import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getLessonWithExercises } from "@/lib/learn";
import LessonClient from "./LessonClient";

export default async function LessonPage(
  props: PageProps<"/learn/[language]/[lesson]">,
) {
  const { language: slug, lesson: lessonIdStr } = await props.params;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const lessonId = Number(lessonIdStr);
  if (!Number.isFinite(lessonId)) notFound();

  const data = await getLessonWithExercises(lessonId);
  if (!data) notFound();
  if (data.language.code !== slug) notFound();

  return (
    <LessonClient
      languageSlug={slug}
      languageName={data.language.name}
      lesson={data.lesson}
      exercises={data.exercises}
      sectionId={data.course.id}
    />
  );
}
