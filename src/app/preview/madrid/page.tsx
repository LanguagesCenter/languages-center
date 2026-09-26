import Link from "next/link";
import { listPreviewLessons } from "@/lib/traveler-preview";

export const metadata = { title: "Madrid Preview · Traveler v2" };

export default function MadridPreviewIndex() {
  const lessons = listPreviewLessons();
  return (
    <main className="min-h-screen bg-background">
      <div className="max-w-2xl mx-auto px-6 py-16 space-y-8">
        <div className="text-center space-y-2">
          <p className="text-[10px] uppercase tracking-[0.3em] font-bold text-teal-dark">
            Traveler v2 · dry-run
          </p>
          <h1 className="text-3xl sm:text-4xl font-black text-navy leading-tight">
            Madrid — new lesson format preview
          </h1>
          <p className="text-sm text-navy/70 max-w-md mx-auto leading-relaxed">
            Two hand-authored lessons in the proposed new shape. No database
            writes. No auth. Meant to preview the format before we regenerate
            all 50 lessons and update the runner in place.
          </p>
        </div>

        <div className="space-y-4">
          {lessons.map((l) => (
            <Link
              key={l.id}
              href={`/preview/madrid/${l.id}`}
              className="block rounded-3xl bg-white border-2 border-border p-6 hover:border-teal hover:shadow-lg transition-all group"
            >
              <div className="flex items-start gap-4">
                <div className="w-14 h-14 rounded-2xl bg-teal-light border-2 border-teal/30 text-teal-dark font-black text-xl flex items-center justify-center shrink-0">
                  {l.orderIndex}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <h2 className="text-lg font-bold text-navy">{l.title}</h2>
                    <span
                      className={`text-[10px] uppercase tracking-wider font-bold px-2 py-0.5 rounded-full ${
                        l.medium === "audio"
                          ? "bg-navy text-white"
                          : "bg-peach text-peach-dark"
                      }`}
                    >
                      {l.medium}
                    </span>
                  </div>
                  <p className="text-sm text-navy/60 mt-0.5">{l.location}</p>
                  <p className="text-sm text-navy/80 mt-3 leading-relaxed">
                    {l.scene}
                  </p>
                  <p className="text-xs text-teal-dark font-semibold mt-3 inline-flex items-center gap-1 group-hover:gap-2 transition-all">
                    Open lesson
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" /></svg>
                  </p>
                </div>
              </div>
            </Link>
          ))}
        </div>

        <div className="rounded-2xl bg-peach-light border border-peach-dark/40 p-5 text-sm text-navy/80 leading-relaxed space-y-2">
          <p className="font-semibold text-navy">Preview notes</p>
          <ul className="list-disc list-inside space-y-1 text-xs">
            <li>Audio uses the browser's built-in Spanish TTS (SpeechSynthesis) — quality varies by device. Production will pre-generate ElevenLabs / OpenAI MP3s.</li>
            <li>Speaking exercises use the Web Speech API. iOS Safari support is limited — falls back to an “I said it” button.</li>
            <li>The Continue button on every decode step is disabled until you answer the mini-exercise correctly.</li>
            <li>Nothing is written to Supabase. XP shown at the end is calculated locally.</li>
          </ul>
        </div>
      </div>
    </main>
  );
}
