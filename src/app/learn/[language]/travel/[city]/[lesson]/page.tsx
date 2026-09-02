import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
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

  // No Footer, no page background wrapper — the runner is a full
  // adventure surface that owns its own layout and progress chrome.
  // The Back-to-city link lives inside the runner's sticky progress
  // bar instead.
  return (
    <>
      <Navbar />
      <main className="flex-1">
        <TravelerLessonRunner
          languageSlug={langSlug}
          citySlug={citySlug}
          content={content}
          speechLang={speechLang}
          isPremium={isPremium}
        />
      </main>
    </>
  );
}
