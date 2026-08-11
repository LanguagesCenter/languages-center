import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ResetSuccessBanner from "@/components/ResetSuccessBanner";
import HomeMarketing from "@/components/HomeMarketing";
import HomePersonalized, {
  type ActiveLanguageEntry,
  type ExploreLanguageEntry,
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
  isCurrentUserPremium,
  type CEFRLevel,
} from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";
import { createClient } from "@/lib/supabase/server";
import { getServerLang } from "@/lib/i18n-server";
import { getLocalizedLanguageName } from "@/lib/i18n";

// Per-user CTA on each card (Start vs Continue) means the homepage has
// to render per request now. Dropping the static cache; the page is
// still cheap to render.
export const dynamic = "force-dynamic";

// Rough weekly target — used only by the "Weekly goal" widget on the
// personalized homepage. Kept as a constant here so it's easy to make
// user-configurable later.
const WEEKLY_GOAL = 5;

export default async function Home() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const [dbLangs, startedOrder, isPremium] = await Promise.all([
    getLanguagesWithLessonCounts().catch(() => []),
    getStartedLanguageOrder().catch(
      () => [] as Array<{ code: string; firstActivity: string }>,
    ),
    isCurrentUserPremium().catch(() => false),
  ]);

  const startedSlugsInOrder = startedOrder.map((s) => s.code);
  const startedSet = new Set(startedSlugsInOrder);
  const isReturning = !!user && startedSet.size > 0;

  // Signed-in learner with real progress → personalized dashboard-style
  // homepage. Everything else falls through to the marketing page.
  if (isReturning) {
    const uiLang = await getServerLang();
    const [progress, profile, weeklyCount] = await Promise.all([
      getLanguagesWithProgress(),
      getUserProfile(),
      getLessonsCompletedThisWeek(),
    ]);

    const activeProgress = progress.filter(
      (p) => p.completedLessons > 0 || (p.stats?.total_xp ?? 0) > 0,
    );

    // For each active language, pull the CEFR tree + first-incomplete
    // lesson + last-completed lesson in parallel so the whole page
    // resolves in roughly one round-trip's worth of latency.
    const active: ActiveLanguageEntry[] = await Promise.all(
      activeProgress.map(async (entry) => {
        const [tree, firstIncompleteId, lastCompleted] = await Promise.all([
          getCEFRTreeForLanguage(entry.language.id),
          getFirstIncompleteLessonId(entry.language.id),
          getLastCompletedLessonInLanguage(entry.language.id),
        ]);
        // Current level = the first level that isn't fully finished. If
        // everything is done, fall back to the highest they've reached.
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
        };
      }),
    );

    // Preserve the FIRST-started ordering the user already sees on
    // /learn — new learners come last so their in-progress language
    // stays at the top.
    active.sort((a, b) => {
      const ai = startedSlugsInOrder.indexOf(a.slug);
      const bi = startedSlugsInOrder.indexOf(b.slug);
      const av = ai === -1 ? Number.MAX_SAFE_INTEGER : ai;
      const bv = bi === -1 ? Number.MAX_SAFE_INTEGER : bi;
      return av - bv;
    });

    const explore: ExploreLanguageEntry[] = progress
      .filter(
        (p) =>
          !startedSet.has(p.language.code) && p.totalLessons > 0,
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
        isPremium={isPremium}
      />
      <Footer />
    </>
  );
}
