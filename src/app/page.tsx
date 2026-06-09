import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import LanguageGrid, { type LanguageGridItem } from "@/components/LanguageGrid";
import Footer from "@/components/Footer";
import ResetSuccessBanner from "@/components/ResetSuccessBanner";
import {
  getLanguagesWithLessonCounts,
  getLanguagesUserHasStarted,
} from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";

// Per-user CTA on each card (Start vs Continue) means the homepage has
// to render per request now. Dropping the static cache; the page is
// still cheap to render.
export const dynamic = "force-dynamic";

export default async function Home() {
  // Source of truth: the `languages` table in Supabase. Every row in the
  // table renders a card — no hardcoded list anywhere.
  const [dbLangs, started] = await Promise.all([
    getLanguagesWithLessonCounts().catch(() => []),
    getLanguagesUserHasStarted().catch(() => new Set<string>()),
  ]);

  // Global "returning learner" flag: once the user has any completed
  // lesson anywhere, every homepage card flips its CTA to
  // "Continue learning X" — even for languages they haven't tried yet.
  // The user knows the site; "Start learning" only makes sense for
  // first-time visitors with zero progress.
  const userIsReturning = started.size > 0;

  const langs: LanguageGridItem[] = dbLangs.map((db) => ({
    name: db.name,
    slug: db.code,
    countryCode: FLAG_CODES[db.code] ?? db.code,
    grammar: db.difficulty_grammar,
    pronunciation: db.difficulty_pronunciation,
    lessonsTotal: db.lessonsTotal,
    hasProgress: userIsReturning,
  }));

  return (
    <>
      <ResetSuccessBanner />
      <Navbar />
      <main className="flex-1">
        <Hero hasProgress={userIsReturning} />
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <LanguageGrid languages={langs} />
        </section>
      </main>
      <Footer />
    </>
  );
}
