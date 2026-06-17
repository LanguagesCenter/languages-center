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
import ExamClient from "../../../spanish/placement/[level]/ExamClient";
import PaywallClient from "../../../spanish/placement/[level]/PaywallClient";
import CooldownView from "../../../spanish/placement/[level]/CooldownView";
import ResultsView from "../../../spanish/placement/[level]/ResultsView";

const LANGUAGE_SLUG = "french";
const LANGUAGE_NAME = "French";
const LOCALE_CODE = "fr-FR";
const SUPPORTED_LEVELS = ["A1", "A2", "B1", "B2", "C1"] as const;

export async function generateMetadata(props: {
  params: Promise<{ level: string }>;
}) {
  const { level } = await props.params;
  const upper = level.toUpperCase();
  return {
    title: `French ${upper} Placement Exam — Languages Center`,
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

  if (!paid) {
    return (
      <>
        <Navbar />
        <main className="flex-1">
          <PaywallClient
            languageSlug={LANGUAGE_SLUG}
            level={LEVEL}
            languageName={LANGUAGE_NAME}
            justReturnedFromStripe={sp.paid === "1"}
            sessionId={sp.session_id ?? null}
          />
        </main>
        <Footer />
      </>
    );
  }

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
            languageName={LANGUAGE_NAME}
            localeCode={LOCALE_CODE}
            level={LEVEL}
            passage={payload.passage}
            questions={payload.questions}
            roleplays={payload.roleplays}
          />
        </main>
        <Footer />
      </>
    );
  }

  if (lastAttempt) {
    return (
      <>
        <Navbar />
        <main className="flex-1">
          <ResultsView
            attempt={lastAttempt}
            languageSlug={LANGUAGE_SLUG}
            level={LEVEL}
            languageName={LANGUAGE_NAME}
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
          languageName={LANGUAGE_NAME}
          localeCode={LOCALE_CODE}
          level={LEVEL}
          passage={payload.passage}
          questions={payload.questions}
          roleplays={payload.roleplays}
        />
      </main>
      <Footer />
    </>
  );
}
