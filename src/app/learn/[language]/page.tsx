import Link from "next/link";
import Image from "next/image";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import {
  getLanguageBySlug,
  getCourseTreeForLanguage,
  type CourseWithLessons,
  type LessonWithStatus,
} from "@/lib/learn";

const FLAG_CODES: Record<string, string> = {
  spanish: "es",
  french: "fr",
  german: "de",
  greek: "gr",
  swedish: "se",
  danish: "dk",
  finnish: "fi",
  albanian: "al",
  icelandic: "is",
  faroese: "fo",
  corsican: "fr",
  english: "gb",
};

const TIER_STYLES: Record<string, { bg: string; accent: string; ring: string }> = {
  Beginner: {
    bg: "from-teal-light to-white",
    accent: "text-teal-dark",
    ring: "ring-teal/30",
  },
  Intermediate: {
    bg: "from-peach-light to-white",
    accent: "text-amber-700",
    ring: "ring-peach-dark/40",
  },
  Advanced: {
    bg: "from-red-50 to-white",
    accent: "text-red-700",
    ring: "ring-red-200",
  },
};

function LessonIcon({ type }: { type: string }) {
  if (type === "grammar") {
    return (
      <svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M4 6h16M4 12h10M4 18h7" />
      </svg>
    );
  }
  if (type === "phrases") {
    return (
      <svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.86 9.86 0 0 1-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8Z" />
      </svg>
    );
  }
  if (type === "listening") {
    return (
      <svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M15.536 8.464a5 5 0 0 1 0 7.072M18.364 5.636a9 9 0 0 1 0 12.728M5 9v6a2 2 0 0 0 2 2h2l4 4V3L9 7H7a2 2 0 0 0-2 2Z" />
      </svg>
    );
  }
  return (
    <svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25" />
    </svg>
  );
}

function LessonNode({
  lesson,
  languageSlug,
  offset,
}: {
  lesson: LessonWithStatus;
  languageSlug: string;
  offset: number;
}) {
  const stateClasses = lesson.completed
    ? "bg-gradient-to-br from-teal to-teal-dark text-white shadow-lg shadow-teal/30 ring-4 ring-teal/20"
    : lesson.locked
      ? "bg-navy/10 text-navy/30 cursor-not-allowed"
      : "bg-white border-4 border-teal text-teal hover:scale-110 hover:shadow-xl shadow-md";

  const content = (
    <div className="flex flex-col items-center group" style={{ marginLeft: `${offset}px` }}>
      <div
        className={`w-20 h-20 sm:w-24 sm:h-24 rounded-full flex items-center justify-center font-bold transition-all duration-200 ${stateClasses}`}
      >
        {lesson.completed ? (
          <svg
            className="w-10 h-10"
            fill="none"
            stroke="currentColor"
            strokeWidth={3}
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        ) : lesson.locked ? (
          <svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
          </svg>
        ) : (
          <LessonIcon type={lesson.type} />
        )}
      </div>
      <div className="mt-3 text-center max-w-[140px]">
        <p
          className={`text-sm font-semibold leading-tight ${
            lesson.locked ? "text-navy/40" : "text-navy"
          }`}
        >
          {lesson.title}
        </p>
        <p className="text-xs text-navy/40 mt-0.5 capitalize">{lesson.type}</p>
      </div>
    </div>
  );

  if (lesson.locked) return content;

  return (
    <Link href={`/learn/${languageSlug}/${lesson.id}`} className="block">
      {content}
    </Link>
  );
}

function CourseSection({
  course,
  languageSlug,
}: {
  course: CourseWithLessons;
  languageSlug: string;
}) {
  const tier = TIER_STYLES[course.title] ?? TIER_STYLES.Beginner;
  const completed = course.lessons.filter((l) => l.completed).length;
  const total = course.lessons.length;
  const offsets = [0, 80, 40, -40, -80];

  return (
    <section className={`rounded-3xl bg-gradient-to-b ${tier.bg} border border-border p-6 sm:p-10`}>
      <div className="flex items-center justify-between mb-8 flex-wrap gap-3">
        <div>
          <span
            className={`inline-block text-xs font-bold uppercase tracking-wider mb-1 ${tier.accent}`}
          >
            {course.title}
          </span>
          <h2 className="text-2xl font-bold text-navy">{course.description}</h2>
        </div>
        <div className="text-sm text-navy/60">
          <span className="font-semibold text-navy">{completed}</span> / {total} lessons
        </div>
      </div>

      <div className="relative flex flex-col items-center gap-10">
        {course.lessons.map((lesson, idx) => (
          <LessonNode
            key={lesson.id}
            lesson={lesson}
            languageSlug={languageSlug}
            offset={offsets[idx % offsets.length]}
          />
        ))}
      </div>
    </section>
  );
}

export default async function LanguagePage(props: PageProps<"/learn/[language]">) {
  const { language: slug } = await props.params;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    redirect("/login");
  }

  const language = await getLanguageBySlug(slug);
  if (!language) notFound();

  const tree = await getCourseTreeForLanguage(language.id);
  const flagCode = FLAG_CODES[language.code] ?? language.code;

  const totalLessons = tree.reduce((sum, c) => sum + c.lessons.length, 0);
  const completedLessons = tree.reduce(
    (sum, c) => sum + c.lessons.filter((l) => l.completed).length,
    0,
  );

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-6">
          <Link
            href="/learn"
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            All languages
          </Link>
          <div className="flex items-center gap-4">
            <Image
              src={`https://flagcdn.com/w80/${flagCode}.png`}
              alt={`${language.name} flag`}
              width={64}
              height={48}
              className="rounded-md object-cover shadow-sm"
            />
            <div>
              <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
                {language.name}
              </h1>
              <p className="text-sm text-navy/60 mt-1">
                {completedLessons} of {totalLessons} lessons complete
              </p>
            </div>
          </div>
        </section>

        <section className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pb-20 space-y-10">
          {tree.map((course) => (
            <CourseSection key={course.id} course={course} languageSlug={slug} />
          ))}
        </section>
      </main>
      <Footer />
    </>
  );
}
