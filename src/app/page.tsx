import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import LanguageGrid, { type LanguageGridItem } from "@/components/LanguageGrid";
import Footer from "@/components/Footer";
import ResetSuccessBanner from "@/components/ResetSuccessBanner";
import {
  getLanguagesWithLessonCounts,
  getStartedLanguageOrder,
  isCurrentUserPremium,
} from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";

// Per-user CTA on each card (Start vs Continue) means the homepage has
// to render per request now. Dropping the static cache; the page is
// still cheap to render.
export const dynamic = "force-dynamic";

export default async function Home() {
  // Source of truth: the `languages` table in Supabase. Every row in the
  // table renders a card — no hardcoded list anywhere.
  const [dbLangs, startedOrder, isPremium] = await Promise.all([
    getLanguagesWithLessonCounts().catch(() => []),
    getStartedLanguageOrder().catch(
      () => [] as Array<{ code: string; firstActivity: string }>,
    ),
    isCurrentUserPremium().catch(() => false),
  ]);

  const startedSlugsInOrder = startedOrder.map((s) => s.code);
  const startedSet = new Set(startedSlugsInOrder);
  const userIsReturning = startedSet.size > 0;

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
      <main className="flex-1">
        <Hero hasProgress={userIsReturning} isPremium={isPremium} />
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12 sm:pb-16 lg:pb-20">
          <LanguageGrid
            languages={langs}
            startedSlugsInOrder={startedSlugsInOrder}
          />
        </section>
      </main>
      <Footer />
    </>
  );
}
