"use server";

import { completeSkippedSpeaking } from "@/lib/traveler";

// Called by the Speaking Practice panel when the learner finally
// passes an exercise they previously skipped. Marks the row completed
// so it disappears from the panel + the badge.
export async function markSkipCompleted(rowId: string): Promise<void> {
  return completeSkippedSpeaking(rowId);
}
