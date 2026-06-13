import Link from "next/link";
import type { PlacementAttempt } from "@/lib/placement-exam-types";

function ScoreBar({ pct }: { pct: number }) {
  // 0% red → 100% green
  const hue = Math.round((pct / 100) * 120);
  return (
    <div className="w-full h-3 rounded-full bg-navy/5 overflow-hidden">
      <div
        className="h-full rounded-full transition-all"
        style={{ width: `${pct}%`, backgroundColor: `hsl(${hue}, 70%, 45%)` }}
      />
    </div>
  );
}

function CategoryRow({ label, pct }: { label: string; pct: number }) {
  return (
    <div className="space-y-1.5">
      <div className="flex items-center justify-between text-sm">
        <span className="text-navy/80 font-medium">{label}</span>
        <span className="text-navy font-bold tabular-nums">{pct}%</span>
      </div>
      <ScoreBar pct={pct} />
    </div>
  );
}

function formatCooldown(ms: number) {
  const totalMinutes = Math.ceil(ms / 60000);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${hours}h ${minutes}m`;
}

export default function ResultsView({
  attempt,
  languageSlug,
  level,
  languageName,
  cooldownHours,
  cooldownRemainingMs,
}: {
  attempt: PlacementAttempt;
  languageSlug: string;
  level: string;
  languageName: string;
  cooldownHours: number;
  cooldownRemainingMs: number;
}) {
  const canRetake = attempt.passed || cooldownRemainingMs === 0;
  const completedAt = new Date(attempt.completed_at);

  return (
    <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-2">
        {languageName} {level} Placement Exam — Results
      </p>
      <h1 className="text-4xl sm:text-5xl font-bold text-navy tracking-tight mb-1">
        {attempt.score_percentage}%
      </h1>
      <p
        className={`text-lg font-semibold mb-6 ${
          attempt.passed ? "text-teal-dark" : "text-amber-700"
        }`}
      >
        {attempt.passed ? "Passed — well done!" : "Not passed — give it another go."}
      </p>

      <div className="mb-8">
        <ScoreBar pct={attempt.score_percentage} />
      </div>

      <div className="bg-white border border-border rounded-2xl p-6 mb-6 space-y-4">
        <h2 className="text-sm font-semibold text-navy/60 uppercase tracking-wider mb-2">
          By category
        </h2>
        <CategoryRow label="Reading" pct={attempt.reading_score} />
        <CategoryRow label="Vocabulary" pct={attempt.vocabulary_score} />
        <CategoryRow label="Dialogue" pct={attempt.dialogue_score} />
        {attempt.listening_score > 0 && (
          <CategoryRow label="Listening" pct={attempt.listening_score} />
        )}
        {attempt.speaking_score > 0 && (
          <CategoryRow label="Speaking" pct={attempt.speaking_score} />
        )}
        {attempt.roleplay_score > 0 && (
          <CategoryRow label="Roleplay" pct={attempt.roleplay_score} />
        )}
        <CategoryRow label="Writing" pct={attempt.writing_score} />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-6 text-sm">
        <div className="bg-white border border-border rounded-xl p-4">
          <p className="text-xs text-navy/40 uppercase tracking-wider mb-1">
            Completed
          </p>
          <p className="text-navy font-semibold">
            {completedAt.toLocaleString()}
          </p>
        </div>
        <div className="bg-white border border-border rounded-xl p-4">
          <p className="text-xs text-navy/40 uppercase tracking-wider mb-1">
            Time taken
          </p>
          <p className="text-navy font-semibold">
            {Math.floor(attempt.time_taken_seconds / 60)}m {attempt.time_taken_seconds % 60}s
          </p>
        </div>
      </div>

      <div className="flex flex-col sm:flex-row gap-3 mb-3">
        {attempt.passed && (
          <Link
            href="/profile"
            className="flex-1 py-3 text-sm font-semibold text-white bg-teal rounded-xl text-center hover:bg-teal-dark transition-colors"
          >
            View certificate
          </Link>
        )}
        {canRetake ? (
          <Link
            href={`/learn/${languageSlug}/placement/${level.toLowerCase()}?show_result=0`}
            className="flex-1 py-3 text-sm font-semibold text-teal-dark bg-white border border-teal rounded-xl text-center hover:bg-teal-light transition-colors"
          >
            Retake exam
          </Link>
        ) : (
          <div className="flex-1 py-3 text-sm font-semibold text-navy/50 bg-navy/5 rounded-xl text-center">
            Retake available in {formatCooldown(cooldownRemainingMs)}
          </div>
        )}
      </div>
      <div className="flex flex-col sm:flex-row gap-3">
        <Link
          href={`/learn/${languageSlug}/placement/${level.toLowerCase()}/review`}
          className="flex-1 py-3 text-sm font-semibold text-teal-dark bg-teal-light rounded-xl text-center hover:bg-teal hover:text-white transition-colors"
        >
          Review questions
        </Link>
        <Link
          href={`/learn/${languageSlug}`}
          className="flex-1 py-3 text-sm font-medium text-navy/60 hover:text-teal text-center"
        >
          Back to course
        </Link>
      </div>

      <p className="mt-6 text-xs text-navy/40 text-center">
        Failing this exam never blocks your progress — A2 is always open to you.
        {!attempt.passed && ` You can retake for free after the ${cooldownHours}h cooldown.`}
      </p>
    </section>
  );
}
