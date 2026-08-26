import Link from "next/link";
import Image from "next/image";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import { isCurrentUserPremium } from "@/lib/learn";
import {
  getTravelerCourseByCitySlug,
  type TravelerLessonSummary,
} from "@/lib/traveler";

const SUPPORTED_LANGS = new Set(["spanish", "french"]);

export async function generateMetadata(
  props: PageProps<"/learn/[language]/travel/[city]">,
) {
  const { language, city } = await props.params;
  if (!SUPPORTED_LANGS.has(language)) return { title: "Traveler's Course — Languages Center" };
  const data = await getTravelerCourseByCitySlug(language, city);
  if (!data) return { title: "Traveler's Course — Languages Center" };
  return {
    title: `${data.course.city} — ${data.course.country} — Traveler's Course`,
    description: `A two-week traveler's course in ${data.course.city}, ${data.course.country}. ${data.course.description ?? ""}`.trim(),
  };
}

const LESSON_TYPE_LABEL: Record<TravelerLessonSummary["lessonType"], string> = {
  sign: "Reading signs",
  conversation: "Conversation",
  cultural: "Cultural",
  mixed: "Mixed",
};

const LESSON_TYPE_COLOR: Record<TravelerLessonSummary["lessonType"], string> = {
  sign: "bg-amber-100 text-amber-800 ring-amber-200",
  conversation: "bg-teal-light text-teal-dark ring-teal/30",
  cultural: "bg-rose-50 text-rose-700 ring-rose-200",
  mixed: "bg-navy/5 text-navy/70 ring-navy/10",
};

