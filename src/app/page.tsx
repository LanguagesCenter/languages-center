import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ResetSuccessBanner from "@/components/ResetSuccessBanner";
import HomeMarketing, {
  type HomeMarketingCity,
} from "@/components/HomeMarketing";
import HomePersonalized, {
  type ActiveLanguageEntry,
  type ExploreLanguageEntry,
  type StartedTripEntry,
} from "@/components/HomePersonalized";
import { type LanguageGridItem } from "@/components/LanguageGrid";
import {
  getLanguagesWithLessonCounts,
  getLanguagesWithProgress,
  getStartedLanguageOrder,
  getUserProfile,
  getLessonsCompletedThisWeek,
  getCEFRTreeForLanguage,
  getFirstIncompleteLessonId,
  getLastCompletedLessonInLanguage,
  getHighestReachedLevel,
  type CEFRLevel,
} from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";
import { createClient } from "@/lib/supabase/server";
import { getServerLang } from "@/lib/i18n-server";
import { getLocalizedLanguageName } from "@/lib/i18n";
import {
  getTravelerCompletedCountsByLanguage,
  getStartedTravelerCourses,
  getAllTravelerCourses,
} from "@/lib/traveler";

// Per-user CTA on each card (Start vs Continue) means the homepage has
// to render per request. Dropping the static cache; the page is still
// cheap to render.
export const dynamic = "force-dynamic";

const WEEKLY_GOAL = 5;

