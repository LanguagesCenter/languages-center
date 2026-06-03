"use client";

import { useEffect, useState } from "react";

function format(ms: number) {
  const totalSeconds = Math.max(0, Math.ceil(ms / 1000));
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const s = totalSeconds % 60;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

export default function CooldownView({
  cooldownRemainingMs,
  cooldownHours,
}: {
  cooldownRemainingMs: number;
  cooldownHours: number;
}) {
  const [remaining, setRemaining] = useState(cooldownRemainingMs);
  useEffect(() => {
    const t = setInterval(() => setRemaining((r) => Math.max(0, r - 1000)), 1000);
    return () => clearInterval(t);
  }, []);
  return (
    <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pb-12">
      <div className="bg-amber-50 border border-amber-200 rounded-2xl p-5 text-center">
        <p className="text-xs font-semibold uppercase tracking-wider text-amber-800 mb-1">
          Cooldown
        </p>
        <p className="text-3xl font-bold text-amber-900 tabular-nums">
          {format(remaining)}
        </p>
        <p className="text-xs text-amber-700 mt-2">
          You can retake this exam for free once the {cooldownHours}-hour cooldown ends.
        </p>
      </div>
    </section>
  );
}
