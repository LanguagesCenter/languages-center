import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import {
  getAttemptReview,
  getAttemptRoleplayReviews,
  getLanguageIdBySlug,
  getLastAttempt,
  type ExamCategory,
  type ReviewItem,
  type ReviewRoleplay,
} from "@/lib/placement-exam";

const LANGUAGE_SLUG = "spanish";
const SUPPORTED_LEVELS = ["A1", "A2", "B1", "B2", "C1"] as const;

const CATEGORY_LABEL: Record<ExamCategory, string> = {
  reading: "Reading",
  vocabulary: "Vocabulary",
  dialogue: "Dialogue",
  listening: "Listening",
  speaking: "Speaking",
  roleplay: "Roleplay",
  writing: "Writing",
};

export async function generateMetadata(props: {
  params: Promise<{ level: string }>;
}) {
  const { level } = await props.params;
  return {
    title: `Spanish ${level.toUpperCase()} — Review questions — Languages Center`,
  };
}

export default async function ReviewPage(props: {
  params: Promise<{ level: string }>;
}) {
  const { level: rawLevel } = await props.params;
  const LEVEL = rawLevel.toUpperCase();
  if (!(SUPPORTED_LEVELS as readonly string[]).includes(LEVEL)) {
    notFound();
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    redirect(`/login?next=/learn/${LANGUAGE_SLUG}/placement/${LEVEL.toLowerCase()}/review`);
  }

  const languageId = await getLanguageIdBySlug(LANGUAGE_SLUG);
  if (!languageId) redirect("/learn");

  const attempt = await getLastAttempt(user.id, languageId, LEVEL);
  if (!attempt) {
    return (
      <>
        <Navbar />
        <main className="flex-1 max-w-2xl mx-auto px-4 py-12 text-center">
          <p className="text-navy/70 mb-4">
            You don&apos;t have any attempts to review yet.
          </p>
          <Link
            href={`/learn/${LANGUAGE_SLUG}/placement/${LEVEL.toLowerCase()}`}
            className="text-teal-dark hover:underline font-semibold"
          >
            Take the {LEVEL} placement exam →
          </Link>
        </main>
        <Footer />
      </>
    );
  }

  const [items, roleplayReviews] = await Promise.all([
    getAttemptReview(attempt.id, user.id),
    getAttemptRoleplayReviews(attempt.id, user.id),
  ]);

  // Group by category for cleaner display.
  const grouped = items.reduce<Record<string, ReviewItem[]>>((acc, item) => {
    (acc[item.category] ??= []).push(item);
    return acc;
  }, {});
  const orderedCats = (
    [
      "reading",
      "vocabulary",
      "dialogue",
      "listening",
      "speaking",
      "writing",
    ] as ExamCategory[]
  ).filter((c) => grouped[c]?.length);

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
          <div className="flex items-center justify-between gap-3 mb-6">
            <div>
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-1">
                Spanish {LEVEL} Placement Exam — Review
              </p>
              <h1 className="text-2xl sm:text-3xl font-bold text-navy">
                {attempt.score_percentage}%{" "}
                <span
                  className={`text-base font-semibold ${
                    attempt.passed ? "text-teal-dark" : "text-amber-700"
                  }`}
                >
                  · {attempt.passed ? "Passed" : "Not passed"}
                </span>
              </h1>
            </div>
            <Link
              href={`/learn/${LANGUAGE_SLUG}/placement/${LEVEL.toLowerCase()}`}
              className="text-sm font-medium text-navy/60 hover:text-navy"
            >
              ← Back to results
            </Link>
          </div>

          {orderedCats.length === 0 && roleplayReviews.length === 0 ? (
            <p className="text-navy/60">
              No per-question detail is available for this attempt.
            </p>
          ) : (
            <div className="space-y-8">
              {orderedCats.map((cat) => (
                <section key={cat}>
                  <h2 className="text-sm font-semibold text-navy/60 uppercase tracking-wider mb-3">
                    {CATEGORY_LABEL[cat]}
                  </h2>
                  <div className="space-y-3">
                    {grouped[cat].map((item, i) => (
                      <ReviewCard key={item.id} item={item} index={i + 1} />
                    ))}
                  </div>
                </section>
              ))}
              {roleplayReviews.length > 0 && (
                <section>
                  <h2 className="text-sm font-semibold text-navy/60 uppercase tracking-wider mb-3">
                    Roleplays
                  </h2>
                  <div className="space-y-3">
                    {roleplayReviews.map((rp, i) => (
                      <RoleplayCard key={rp.id} rp={rp} index={i + 1} />
                    ))}
                  </div>
                </section>
              )}
            </div>
          )}
        </section>
      </main>
      <Footer />
    </>
  );
}

