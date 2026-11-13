import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import { createClient } from "@/lib/supabase/server";
import {
  getOpenSkippedSpeakingForCity,
  getTravelerCourseByCitySlug,
} from "@/lib/traveler";
import SpeakingPracticeRunner from "./SpeakingPracticeRunner";

const SUPPORTED_LANGS = new Set(["spanish", "french"]);
const SPEECH_LANG: Record<string, string> = {
  spanish: "es-ES",
  french: "fr-FR",
};

export async function generateMetadata(
  props: PageProps<"/learn/[language]/travel/[city]/speaking-practice">,
) {
  const { city } = await props.params;
  return {
    title: `${city} · Speaking practice — Languages Center`,
  };
}

export default async function SpeakingPracticePage(
  props: PageProps<"/learn/[language]/travel/[city]/speaking-practice">,
) {
  const { language: langSlug, city: citySlug } = await props.params;
  if (!SUPPORTED_LANGS.has(langSlug)) notFound();

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const bundle = await getTravelerCourseByCitySlug(langSlug, citySlug);
  if (!bundle) notFound();

  const rows = await getOpenSkippedSpeakingForCity({
    languageSlug: langSlug,
    citySlug,
  });

  const speechLang = SPEECH_LANG[langSlug] ?? "en-US";

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 pb-4">
          <Link
            href={`/learn/${langSlug}/travel/${citySlug}`}
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-4"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            Back to {bundle.course.city}
          </Link>
          <h1 className="text-3xl sm:text-4xl font-black text-navy tracking-tight">
            Speaking practice
          </h1>
          <p className="text-sm text-navy/60 mt-1 leading-relaxed">
            Everything you parked earlier with &ldquo;I can&apos;t speak now&rdquo;,
            grouped by lesson. Pass each one to clear it.
          </p>
        </section>
        <SpeakingPracticeRunner rows={rows} speechLang={speechLang} />
      </main>
    </>
  );
}
