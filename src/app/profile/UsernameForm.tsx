"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { updateUsername } from "@/lib/profile-actions";

export default function UsernameForm({ initial }: { initial: string }) {
  const router = useRouter();
  const [value, setValue] = useState(initial);
  const [status, setStatus] = useState<
    { kind: "idle" } | { kind: "ok" } | { kind: "error"; message: string }
  >({ kind: "idle" });
  const [pending, startTransition] = useTransition();

  const dirty = value.trim() !== initial.trim();

  function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!dirty || pending) return;
    setStatus({ kind: "idle" });
    const fd = new FormData();
    fd.set("full_name", value);
    startTransition(async () => {
      const result = await updateUsername(fd);
      if (result.ok) {
        setStatus({ kind: "ok" });
        router.refresh();
      } else {
        setStatus({ kind: "error", message: result.error ?? "Could not update" });
      }
    });
  }

  return (
    <form onSubmit={onSubmit} className="space-y-3">
      <label className="block">
        <span className="text-xs font-semibold text-navy/60 uppercase tracking-wide">
          Display name
        </span>
        <input
          type="text"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          maxLength={80}
          placeholder="What should we call you?"
          className="mt-1.5 w-full px-4 py-2.5 rounded-xl border-2 border-border bg-white text-navy text-sm focus:border-teal focus:outline-none"
        />
        <p className="text-[11px] text-navy/40 mt-1">
          Shown on your profile and on certificates.
        </p>
      </label>
      <div className="flex items-center gap-3">
        <button
          type="submit"
          disabled={!dirty || pending}
          className="px-4 py-2 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {pending ? "Saving…" : "Save"}
        </button>
        {status.kind === "ok" && (
          <span className="text-xs text-teal-dark font-medium">Saved ✓</span>
        )}
        {status.kind === "error" && (
          <span className="text-xs text-red-600">{status.message}</span>
        )}
      </div>
    </form>
  );
}
