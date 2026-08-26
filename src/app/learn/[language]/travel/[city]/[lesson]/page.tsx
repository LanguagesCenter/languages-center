import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import { getTravelerCourseByCitySlug } from "@/lib/traveler";

const SUPPORTED_LANGS = new Set(["spanish", "french"]);

// Placeholder lesson runner. The traveler-lesson runner (image →
// explanation → dialogue → quiz walkthrough) is a follow-up build; this
// page keeps the URL structure intact so timeline cards on the city
// page don't lead to a 404 in the meantime.
export default async function TravelerLessonPage(
  props: PageProps<"/learn/[language]/travel/[city]/[lesson]">,
) {
  const { language: langSlug, city: citySlug, lesson: lessonIdRaw } = await props.params;
  if (!SUPPORTED_LANGS.has(langSlug)) notFound();

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const data = await getTravelerCourseByCitySlug(langSlug, citySlug);
  if (!data) notFound();

  const lessonId = Number(lessonIdRaw);
  const lesson = data.lessons.find((l) => l.id === lessonId);
  if (!lesson) notFound();

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-16">
          <Link
            href={`/learn/${langSlug}/travel/${citySlug}`}
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            Back to {data.course.city}
          </Link>

          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-teal-dark">
            {data.course.city} · Lesson {lesson.orderIndex}
          </p>
          <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mt-1">
            {lesson.title}
          </h1>
          <p className="text-sm text-navy/60 mt-1.5">{lesson.locationName}</p>

          <div className="mt-8 rounded-2xl border border-dashed border-border bg-white p-8 text-center">
            <p className="text-4xl mb-3" aria-hidden>✈️</p>
            <h2 className="text-lg font-bold text-navy mb-1">Lesson runner coming soon</h2>
            <p className="text-sm text-navy/60 max-w-md mx-auto">
              The image + explanation + dialogue + quiz experience for this
              lesson will land in the next build. Content for Madrid L1 and
              Paris L1 is already seeded; the rest of the lessons are metadata
              only for now.
            </p>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
