import { notFound } from "next/navigation";
import PreviewLessonRunner from "@/components/PreviewLessonRunner";
import { getPreviewLesson } from "@/lib/traveler-preview";

export default async function PreviewLessonPage(
  props: PageProps<"/preview/madrid/[lesson]">,
) {
  const { lesson: lessonRaw } = await props.params;
  const lessonId = Number(lessonRaw);
  if (!Number.isFinite(lessonId)) notFound();

  const lesson = getPreviewLesson(lessonId);
  if (!lesson) notFound();

  return <PreviewLessonRunner lesson={lesson} lang="es-ES" />;
}
