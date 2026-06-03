import { redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import {
  COOLDOWN_HOURS,
  cooldownRemainingMs,
  getLanguageIdBySlug,
  getLastAttempt,
  getQuestionsForClient,
  hasPaid,
} from "@/lib/placement-exam";
import ExamClient from "./ExamClient";
import PaywallClient from "./PaywallClient";
import CooldownView from "./CooldownView";
import ResultsView from "./ResultsView";

export const metadata = {
  title: "Spanish A1 Placement Exam — Languages Center",
};

const LANGUAGE_SLUG = "spanish";
const LEVEL = "A1";

export default async function PlacementExamPage(props: {
  searchParams: Promise<{ paid?: string; session_id?: string; show_result?: string }>;
}) {
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

  const isPremium = !!user.user_metadata?.is_premium;
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
    const questions = await getQuestionsForClient(languageId, LEVEL);
    return (
      <>
        <Navbar />
        <main className="flex-1">
          <ExamClient
            languageSlug={LANGUAGE_SLUG}
            level={LEVEL}
            questions={questions}
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
  const questions = await getQuestionsForClient(languageId, LEVEL);
  return (
    <>
      <Navbar />
      <main className="flex-1">
        <ExamClient
          languageSlug={LANGUAGE_SLUG}
          level={LEVEL}
          questions={questions}
        />
      </main>
      <Footer />
    </>
  );
}
