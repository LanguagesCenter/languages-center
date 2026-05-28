"use client";

import { useEffect, useState, type ReactNode } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter, useSearchParams, usePathname } from "next/navigation";
import type { EmailOtpType } from "@supabase/supabase-js";
import { createClient } from "@/lib/supabase/client";
import HomeButton from "@/components/HomeButton";
import { useI18n } from "@/components/I18nProvider";

type Phase = "verifying" | "form" | "submitting" | "invalid";

function Shell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <div className="p-6 flex items-center gap-3">
        <HomeButton />
        <Link href="/" className="flex items-center gap-2.5 w-fit">
          <Image
            src="/Logo fianl.jpg"
            alt="Languages Center logo"
            width={36}
            height={36}
            className="rounded-lg"
          />
          <span className="text-lg font-bold text-navy tracking-tight">
            Languages Center
          </span>
        </Link>
      </div>
      <div className="flex-1 flex items-center justify-center px-4 pb-20">
        <div className="w-full max-w-sm">{children}</div>
      </div>
    </div>
  );
}

export default function ResetPasswordClient() {
  const { t } = useI18n();
  const supabase = createClient();
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const [phase, setPhase] = useState<Phase>("verifying");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    async function verify() {
      const tokenHash = searchParams.get("token_hash");
      const type = (searchParams.get("type") ?? "recovery") as EmailOtpType;

      if (tokenHash) {
        const { error: verifyErr } = await supabase.auth.verifyOtp({
          type,
          token_hash: tokenHash,
        });
        if (!active) return;
        if (verifyErr) {
          setPhase("invalid");
          return;
        }
        // Strip token params off the URL via the Next router so a refresh
        // doesn't replay an already-consumed token.
        router.replace(pathname);
        setPhase("form");
        return;
      }

      // Fall back: if a session is already established (e.g. PKCE
      // ?code auto-exchange from Supabase's default redirect flow), let
      // the user continue straight to the form.
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!active) return;
      setPhase(session ? "form" : "invalid");
    }

    verify();
    return () => {
      active = false;
    };
  }, [supabase, router, pathname, searchParams]);

  const passwordChecks = [
    { label: t("pwd.atLeast8"), met: password.length >= 8 },
    { label: t("pwd.uppercase"), met: /[A-Z]/.test(password) },
    { label: t("pwd.lowercase"), met: /[a-z]/.test(password) },
    { label: t("pwd.number"), met: /[0-9]/.test(password) },
    { label: t("pwd.special"), met: /[!@#$%^&*]/.test(password) },
  ];
  const allChecksMet = passwordChecks.every((c) => c.met);
  const passwordsMatch = confirmPassword.length > 0 && password === confirmPassword;
  const canSubmit = allChecksMet && passwordsMatch;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!canSubmit) return;

    setPhase("submitting");
    setError(null);
    const { error: updateErr } = await supabase.auth.updateUser({ password });
    if (updateErr) {
      setError(updateErr.message);
      setPhase("form");
      return;
    }

    router.push("/?reset=success");
    router.refresh();
  }

  if (phase === "verifying") {
    return (
      <Shell>
        <div className="text-center">
          <div className="w-10 h-10 rounded-full border-2 border-teal/20 border-t-teal animate-spin mx-auto mb-4" />
          <p className="text-sm text-navy/60">{t("reset.verifying")}</p>
        </div>
      </Shell>
    );
  }

  if (phase === "invalid") {
    return (
      <Shell>
        <div className="text-center">
          <div className="w-12 h-12 rounded-full bg-red-50 border border-red-200 flex items-center justify-center mx-auto mb-4">
            <svg
              className="w-6 h-6 text-red-500"
              fill="none"
              stroke="currentColor"
              strokeWidth={1.8}
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-navy mb-2">{t("reset.linkInvalid")}</h1>
          <p className="text-sm text-navy/60 mb-6">
            {t("reset.linkInvalidDesc")}
          </p>
          <Link
            href="/forgot-password"
            className="inline-block px-5 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
          >
            {t("reset.requestNew")}
          </Link>
        </div>
      </Shell>
    );
  }

  return (
    <Shell>
      <h1 className="text-2xl font-bold text-navy text-center mb-2">
        {t("reset.setNewPassword")}
      </h1>
      <p className="text-sm text-navy/50 text-center mb-8">
        {t("reset.chooseStrong")}
      </p>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label
            htmlFor="password"
            className="block text-sm font-medium text-navy/70 mb-1.5"
          >
            {t("reset.newPassword")}
          </label>
          <div className="relative">
            <input
              id="password"
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={8}
              autoComplete="new-password"
              className="w-full px-3.5 py-2.5 pr-10 rounded-xl border border-border bg-white text-navy text-sm placeholder:text-navy/30 focus:outline-none focus:ring-2 focus:ring-teal/30 focus:border-teal transition-colors"
              placeholder={t("reset.placeholderPwd")}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-navy/40 hover:text-navy/70 transition-colors"
              aria-label={showPassword ? "Hide password" : "Show password"}
            >
              {showPassword ? (
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12c1.292 4.338 5.31 7.5 10.066 7.5.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                </svg>
              ) : (
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                </svg>
              )}
            </button>
          </div>

          {password.length > 0 && (
            <ul className="mt-2.5 space-y-1.5">
              {passwordChecks.map((check) => (
                <li key={check.label} className="flex items-center gap-2 text-xs">
                  {check.met ? (
                    <svg className="w-3.5 h-3.5 text-teal shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2.5}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                    </svg>
                  ) : (
                    <svg className="w-3.5 h-3.5 text-red-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2.5}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  )}
                  <span className={check.met ? "text-teal-dark" : "text-navy/50"}>
                    {check.label}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </div>

        <div>
          <label
            htmlFor="confirm-password"
            className="block text-sm font-medium text-navy/70 mb-1.5"
          >
            {t("reset.confirmPassword")}
          </label>
          <input
            id="confirm-password"
            type={showPassword ? "text" : "password"}
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            required
            minLength={8}
            autoComplete="new-password"
            className="w-full px-3.5 py-2.5 rounded-xl border border-border bg-white text-navy text-sm placeholder:text-navy/30 focus:outline-none focus:ring-2 focus:ring-teal/30 focus:border-teal transition-colors"
            placeholder={t("reset.placeholderConfirm")}
          />
          {confirmPassword.length > 0 && !passwordsMatch && (
            <p className="mt-2 text-xs text-red-600">{t("reset.passwordsNoMatch")}</p>
          )}
          {confirmPassword.length > 0 && passwordsMatch && (
            <p className="mt-2 text-xs text-teal-dark">{t("reset.passwordsMatch")}</p>
          )}
        </div>

        {error && (
          <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-3.5 py-2.5">
            {error}
          </div>
        )}

        <button
          type="submit"
          disabled={phase === "submitting" || !canSubmit}
          className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {phase === "submitting" ? t("reset.updating") : t("reset.button")}
        </button>
      </form>
    </Shell>
  );
}
