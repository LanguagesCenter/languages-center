import { createClient } from "@/lib/supabase/server";

// Traveler's Course data helpers. Keeps all traveler-DB queries in one
// place so the pages stay presentational.

export interface TravelerCourseSummary {
  id: number;
  city: string;
  country: string;
  slug: string; // url-safe
  description: string | null;
  coverImageUrl: string; // never null — we always fall back to a curated Unsplash URL
  orderIndex: number;
  lessonsTotal: number;
  lessonsCompleted: number;
  freePreviewCount: number; // how many of these lessons are free (is_premium=false)
  coords: [number, number]; // [lng, lat]
}

export interface TravelerLessonSummary {
  id: number;
  title: string;
  locationName: string;
  lessonType: "sign" | "conversation" | "cultural" | "mixed";
  orderIndex: number;
  xpReward: number;
  isPremium: boolean;
  completed: boolean;
}

// Coordinates + curated Unsplash cover for every city we ship. Keyed by
// the lowercase city name (matches what's in the DB). Adding a new city
// = one row here + one row in traveler_courses.
const CITY_META: Record<
  string,
  { coords: [number, number]; cover: string; countryCode: string }
> = {
  Madrid:         { coords: [-3.7038, 40.4168], cover: "https://images.unsplash.com/photo-1543783207-ec64e4d95325?w=1600&h=900&fit=crop&q=80", countryCode: "ES" },
  Barcelona:      { coords: [ 2.1734, 41.3851], cover: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=1600&h=900&fit=crop&q=80", countryCode: "ES" },
  "Mexico City":  { coords: [-99.1332, 19.4326], cover: "https://images.unsplash.com/photo-1518659526054-190340b32735?w=1600&h=900&fit=crop&q=80", countryCode: "MX" },
  "Buenos Aires": { coords: [-58.3816, -34.6037], cover: "https://images.unsplash.com/photo-1589909202802-8f4aadce1849?w=1600&h=900&fit=crop&q=80", countryCode: "AR" },
  Paris:          { coords: [ 2.3522, 48.8566], cover: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1600&h=900&fit=crop&q=80", countryCode: "FR" },
  Lyon:           { coords: [ 4.8357, 45.7640], cover: "https://images.unsplash.com/photo-1524429656601-1beb8ce3b26a?w=1600&h=900&fit=crop&q=80", countryCode: "FR" },
  Montreal:       { coords: [-73.5673, 45.5017], cover: "https://images.unsplash.com/photo-1519178614-68673b201f36?w=1600&h=900&fit=crop&q=80", countryCode: "CA" },
};

// ISO 3166-1 alpha-2 codes of countries where each course language is
// spoken widely enough to justify highlighting on the map.
export const LANGUAGE_COUNTRY_CODES: Record<string, string[]> = {
  spanish: [
    "ES","MX","AR","CO","PE","VE","CL","EC","GT","CU","BO","DO","HN","PY","SV","NI","CR","PR","UY","GQ","PA",
  ],
  french: [
    "FR","CA","BE","CH","LU","MC","SN","CI","ML","BF","NE","GA","CG","CD","BJ","TG","MG","CM","HT","DJ","GN","VU",
  ],
};

export function cityToSlug(city: string): string {
  return city.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function coverFor(city: string): string {
  return CITY_META[city]?.cover ?? "";
}

function coordsFor(city: string): [number, number] {
  return CITY_META[city]?.coords ?? [0, 0];
}

// Returns the traveler courses for the given language slug ("spanish" |
// "french"), each row enriched with lesson counts and (if the user is
// signed in) their completion count.
export async function getTravelerCoursesForLanguage(
  languageSlug: string,
): Promise<TravelerCourseSummary[]> {
  const supabase = await createClient();

  const { data: lang } = await supabase
    .from("languages")
    .select("id")
    .eq("code", languageSlug)
    .maybeSingle();
  if (!lang) return [];

  const { data: courses } = await supabase
    .from("traveler_courses")
    .select("id, city, country, description, cover_image_url, order_index")
    .eq("language_id", lang.id)
    .order("order_index");

  const courseRows = (courses ?? []) as Array<{
    id: number;
    city: string;
    country: string;
    description: string | null;
    cover_image_url: string | null;
    order_index: number;
  }>;
  if (courseRows.length === 0) return [];

  const courseIds = courseRows.map((c) => c.id);

  const { data: lessons } = await supabase
    .from("traveler_lessons")
    .select("id, traveler_course_id, is_premium")
    .in("traveler_course_id", courseIds);
  const lessonRows = (lessons ?? []) as Array<{
    id: number;
    traveler_course_id: number;
    is_premium: boolean;
  }>;

  const {
    data: { user },
  } = await supabase.auth.getUser();

  let completedSet = new Set<number>();
  if (user) {
    const { data: progress } = await supabase
      .from("traveler_progress")
      .select("traveler_lesson_id")
      .eq("user_id", user.id)
      .eq("completed", true)
      .in("traveler_lesson_id", lessonRows.map((l) => l.id));
    completedSet = new Set(
      (progress ?? []).map((p: { traveler_lesson_id: number }) => p.traveler_lesson_id),
    );
  }

  return courseRows.map((c) => {
    const courseLessons = lessonRows.filter((l) => l.traveler_course_id === c.id);
    const free = courseLessons.filter((l) => !l.is_premium).length;
    const completed = courseLessons.filter((l) => completedSet.has(l.id)).length;
    return {
      id: c.id,
      city: c.city,
      country: c.country,
      slug: cityToSlug(c.city),
      description: c.description,
      coverImageUrl: coverFor(c.city) || c.cover_image_url || "",
      orderIndex: c.order_index,
      lessonsTotal: courseLessons.length,
      lessonsCompleted: completed,
      freePreviewCount: free,
      coords: coordsFor(c.city),
    };
  });
}

// Returns a single traveler course looked up by (languageSlug, citySlug),
// plus its lessons in order and per-lesson completion state.
export async function getTravelerCourseByCitySlug(
  languageSlug: string,
  citySlug: string,
): Promise<{ course: TravelerCourseSummary; lessons: TravelerLessonSummary[] } | null> {
  const courses = await getTravelerCoursesForLanguage(languageSlug);
  const course = courses.find((c) => c.slug === citySlug);
  if (!course) return null;

  const supabase = await createClient();
  const { data: lessons } = await supabase
    .from("traveler_lessons")
    .select("id, title, location_name, lesson_type, order_index, xp_reward, is_premium")
    .eq("traveler_course_id", course.id)
    .order("order_index");
  const lessonRows = (lessons ?? []) as Array<{
    id: number;
    title: string;
    location_name: string;
    lesson_type: TravelerLessonSummary["lessonType"];
    order_index: number;
    xp_reward: number;
    is_premium: boolean;
  }>;

  const {
    data: { user },
  } = await supabase.auth.getUser();

  let completedSet = new Set<number>();
  if (user && lessonRows.length > 0) {
    const { data: progress } = await supabase
      .from("traveler_progress")
      .select("traveler_lesson_id")
      .eq("user_id", user.id)
      .eq("completed", true)
      .in("traveler_lesson_id", lessonRows.map((l) => l.id));
    completedSet = new Set(
      (progress ?? []).map((p: { traveler_lesson_id: number }) => p.traveler_lesson_id),
    );
  }

  return {
    course,
    lessons: lessonRows.map((l) => ({
      id: l.id,
      title: l.title,
      locationName: l.location_name,
      lessonType: l.lesson_type,
      orderIndex: l.order_index,
      xpReward: l.xp_reward,
      isPremium: l.is_premium,
      completed: completedSet.has(l.id),
    })),
  };
}

// Cover image lookup, exposed for the city-detail hero.
export function coverImageForCity(city: string): string {
  return coverFor(city);
}
