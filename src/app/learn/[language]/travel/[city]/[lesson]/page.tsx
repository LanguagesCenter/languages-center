import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import { createClient } from "@/lib/supabase/server";
import { isCurrentUserPremium } from "@/lib/learn";
import { getTravelerLessonWithContent } from "@/lib/traveler";
import TravelerLessonRunner from "@/components/TravelerLessonRunner";
import PreviewLessonRunner from "@/components/PreviewLessonRunner";
import { markLessonComplete } from "./actions";

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

  // v2 (Adventure format) rows: mount PreviewLessonRunner wired to the
  // real markLessonComplete server action and DB-derived next-lesson.
  if (content.v2) {
    const nextLesson = content.nextLesson
      ? {
          id: content.nextLesson.id,
          title: content.nextLesson.title,
          location: content.nextLesson.locationName,
          isPremium: content.nextLesson.isPremium,
        }
      : undefined;
    const v2Lesson = {
      ...content.v2,
      city: content.courseCity,
      country: content.courseCountry,
      nextLesson,
    };
    return (
      <>
        <Navbar />
        <main className="flex-1">
          <PreviewLessonRunner
            lesson={v2Lesson}
            lang={speechLang}
            lessonId={content.lesson.id}
            markComplete={markLessonComplete}
            exitHref={`/learn/${langSlug}/travel/${citySlug}`}
            nextLessonHref={
              content.nextLesson
                ? `/learn/${langSlug}/travel/${citySlug}/${content.nextLesson.id}`
                : undefined
            }
            isPremium={isPremium}
          />
        </main>
      </>
    );
  }

  // Legacy v1 runner for lessons that haven't been regenerated yet.
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