function RoleplayCard({
  rp,
  index,
}: {
  rp: ReviewRoleplay;
  index: number;
}) {
  const good = rp.score >= 7;
  const borderClass = good
    ? "border-teal/40 bg-teal-light/40"
    : "border-amber-300 bg-amber-50/40";
  return (
    <div className={`border-2 rounded-2xl p-5 ${borderClass}`}>
      <div className="flex items-start justify-between gap-3 mb-2">
        <p className="text-xs font-semibold text-navy/50 uppercase tracking-wider">
          Roleplay {index} — {rp.topic_label}
        </p>
        <span
          className={`text-xs font-bold px-2 py-0.5 rounded-full ${
            good ? "bg-teal text-white" : "bg-amber-600 text-white"
          }`}
        >
          {rp.score}/10
        </span>
      </div>
      <p className="text-xs text-navy/60 mb-3">
        You played <span className="font-semibold">{rp.user_role}</span> ·
        AI played <span className="font-semibold">{rp.ai_role}</span>
      </p>
      <div className="bg-white/70 rounded-lg p-3 border border-navy/10 space-y-2 max-h-80 overflow-y-auto">
        {rp.transcript.map((turn, i) => (
          <div key={i} className="text-sm">
            <span className="text-[10px] uppercase tracking-wider text-navy/40 mr-2">
              {turn.role === "user" ? rp.user_role : rp.ai_role}:
            </span>
            <span className="text-navy whitespace-pre-wrap">{turn.text}</span>
          </div>
        ))}
      </div>
      {rp.feedback && (
        <div className="mt-3">
          <p className="text-xs text-navy/50 uppercase tracking-wider mb-0.5">
            Feedback
          </p>
          <p className="text-sm text-navy/80 italic">{rp.feedback}</p>
        </div>
      )}
    </div>
  );
}

function ReviewCard({ item, index }: { item: ReviewItem; index: number }) {
  const isMC = item.category === "vocabulary" || item.category === "reading";
  const correct = isMC ? item.score === 10 : item.score >= 7;
  // Border colour cues correctness at a glance.
  const borderClass = correct
    ? "border-teal/40 bg-teal-light/40"
    : "border-amber-300 bg-amber-50/40";

  return (
    <div className={`border-2 rounded-2xl p-5 ${borderClass}`}>
      <div className="flex items-start justify-between gap-3 mb-2">
        <p className="text-xs font-semibold text-navy/50 uppercase tracking-wider">
          Q{index}
        </p>
        <span
          className={`text-xs font-bold px-2 py-0.5 rounded-full ${
            correct
              ? "bg-teal text-white"
              : "bg-amber-600 text-white"
          }`}
        >
          {item.score}/10
        </span>
      </div>

      {item.context && (
        <pre className="text-sm text-navy/70 mb-2 whitespace-pre-wrap font-sans bg-white/60 rounded-lg p-3 border border-navy/10">
          {item.context}
        </pre>
      )}

      <p className="text-navy font-semibold mb-3">{item.prompt}</p>

      <div className="space-y-2 text-sm">
        <div>
          <p className="text-xs text-navy/50 uppercase tracking-wider mb-0.5">
            Your answer
          </p>
          <p className="text-navy whitespace-pre-wrap">
            {item.user_response || (
              <span className="italic text-navy/40">(no answer)</span>
            )}
          </p>
        </div>
        {item.correct_answer && !correct && (
          <div>
            <p className="text-xs text-navy/50 uppercase tracking-wider mb-0.5">
              Expected
            </p>
            <p className="text-navy">{item.correct_answer}</p>
          </div>
        )}
        {item.feedback && (
          <div>
            <p className="text-xs text-navy/50 uppercase tracking-wider mb-0.5">
              Feedback
            </p>
            <p className="text-navy/80 italic">{item.feedback}</p>
          </div>
        )}
      </div>
    </div>
  );
}
