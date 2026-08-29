import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import { isCurrentUserPremium } from "@/lib/learn";
import { getTravelerLessonWithContent } from "@/lib/traveler";
import TravelerLessonRunner from "@/components/TravelerLessonRunner";

const SUPPORTED_LANGS = new Set(["spanish", "french"]);

// Locale for the browser's SpeechSynthesis API. Determines which
// accent plays audio for target-language phrases and dialogue.
const SPEECH_LANG: Record<string, string> = {
  spanish: "es-ES",
  french: "fr-FR",
};

export default async function TravelerLessonPage(
  props: PageProps<"/learn/[language]/travel/[city]/[lesson]">,
) {
  const {
    language: langSlug,
    city: citySlug,
    lesson: lessonIdRaw,
  } = await props.params;
  if (!SUPPORTED_LANGS.has(langSlug)) notFound();

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const lessonId = Number(lessonIdRaw);
  if (!Number.isFinite(lessonId)) notFound();

  const content = await getTravelerLessonWithContent(
    langSlug,
    citySlug,
    lessonId,
  );
  if (!content) notFound();

  const isPremium = await isCurrentUserPremium();

  // Premium gate: paywalled lessons redirect the free user back to the
  // city timeline (where the upgrade prompt is prominent). Free lessons
  // (order 1–5) are always accessible.
  if (content.lesson.isPremium && !isPremium) {
    redirect(`/learn/${langSlug}/travel/${citySlug}`);
  }

  const speechLang = SPEECH_LANG[langSlug] ?? "en-US";

  return (
    <>
      <Navbar />
      <main className="flex-1 bg-gradient-to-b from-amber-50/50 via-white to-white">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pt-6 pb-4">
          <Link
            href={`/learn/${langSlug}/travel/${citySlug}`}
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors"
          >
            <svg
              className="w-4 h-4"
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back to {content.courseCity}
          </Link>
        </div>

        <TravelerLessonRunner
          languageSlug={langSlug}
          citySlug={citySlug}
          content={content}
          speechLang={speechLang}
          isPremium={isPremium}
        />
      </main>
      <Footer />
    </>
  );
}
