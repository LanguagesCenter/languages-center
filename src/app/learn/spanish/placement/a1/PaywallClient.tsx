"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function PaywallClient({
  languageSlug,
  level,
  languageName,
  justReturnedFromStripe,
  sessionId,
}: {
  languageSlug: string;
  level: string;
  languageName: string;
  justReturnedFromStripe: boolean;
  sessionId: string | null;
}) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [verifying, setVerifying] = useState(justReturnedFromStripe);

  // If the user just returned from Stripe with paid=1 + session_id, verify
  // the payment and then reload so the server page re-checks payment status.
  useEffect(() => {
    if (!justReturnedFromStripe || !sessionId) return;
    fetch("/api/placement-exam/verify", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ session_id: sessionId }),
    })
      .then(async (r) => {
        const body = await r.json().catch(() => ({}));
        if (!r.ok) throw new Error(body?.error ?? "Verification failed");
      })
      .then(() => {
        router.replace(`/learn/${languageSlug}/placement/${level.toLowerCase()}`);
        router.refresh();
      })
      .catch((e: Error) => {
        setError(e.message);
        setVerifying(false);
      });
  }, [justReturnedFromStripe, sessionId, router, languageSlug, level]);

  async function handlePay() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch("/api/placement-exam/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ languageSlug, level }),
      });
      const data = await res.json();
      if (data?.url) {
        window.location.href = data.url;
      } else {
        setError(data?.error ?? "Could not start checkout");
        setLoading(false);
      }
    } catch {
      setError("Network error");
      setLoading(false);
    }
  }

  if (verifying) {
    return (
      <div className="max-w-2xl mx-auto p-6 text-center">
        <p className="text-sm text-navy/60">Verifying your payment…</p>
      </div>
    );
  }

  return (
    <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <h1 className="text-3xl sm:text-4xl font-bold text-navy mb-2 tracking-tight">
        {languageName} {level} Placement Exam
      </h1>
      <p className="text-sm text-navy/60 mb-6">
        45-minute timed test. 40 questions across vocabulary, listening, speaking and writing. Pass
        with 50% or higher.
      </p>

      {/* Locked preview */}
      <div className="relative bg-white border border-border rounded-2xl p-6 overflow-hidden">
        <div className="space-y-3 pointer-events-none select-none blur-sm opacity-60">
          {[
            "How do you say \"Hello\" in Spanish?",
            "Listen: \"Buenos días\"",
            "Say aloud: \"Tengo hambre.\"",
            "Translate to Spanish: \"I am hungry.\"",
          ].map((q, i) => (
            <div key={i} className="rounded-xl border border-border p-4 text-navy/80">
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-1">
                Question {i + 1}
              </p>
              <p className="text-base font-semibold">{q}</p>
              <div className="mt-2 grid grid-cols-2 gap-2">
                <div className="rounded-lg border border-border h-9" />
                <div className="rounded-lg border border-border h-9" />
                <div className="rounded-lg border border-border h-9" />
                <div className="rounded-lg border border-border h-9" />
              </div>
            </div>
          ))}
        </div>
        <div className="absolute inset-0 bg-white/40 flex flex-col items-center justify-center text-center p-6">
          <div className="w-14 h-14 rounded-full bg-navy/10 flex items-center justify-center text-navy/60 mb-4">
            <svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
            </svg>
          </div>
          <p className="text-navy font-bold text-xl">Unlock this exam</p>
          <p className="text-sm text-navy/60 mt-1">Free with Premium · $0.99 one-time</p>
          <p className="text-xs text-navy/50 mt-2 max-w-sm">
            Languages Center Premium subscribers get all placement exams free.
          </p>
        </div>
      </div>

      {error && (
        <div className="mt-4 text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-4 py-3">
          {error}
        </div>
      )}

      <div className="mt-6 flex flex-col gap-3">
        {/* Premium upsell first (primary call to action) */}
        <Link
          href="/pricing"
          className="w-full py-3 text-sm font-semibold text-white bg-teal rounded-xl text-center hover:bg-teal-dark transition-colors"
        >
          Upgrade to Premium — all exams included
        </Link>
        {/* Single-exam fallback below */}
        <button
          type="button"
          onClick={handlePay}
          disabled={loading}
          className="w-full py-3 text-sm font-semibold text-teal-dark bg-white border border-teal rounded-xl hover:bg-teal-light transition-colors disabled:opacity-50"
        >
          {loading ? "Starting checkout…" : "or pay $0.99 to unlock just this exam"}
        </button>
      </div>
      <p className="mt-3 text-xs text-navy/40 text-center">
        Skipping is OK — you can take this exam anytime and it never blocks your progress to A2.
      </p>
    </section>
  );
}
