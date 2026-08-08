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
  if (!book) return { title: "Travel Guide — Languages Center" };
  return {
    title: `${book.language} Travel Phrases — Languages Center`,
    description: `65 essential ${book.language} phrases with pronunciation and audio, plus a built-in flashcard trainer for on-the-go study.`,
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
