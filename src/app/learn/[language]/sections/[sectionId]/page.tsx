import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import {
  getLanguageBySlug,
  getSectionWithLessons,
  type LessonWithStatus,
} from "@/lib/learn";

const LEVEL_PILL: Record<string, string> = {
  A1: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  A2: "bg-teal-light text-teal-dark ring-teal/30",
  B1: "bg-amber-50 text-amber-800 ring-amber-200",
  B2: "bg-orange-50 text-orange-800 ring-orange-200",
  C1: "bg-rose-50 text-rose-800 ring-rose-200",
};

function LessonCard({
  lesson,
  languageSlug,
  index,
}: {
  lesson: LessonWithStatus;
  languageSlug: string;
  index: number;
}) {
  const body = (
    <div
      className={`relative h-full bg-white border rounded-2xl p-5 transition-all ${
        lesson.locked
          ? "border-border opacity-60"
          : lesson.completed
            ? "border-teal/30 bg-teal-light/40"
            : "border-border hover:border-teal/40 hover:shadow-md hover:-translate-y-0.5"
      }`}
    >
      <div className="flex items-start justify-between mb-3">
        <span className="inline-flex items-center justify-center w-7 h-7 rounded-full bg-navy/5 text-xs font-semibold text-navy/60">
          {index + 1}
        </span>
        {lesson.completed ? (
          <span className="inline-flex items-center gap-1 text-xs font-semibold text-teal-dark">
            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
            Completed
          </span>
        ) : lesson.locked ? (
          <svg className="w-4 h-4 text-navy/40" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
          </svg>
        ) : (
          <span className="inline-flex items-center gap-1 text-xs font-semibold text-teal">
            +{lesson.xp_reward} XP
          </span>
        )}
      </div>
      <h3 className="text-base font-semibold text-navy leading-tight mb-1.5">
        {lesson.title}
      </h3>
      <p className="text-xs text-navy/50 mb-4 line-clamp-2 leading-relaxed">
        {lesson.description}
      </p>
      <div className="flex items-center justify-between text-xs text-navy/50">
        <span className="capitalize">{lesson.type}</span>
        {!lesson.locked && (
          <span className="inline-flex items-center gap-1 text-teal font-semibold">
            {lesson.completed ? "Review" : "Start"}
            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </span>
        )}
      </div>
    </div>
  );

  if (lesson.locked) return body;
  return (
    <Link href={`/learn/${languageSlug}/${lesson.id}`} className="block">
      {body}
    </Link>
  );
}

export default async function SectionPage(
  props: PageProps<"/learn/[language]/sections/[sectionId]">,
) {
  const { language: slug, sectionId: sectionIdStr } = await props.params;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const sectionId = Number(sectionIdStr);
  if (!Number.isFinite(sectionId)) notFound();

  const language = await getLanguageBySlug(slug);
  if (!language) notFound();

  const data = await getSectionWithLessons(sectionId);
  if (!data) notFound();
  if (data.section.language_id !== language.id) notFound();

  const { section, lessons } = data;

  const completed = lessons.filter((l) => l.completed).length;
  const total = lessons.length;
  const pct = total === 0 ? 0 : Math.round((completed / total) * 100);
  const pill = LEVEL_PILL[section.cefr_level] ?? LEVEL_PILL.A1;

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-8">
          <Link
            href={`/learn/${slug}`}
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            Back to {language.name}
          </Link>

          <div className="flex items-start gap-3 mb-3">
            <span
              className={`inline-flex items-center gap-1.5 rounded-full font-semibold px-2.5 py-1 text-xs ${pill} ring-1`}
            >
              {section.cefr_level}
            </span>
            <span className="text-xs text-navy/40">·</span>
            <span className="text-xs text-navy/50">{language.name}</span>
          </div>
          <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mb-2">
            {section.title}
          </h1>
          <p className="text-sm text-navy/60 mb-6">{section.description}</p>

          <div className="bg-white border border-border rounded-2xl p-5">
            <div className="flex items-center justify-between mb-2">
              <p className="text-sm text-navy/60">
                <span className="font-semibold text-navy">{completed}</span> of {total} lessons complete
              </p>
              <span className="text-sm font-semibold text-navy/70">{pct}%</span>
            </div>
            <div className="h-1.5 w-full rounded-full bg-navy/5 overflow-hidden">
              <div
                className="h-full rounded-full bg-gradient-to-r from-teal to-teal-dark transition-all"
                style={{ width: `${pct}%` }}
              />
            </div>
          </div>
        </section>

        <section className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pb-20">
          {lessons.length === 0 ? (
            <p className="text-sm text-navy/50">No lessons in this section yet.</p>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {lessons.map((lesson, idx) => (
                <LessonCard
                  key={lesson.id}
                  lesson={lesson}
                  languageSlug={slug}
                  index={idx}
                />
              ))}
            </div>
          )}
        </section>
      </main>
      <Footer />
    </>
  );
}
