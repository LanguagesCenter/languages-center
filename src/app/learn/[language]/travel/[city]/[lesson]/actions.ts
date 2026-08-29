"use server";

import { completeTravelerLesson } from "@/lib/traveler";

// Client → server bridge for marking a Traveler's Course lesson done
// once the learner finishes the quiz. Returns the XP earned (0 if the
// lesson was already completed on a previous visit).
export async function markLessonComplete(lessonId: number): Promise<number> {
  return completeTravelerLesson(lessonId);
}
