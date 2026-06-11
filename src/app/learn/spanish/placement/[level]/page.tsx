import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import { isCurrentUserPremium } from "@/lib/learn";
import {
  COOLDOWN_HOURS,
  cooldownRemainingMs,
  getLanguageIdBySlug,
  getLastAttempt,
  buildExamPayload,
  hasPaid,
} from "@/lib/placement-exam";
import ExamClient from "./ExamClient";
import PaywallClient from "./PaywallClient";
import CooldownView from "./CooldownView";
import ResultsView from "./ResultsView";

const LANGUAGE_SLUG = "spanish";
const SUPPORTED_LEVELS = ["A1", "A2"] as const;

export async function generateMetadata(props: {
  params: Promise<{ level: string }>;
}) {
  const { level } = await props.params;
  const upper = level.toUpperCase();
  return {
    title: `Spanish ${upper} Placement Exam — Languages Center`,
  };
}

export default async function PlacementExamPage(props: {
  params: Promise<{ level: string }>;
  searchParams: Promise<{ paid?: string; session_id?: string; show_result?: string }>;
}) {
  const { level: rawLevel } = await props.params;
  const LEVEL = rawLevel.toUpperCase();
  if (!(SUPPORTED_LEVELS as readonly string[]).includes(LEVEL)) {
    notFound();
  }
  const sp = await props.searchParams;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    redirect(`/login?next=/learn/${LANGUAGE_SLUG}/placement/${LEVEL.toLowerCase()}`);
  }

  const languageId = await getLanguageIdBySlug(LANGUAGE_SLUG);
  if (!languageId) {
    redirect("/learn");
  }

  const isPremium = await isCurrentUserPremium();
  const paid = isPremium || (await hasPaid(user.id, languageId, LEVEL));
  const lastAttempt = await getLastAttempt(user.id, languageId, LEVEL);
  const remainingMs = cooldownRemainingMs(lastAttempt);

  // Paywall: not premium and not paid.
  if (!paid) {
    return (
      <>
        <Navbar />
        <main className="flex-1">
          <PaywallClient
            languageSlug={LANGUAGE_SLUG}
            level={LEVEL}
            languageName="Spanish"
            justReturnedFromStripe={sp.paid === "1"}
            sessionId={sp.session_id ?? null}
          />
        </main>
        <Footer />
      </>
    );
  }

  // The user explicitly clicked Retake — clear the result view and load the exam.
  if (sp.show_result === "0" && remainingMs === 0) {
    const payload = await buildExamPayload(languageId, LEVEL);
    if (!payload) {
      return (
        <>
          <Navbar />
          <main className="flex-1 max-w-2xl mx-auto px-4 py-10">
            <p className="text-navy/70">This exam is not available yet.</p>
          </main>
          <Footer />
        </>
      );
    }
    return (
      <>
        <Navbar />
        <main className="flex-1">
          <ExamClient
            languageSlug={LANGUAGE_SLUG}
            level={LEVEL}
            passage={payload.passage}
            questions={payload.questions}
          />
        </main>
        <Footer />
      </>
    );
  }

  // Has a recent attempt → show results (with cooldown if failed).
  if (lastAttempt) {
    return (
      <>
        <Navbar />
        <main className="flex-1">
          <ResultsView
            attempt={lastAttempt}
            languageSlug={LANGUAGE_SLUG}
            level={LEVEL}
            languageName="Spanish"
            cooldownHours={COOLDOWN_HOURS}
            cooldownRemainingMs={remainingMs}
          />
          {remainingMs > 0 && (
            <CooldownView
              cooldownRemainingMs={remainingMs}
              cooldownHours={COOLDOWN_HOURS}
            />
          )}
        </main>
        <Footer />
      </>
    );
  }

  // No prior attempt → load the exam.
  const payload = await buildExamPayload(languageId, LEVEL);
  if (!payload) {
    return (
      <>
        <Navbar />
        <main className="flex-1 max-w-2xl mx-auto px-4 py-10">
          <p className="text-navy/70">This exam is not available yet.</p>
        </main>
        <Footer />
      </>
    );
  }
  return (
    <>
      <Navbar />
      <main className="flex-1">
        <ExamClient
          languageSlug={LANGUAGE_SLUG}
          level={LEVEL}
          passage={payload.passage}
          questions={payload.questions}
        />
      </main>
      <Footer />
    </>
  );
}
