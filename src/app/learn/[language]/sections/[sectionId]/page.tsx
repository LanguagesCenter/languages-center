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
import { getServerLang, getServerT } from "@/lib/i18n-server";
import {
  getLocalizedLanguageName,
  translateLessonTitle,
  translateSectionTitle,
  translateSectionDescription,
} from "@/lib/i18n";

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
  title,
  completedLabel,
  startLabel,
  reviewLabel,
}: {
  lesson: LessonWithStatus;
  languageSlug: string;
  index: number;
  title: string;
  completedLabel: string;
  startLabel: string;
  reviewLabel: string;
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
            {completedLabel}
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
        {title}
      </h3>
      <p className="text-xs text-navy/50 mb-4 line-clamp-2 leading-relaxed">
        {lesson.description}
      </p>
      <div className="flex items-center justify-between text-xs text-navy/50">
        <span className="capitalize">{lesson.type}</span>
        {!lesson.locked && (
          <span className="inline-flex items-center gap-1 text-teal font-semibold">
            {lesson.completed ? reviewLabel : startLabel}
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

function PremiumPlaceholder({
  kind,
  topic,
}: {
  kind: "video" | "podcast";
  topic: string;
}) {
  const label = kind === "video" ? "Video" : "Podcast";
  const descKind = kind === "video" ? "video" : "podcast episode";
  return (
    <div className="relative rounded-2xl p-5 border border-dashed border-border bg-navy/5 opacity-70 select-none">
      <div className="flex items-center gap-4">
        <div className="shrink-0 w-12 h-12 rounded-full bg-navy/10 flex items-center justify-center text-navy/40">
          {kind === "video" ? (
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          ) : (
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 1a4 4 0 0 0-4 4v7a4 4 0 0 0 8 0V5a4 4 0 0 0-4-4zm7 11a7 7 0 0 1-14 0H3a9 9 0 0 0 8 8.94V23h2v-2.06A9 9 0 0 0 21 12h-2z" />
            </svg>
          )}
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-xs font-semibold text-navy/40 uppercase tracking-wider mb-0.5">
            {label} — Coming soon
          </p>
          <h4 className="text-sm font-semibold text-navy/70 truncate">
            {label}: {topic}
          </h4>
          <p className="text-xs text-navy/40 mt-0.5">
            Premium {descKind} for this topic will be available soon.
          </p>
        </div>
        <div className="shrink-0 text-navy/30" title="Premium subscription required">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
          </svg>
        </div>
      </div>
    </div>
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

  const t = await getServerT();
  const uiLang = await getServerLang();
  const localizedLanguageName = getLocalizedLanguageName(
    language.code,
    uiLang,
    language.name,
  );
  const localizedSectionTitle = translateSectionTitle(section.title, uiLang);
  const localizedSectionDesc = translateSectionDescription(
    section.title,
    section.cefr_level,
    localizedLanguageName,
    uiLang,
  );

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
            {t("section.backToLang", { language: localizedLanguageName })}
          </Link>

          <div className="flex items-start gap-3 mb-3">
            <span
              className={`inline-flex items-center gap-1.5 rounded-full font-semibold px-2.5 py-1 text-xs ${pill} ring-1`}
            >
              {section.cefr_level}
            </span>
            <span className="text-xs text-navy/40">·</span>
            <span className="text-xs text-navy/50">{localizedLanguageName}</span>
          </div>
          <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mb-2">
            {localizedSectionTitle}
          </h1>
          <p className="text-sm text-navy/60 mb-6">{localizedSectionDesc}</p>

          <div className="bg-white border border-border rounded-2xl p-5">
            <div className="flex items-center justify-between mb-2">
              <p className="text-sm text-navy/60">
                {t("section.completeOf", { completed, total })}
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
            <p className="text-sm text-navy/50">{t("section.noLessons")}</p>
          ) : (
            <div className="flex flex-col gap-3">
              {lessons.flatMap((lesson, idx) => {
                const card = (
                  <LessonCard
                    key={`lesson-${lesson.id}`}
                    lesson={lesson}
                    languageSlug={slug}
                    index={idx}
                    title={translateLessonTitle(lesson.title, uiLang)}
                    completedLabel={t("section.completed")}
                    startLabel={t("section.start")}
                    reviewLabel={t("section.review")}
                  />
                );
                // After every lesson except the last, drop in an alternating
                // video/podcast placeholder card. Index 0 → video, 1 → podcast, etc.
                const isLast = idx === lessons.length - 1;
                if (isLast) return [card];
                const kind: "video" | "podcast" = idx % 2 === 0 ? "video" : "podcast";
                return [
                  card,
                  <PremiumPlaceholder
                    key={`gap-${lesson.id}`}
                    kind={kind}
                    topic={localizedSectionTitle}
                  />,
                ];
              })}
            </div>
          )}
        </section>
      </main>
      <Footer />
    </>
  );
}