export default async function Home() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const [dbLangs, startedOrder, travelerCompletedCounts, allCities, startedTrips] =
    await Promise.all([
      getLanguagesWithLessonCounts().catch(() => []),
      getStartedLanguageOrder().catch(
        () => [] as Array<{ code: string; firstActivity: string }>,
      ),
      getTravelerCompletedCountsByLanguage().catch(
        () => ({}) as Record<string, number>,
      ),
      getAllTravelerCourses().catch(
        () => [] as Awaited<ReturnType<typeof getAllTravelerCourses>>,
      ),
      user
        ? getStartedTravelerCourses().catch(
            () => [] as Awaited<ReturnType<typeof getStartedTravelerCourses>>,
          )
        : Promise.resolve(
            [] as Awaited<ReturnType<typeof getStartedTravelerCourses>>,
          ),
    ]);

  const startedSlugsInOrder = startedOrder.map((s) => s.code);
  const startedSet = new Set(startedSlugsInOrder);
  // "Returning" now means EITHER fluency progress OR traveler progress.
  // Trip-only users still need the personalized homepage.
  const hasAnyTrip = startedTrips.length > 0;
  const hasAnyFluency = !!user && startedSet.size > 0;
  const isReturning = !!user && (hasAnyFluency || hasAnyTrip);

  // The homepage city grid for anon/no-progress users — same list for
  // every visitor, derived from the DB.
  const cities: HomeMarketingCity[] = allCities.map((c) => ({
    languageSlug: c.languageSlug,
    city: c.city,
    country: c.country,
    citySlug: c.citySlug,
    coverImageUrl: c.coverImageUrl,
    lessonsTotal: c.lessonsTotal,
    freePreviewCount: c.freePreviewCount,
  }));

  if (isReturning) {
    const uiLang = await getServerLang();
    const [progress, profile, weeklyCount] = await Promise.all([
      getLanguagesWithProgress(),
      getUserProfile(),
      getLessonsCompletedThisWeek(),
    ]);

    // Fluency progress — only languages the user has completed at least
    // one Fluency Course lesson in.
    const activeProgress = progress.filter((p) => p.completedLessons > 0);

    const active: ActiveLanguageEntry[] = await Promise.all(
      activeProgress.map(async (entry) => {
        const [tree, firstIncompleteId, lastCompleted] = await Promise.all([
          getCEFRTreeForLanguage(entry.language.id),
          getFirstIncompleteLessonId(entry.language.id),
          getLastCompletedLessonInLanguage(entry.language.id),
        ]);
        let currentLevel: CEFRLevel = getHighestReachedLevel(tree);
        for (const group of tree) {
          if (group.lessonsTotal > 0 && group.lessonsCompleted < group.lessonsTotal) {
            currentLevel = group.level;
            break;
          }
        }
        const levelGroup = tree.find((g) => g.level === currentLevel);
        const levelTotal = levelGroup?.lessonsTotal ?? 0;
        const levelCompleted = levelGroup?.lessonsCompleted ?? 0;
        const levelPct =
          levelTotal === 0 ? 0 : Math.round((levelCompleted / levelTotal) * 100);
        const localizedName = getLocalizedLanguageName(
          entry.language.code,
          uiLang,
          entry.language.name,
        );
        const continueHref = firstIncompleteId
          ? `/learn/${entry.language.code}/${firstIncompleteId}`
          : `/learn/${entry.language.code}`;
        return {
          slug: entry.language.code,
          name: localizedName,
          countryCode: FLAG_CODES[entry.language.code] ?? entry.language.code,
          currentLevel,
          levelCompleted,
          levelTotal,
          levelPct,
          totalCompleted: entry.completedLessons,
          totalLessons: entry.totalLessons,
          totalXp: entry.stats?.total_xp ?? 0,
          continueHref,
          lastLessonTitle: lastCompleted?.title ?? null,
          travelerCompletedCount:
            travelerCompletedCounts[entry.language.code] ?? 0,
        };
      }),
    );

    // Preserve the FIRST-started ordering already used elsewhere.
    active.sort((a, b) => {
      const ai = startedSlugsInOrder.indexOf(a.slug);
      const bi = startedSlugsInOrder.indexOf(b.slug);
      const av = ai === -1 ? Number.MAX_SAFE_INTEGER : ai;
      const bv = bi === -1 ? Number.MAX_SAFE_INTEGER : bi;
      return av - bv;
    });

    // Shape trips for the personalized page. Already sorted
    // server-side by getStartedTravelerCourses().
    const trips: StartedTripEntry[] = startedTrips.map((t) => ({
      languageSlug: t.languageSlug,
      city: t.city,
      country: t.country,
      citySlug: t.citySlug,
      coverImageUrl: t.coverImageUrl,
      lessonsTotal: t.lessonsTotal,
      lessonsCompleted: t.lessonsCompleted,
      nextLessonId: t.nextLessonId,
      nextLessonTitle: t.nextLessonTitle,
      nextLessonLocation: t.nextLessonLocation,
    }));

    const activeCodes = new Set(active.map((a) => a.slug));
    const explore: ExploreLanguageEntry[] = progress
      .filter(
        (p) =>
          !activeCodes.has(p.language.code) && p.totalLessons > 0,
      )
      .map((p) => ({
        slug: p.language.code,
        name: getLocalizedLanguageName(
          p.language.code,
          uiLang,
          p.language.name,
        ),
        countryCode: FLAG_CODES[p.language.code] ?? p.language.code,
        lessonsTotal: p.totalLessons,
      }));

    const displayName =
      (user.user_metadata?.full_name as string | undefined)?.trim() ||
      (user.user_metadata?.username as string | undefined)?.trim() ||
      (user.email?.split("@")[0] ?? "friend");

    return (
      <>
        <ResetSuccessBanner />
        <Navbar />
        <HomePersonalized
          displayName={displayName}
          totalXp={profile?.total_xp ?? 0}
          currentStreak={profile?.current_streak ?? 0}
          longestStreak={profile?.longest_streak ?? 0}
          weeklyCount={weeklyCount}
          weeklyGoal={WEEKLY_GOAL}
          trips={trips}
          active={active}
          explore={explore}
        />
        <Footer />
      </>
    );
  }

  // Marketing view — anonymous visitors and signed-in users with zero
  // progress. Language grid is prepared here (needs FLAG_CODES lookup).
  const langs: LanguageGridItem[] = dbLangs.map((db) => ({
    name: db.name,
    slug: db.code,
    countryCode: FLAG_CODES[db.code] ?? db.code,
    grammar: db.difficulty_grammar,
    pronunciation: db.difficulty_pronunciation,
    lessonsTotal: db.lessonsTotal,
    hasProgress: startedSet.has(db.code),
  }));

  return (
    <>
      <ResetSuccessBanner />
      <Navbar />
      <HomeMarketing
        langs={langs}
        startedSlugsInOrder={startedSlugsInOrder}
        travelerCompletedCounts={travelerCompletedCounts}
        cities={cities}
        isLoggedIn={!!user}
      />
      <Footer />
    </>
  );
}
