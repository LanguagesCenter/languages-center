import { notFound } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { getTravelPhrasebook } from "@/lib/travel-phrases";
import TravelGuideClient from "./TravelGuideClient";

export function generateStaticParams() {
  return [{ language: "spanish" }, { language: "french" }];
}

export async function generateMetadata(
  props: PageProps<"/languages/[language]/travel-guide">,
) {
  const { language } = await props.params;
  const book = getTravelPhrasebook(language);
  if (!book) return { title: "Phrase Passport — Languages Center" };
  return {
    title: `${book.language} Phrase Passport — Languages Center`,
    description: `65 essential ${book.language} phrases with pronunciation and audio — your pocket guide to getting by, plus a built-in flashcard trainer.`,
  };
}

export default async function TravelGuidePage(
  props: PageProps<"/languages/[language]/travel-guide">,
) {
  const { language } = await props.params;
  const book = getTravelPhrasebook(language);
  if (!book) notFound();

  return (
    <>
      <Navbar />
      <main className="flex-1 bg-gradient-to-b from-peach-light/40 to-background">
        <TravelGuideClient book={book} />
      </main>
      <Footer />
    </>
  );
}
