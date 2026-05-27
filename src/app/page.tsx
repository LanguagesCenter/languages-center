import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import LanguageGrid from "@/components/LanguageGrid";
import Footer from "@/components/Footer";
import ResetSuccessBanner from "@/components/ResetSuccessBanner";
import { languages as staticLanguages, type Language } from "@/lib/languages";
import { getAllLanguages } from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";

export const revalidate = 60; // refresh every minute so newly seeded langs appear quickly

export default async function Home() {
  // Source of truth is the DB; fall back to the static catalogue if the
  // DB is empty or unreachable (so the page never renders blank).
  const dbLangs = await getAllLanguages().catch(() => []);
  const langs: Language[] =
    dbLangs.length > 0
      ? dbLangs.map((db) => ({
          name: db.name,
          slug: db.code,
          countryCode: FLAG_CODES[db.code] ?? db.code,
          grammar: db.difficulty_grammar,
          pronunciation: db.difficulty_pronunciation,
        }))
      : staticLanguages;

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
