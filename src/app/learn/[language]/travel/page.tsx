import Link from "next/link";
import Image from "next/image";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import TravelerMap from "@/components/TravelerMap";
import { createClient } from "@/lib/supabase/server";
import {
  getTravelerCoursesForLanguage,
  LANGUAGE_COUNTRY_CODES,
} from "@/lib/traveler";

const SUPPORTED = new Set(["spanish", "french"]);

export async function generateMetadata(
  props: PageProps<"/learn/[language]/travel">,
) {
  const { language } = await props.params;
  const langName = language.charAt(0).toUpperCase() + language.slice(1);
  return {
    title: `${langName} Traveler's Course — Languages Center`,
    description: `Simulate a real trip abroad in ${langName}. City by city, sign by sign — learn the ${langName} you'll actually hear on the ground.`,
  };
}

export default async function TravelerLanguagePage(
  props: PageProps<"/learn/[language]/travel">,
) {
  const { language: slug } = await props.params;
  if (!SUPPORTED.has(slug)) notFound();

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const language = slug as "spanish" | "french";
  const courses = await getTravelerCoursesForLanguage(language);
  const langName = language.charAt(0).toUpperCase() + language.slice(1);
  const baseHref = `/learn/${language}/travel`;
  const highlightCountryCodes = LANGUAGE_COUNTRY_CODES[language] ?? [];

  return (
    <>
      <Navbar />
      <main className="flex-1">
        {/* Header */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-12 pb-4">
          <Link
            href="/"
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-4"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            Back to home
          </Link>
          <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-3">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.16em] text-teal-dark">
                Traveler&rsquo;s Course
              </p>
              <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-navy tracking-tight mt-1">
                {langName} on the ground
              </h1>
              <p className="text-sm sm:text-base text-navy/60 mt-2 max-w-2xl">
                A separate track from the main course. Pick a city and walk
                through two weeks of realistic scenarios — airport signs,
                cafe orders, metro maps, the exact {langName} you&rsquo;ll
                actually hear on a trip.
              </p>
            </div>
          </div>
        </section>

        {/* Map */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-6">
          {courses.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-border bg-white p-8 text-center text-sm text-navy/60">
              No traveler courses seeded for this language yet — check back soon.
            </div>
          ) : (
            <TravelerMap
              language={language}
              cities={courses.map((c) => ({
                city: c.city,
                country: c.country,
                slug: c.slug,
                coords: c.coords,
              }))}
              highlightCountryCodes={highlightCountryCodes}
              baseHref={baseHref}
            />
          )}
        </section>

        {/* City cards */}
        {courses.length > 0 && (
          <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
            <h2 className="text-xl sm:text-2xl font-bold text-navy tracking-tight mb-4">
              Choose your city
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
              {courses.map((c) => (
                <CityCard key={c.id} baseHref={baseHref} course={c} />
              ))}
            </div>
          </section>
        )}
      </main>
      <Footer />
    </>
  );
}

function CityCard({
  baseHref,
  course,
}: {
  baseHref: string;
  course: Awaited<ReturnType<typeof getTravelerCoursesForLanguage>>[number];
}) {
  const started = course.lessonsCompleted > 0;
  const pct =
    course.lessonsTotal === 0
      ? 0
      : Math.round((course.lessonsCompleted / course.lessonsTotal) * 100);
  return (
    <Link
      href={`${baseHref}/${course.slug}`}
      className="group relative flex flex-col overflow-hidden bg-white border border-border rounded-2xl hover:border-teal/40 hover:shadow-lg sm:hover:-translate-y-0.5 transition-all"
    >
      <div className="relative w-full aspect-[16/10] bg-navy/5">
        {course.coverImageUrl && (
          <Image
            src={course.coverImageUrl}
            alt={`${course.city}, ${course.country}`}
            fill
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className="object-cover group-hover:scale-[1.02] transition-transform duration-500"
          />
        )}
        <div className="absolute top-3 left-3">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-white/95 backdrop-blur px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-amber-800 shadow-sm">
            <span aria-hidden>✈</span>
            First {course.freePreviewCount} lessons free
          </span>
        </div>
        <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/60 to-transparent pointer-events-none" />
        <div className="absolute bottom-3 left-3 right-3">
          <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-white/80">
            {course.country}
          </p>
          <h3 className="text-2xl font-bold text-white leading-tight drop-shadow-sm">
            {course.city}
          </h3>
        </div>
      </div>

      <div className="flex flex-col flex-1 p-4 sm:p-5">
        {course.description && (
          <p className="text-sm text-navy/60 leading-relaxed line-clamp-2 mb-4">
            {course.description}
          </p>
        )}
        <div className="mt-auto space-y-3">
          <div className="flex items-center justify-between text-xs text-navy/50">
            <span>{course.lessonsTotal} lessons</span>
            {started && (
              <span className="tabular-nums font-semibold text-teal-dark">
                {course.lessonsCompleted} / {course.lessonsTotal} ({pct}%)
              </span>
            )}
          </div>
          {started && (
            <div className="w-full h-2 bg-navy/5 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full transition-all duration-500"
                style={{ width: `${pct}%` }}
              />
            </div>
          )}
          <span className="mt-1 inline-flex items-center justify-center gap-1.5 w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl group-hover:bg-teal-dark active:scale-[0.98] transition-all">
            {started ? "Continue journey" : "Start journey"}
            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </span>
        </div>
      </div>
    </Link>
  );
}
