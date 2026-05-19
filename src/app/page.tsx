import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import LanguageCard from "@/components/LanguageCard";
import Footer from "@/components/Footer";
import { languages } from "@/lib/languages";

export default function Home() {
  return (
    <>
      <Navbar />
      <main className="flex-1">
        <Hero />
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {languages.map((lang) => (
              <LanguageCard key={lang.slug} language={lang} />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