export default async function TravelerCityPage(
  props: PageProps<"/learn/[language]/travel/[city]">,
) {
  const { language: langSlug, city: citySlug } = await props.params;
  if (!SUPPORTED_LANGS.has(langSlug)) notFound();

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const data = await getTravelerCourseByCitySlug(langSlug, citySlug);
  if (!data) notFound();
  const { course, lessons } = data;

  const isPremium = await isCurrentUserPremium();

  const completedCount = lessons.filter((l) => l.completed).length;
  const totalCount = lessons.length;
  const progressPct = totalCount === 0 ? 0 : Math.round((completedCount / totalCount) * 100);

  return (
    <>
      <Navbar />
      <main className="flex-1">
        {/* Hero */}
        <section className="relative">
          <div className="relative w-full h-64 sm:h-80 lg:h-[420px] bg-navy">
            {course.coverImageUrl && (
              <Image
                src={course.coverImageUrl}
                alt={`${course.city}, ${course.country}`}
                fill
                sizes="100vw"
                className="object-cover"
                priority
              />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/25 to-black/10" />
            <div className="absolute inset-x-0 bottom-0">
              <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-6 sm:pb-10">
                <Link
                  href="/"
                  className="inline-flex items-center gap-1.5 text-sm text-white/85 hover:text-white transition-colors mb-4"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
                  </svg>
                  Back to home
                </Link>
                <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/80">
                  {course.country}
                </p>
                <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-white tracking-tight mt-1 drop-shadow-sm">
                  {course.city}
                </h1>
                {course.description && (
                  <p className="text-sm sm:text-base text-white/85 mt-3 max-w-2xl leading-relaxed">
                    {course.description}
                  </p>
                )}
              </div>
            </div>
          </div>
        </section>

        {/* Progress summary */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
          <div className="bg-white border border-border rounded-2xl p-4 sm:p-5 shadow-sm">
            <div className="flex items-center justify-between mb-2">
              <p className="text-xs font-semibold uppercase tracking-wider text-teal-dark">
                Journey progress
              </p>
              <p className="text-xs tabular-nums text-navy/60">
                {completedCount} / {totalCount} · {progressPct}%
              </p>
            </div>
            <div className="w-full h-2 bg-navy/5 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full transition-all duration-500"
                style={{ width: `${progressPct}%` }}
              />
            </div>
            {!isPremium && (
              <p className="mt-3 text-xs text-navy/60">
                Free preview:{" "}
                <span className="font-semibold text-navy">
                  first {course.freePreviewCount} lessons
                </span>
                . Upgrade to Premium for the full trip.
              </p>
            )}
          </div>
        </section>

        {/* Journey timeline */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-10">
          <ol className="relative">
            {/* Left rail */}
            <div className="absolute left-4 sm:left-5 top-2 bottom-2 w-px bg-navy/10" aria-hidden />
            {lessons.map((lesson, i) => {
              const isLast = i === lessons.length - 1;
              const locked = lesson.isPremium && !isPremium;
              return (
                <li
                  key={lesson.id}
                  className={`relative pl-12 sm:pl-14 ${isLast ? "pb-0" : "pb-5"}`}
                >
                  {/* Stop marker */}
                  <span
                    className={`absolute left-0 top-1 flex items-center justify-center w-8 h-8 sm:w-10 sm:h-10 rounded-full text-xs sm:text-sm font-bold shadow-sm ring-4 ring-background ${
                      lesson.completed
                        ? "bg-teal text-white"
                        : locked
                        ? "bg-navy/10 text-navy/40"
                        : "bg-white text-teal-dark border-2 border-teal/30"
                    }`}
                  >
                    {lesson.completed ? (
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    ) : locked ? (
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                      </svg>
                    ) : (
                      lesson.orderIndex
                    )}
                  </span>

                  <TimelineCard
                    lesson={lesson}
                    locked={locked}
                    langSlug={langSlug}
                    citySlug={citySlug}
                  />
                </li>
              );
            })}
          </ol>
        </section>
      </main>
      <Footer />
    </>
  );
}

function TimelineCard({
  lesson,
  locked,
  langSlug,
  citySlug,
}: {
  lesson: TravelerLessonSummary;
  locked: boolean;
  langSlug: string;
  citySlug: string;
}) {
  const typePill = LESSON_TYPE_COLOR[lesson.lessonType];
  const typeLabel = LESSON_TYPE_LABEL[lesson.lessonType];

  const body = (
    <div
      className={`relative bg-white border rounded-xl p-4 sm:p-5 transition-all overflow-hidden ${
        locked
          ? "border-border/60"
          : "border-border hover:border-teal/40 hover:shadow-md"
      }`}
    >
      <div className={locked ? "blur-[1.5px] select-none pointer-events-none" : ""}>
        <div className="flex items-center justify-between gap-3 mb-1.5">
          <span
            className={`inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider ring-1 ${typePill}`}
          >
            {typeLabel}
          </span>
          <span className="text-[10px] font-semibold text-teal-dark bg-teal-light rounded-full px-2 py-0.5">
            +{lesson.xpReward} XP
          </span>
        </div>
        <h3 className="text-base sm:text-lg font-bold text-navy leading-snug">
          {lesson.orderIndex}. {lesson.title}
        </h3>
        <p className="text-xs sm:text-sm text-navy/50 mt-0.5">
          {lesson.locationName}
        </p>
      </div>

      {locked && (
        <div className="absolute inset-0 flex items-center justify-center bg-white/70 backdrop-blur-[2px]">
          <div className="text-center max-w-xs px-4">
            <span className="inline-flex items-center justify-center w-10 h-10 rounded-full bg-amber-100 text-amber-800 mb-2">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </span>
            <p className="text-sm font-semibold text-navy">
              Upgrade to Premium to continue your trip
            </p>
            <Link
              href="/pricing"
              className="mt-3 inline-flex items-center justify-center gap-1.5 px-4 py-2 text-xs font-bold text-white bg-amber-600 rounded-full hover:bg-amber-700 transition-colors"
            >
              See plans
              <svg className="w-3 h-3" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </Link>
          </div>
        </div>
      )}
    </div>
  );

  if (locked) return body;
  return (
    <Link
      href={`/learn/${langSlug}/travel/${citySlug}/${lesson.id}`}
      className="block"
    >
      {body}
    </Link>
  );
}
