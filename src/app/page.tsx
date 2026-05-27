import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import LanguageGrid, { type LanguageGridItem } from "@/components/LanguageGrid";
import Footer from "@/components/Footer";
import ResetSuccessBanner from "@/components/ResetSuccessBanner";
import { getLanguagesWithLessonCounts } from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";

export const revalidate = 60; // refresh every minute so newly seeded langs appear quickly

export default async function Home() {
  // Source of truth: the `languages` table in Supabase. Every row in the
  // table renders a card — no hardcoded list anywhere.
  const dbLangs = await getLanguagesWithLessonCounts().catch(() => []);

  const langs: LanguageGridItem[] = dbLangs.map((db) => ({
    name: db.name,
    slug: db.code,
    countryCode: FLAG_CODES[db.code] ?? db.code,
    grammar: db.difficulty_grammar,
    pronunciation: db.difficulty_pronunciation,
    lessonsTotal: db.lessonsTotal,
  }));

  return (
    <>
      <ResetSuccessBanner />
      <Navbar />
      <main className="flex-1">
        <Hero />
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <LanguageGrid languages={langs} />
        </section>
      </main>
      <Footer />
    </>
  );
}
