"use server";

import {
  completeTravelerLesson,
  recordSkippedSpeaking,
} from "@/lib/traveler";

// Client → server bridge for marking a Traveler's Course lesson done
// once the learner finishes the quiz. Returns the XP earned (0 if the
// lesson was already completed on a previous visit).
export async function markLessonComplete(lessonId: number): Promise<number> {
  return completeTravelerLesson(lessonId);
}

// Called when the learner taps "I can't speak now" on any speaking
// exercise in the runner. Persists the skip so the city-level
// Speaking Practice panel can list it later. The translation-check
// payload rides along so the Speaking Practice page can show the
// comprehension follow-up when the learner comes back.
export async function recordSkip(args: {
  lessonId: number;
  exerciseRef: string;
  prompt: string;
  expected: string;
  translationCheck?: {
    options: string[];
    correctIndex: number;
    explanation: string;
  } | null;
}): Promise<void> {
  return recordSkippedSpeaking(args);
}
