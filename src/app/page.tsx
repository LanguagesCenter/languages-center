import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import LanguageGrid from "@/components/LanguageGrid";
import Footer from "@/components/Footer";
import ResetSuccessBanner from "@/components/ResetSuccessBanner";
import { languages } from "@/lib/languages";

export default function Home() {
  return (
    <>
      <ResetSuccessBanner />
      <Navbar />
      <main className="flex-1">
        <Hero />
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <LanguageGrid languages={languages} />
        </section>
      </main>
      <Footer />
    </>
  );
}
