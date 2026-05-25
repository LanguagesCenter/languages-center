"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Phase = "verifying" | "form" | "submitting" | "success" | "invalid";

export default function ResetPasswordPage() {
  const supabase = createClient();
  const router = useRouter();

  const [phase, setPhase] = useState<Phase>("verifying");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    async function verify() {
      // Read the token directly from the URL — Supabase appends
      // ?token_hash=...&type=recovery (or sets a code/access_token via
      // its default redirect flow). We try them in order.
      const url = new URL(window.location.href);
      const tokenHash = url.searchParams.get("token_hash");
      const type = url.searchParams.get("type") ?? "recovery";

      // Some Supabase flows put credentials in the URL hash. Catch those too.
      const hash = new URLSearchParams(window.location.hash.replace(/^#/, ""));
      const hashAccessToken = hash.get("access_token");
      const hashRefreshToken = hash.get("refresh_token");

      if (tokenHash) {
        const { error: verifyErr } = await supabase.auth.verifyOtp({
          type: type as "recovery",
          token_hash: tokenHash,
        });
        if (!active) return;
        if (verifyErr) {
          setPhase("invalid");
          return;
        }
        // Strip token params from the URL so a refresh doesn't replay them.
        window.history.replaceState({}, "", url.pathname);
        setPhase("form");
        return;
      }

      if (hashAccessToken && hashRefreshToken) {
        const { error: sessionErr } = await supabase.auth.setSession({
          access_token: hashAccessToken,
          refresh_token: hashRefreshToken,
        });
        if (!active) return;
        if (sessionErr) {
          setPhase("invalid");
          return;
        }
        window.history.replaceState({}, "", url.pathname);
        setPhase("form");
        return;
      }

      // Fall back: if a session was already established (e.g. PKCE
      // ?code auto-exchange), let the user continue.
      const { data: { session } } = await supabase.auth.getSession();
      if (!active) return;
      if (session) {
        setPhase("form");
      } else {
        setPhase("invalid");
      }
    }

    verify();
    return () => {
      active = false;
    };
  }, [supabase]);

  const passwordChecks = [
    { label: "At least 8 characters", met: password.length >= 8 },
    { label: "Contains an uppercase letter", met: /[A-Z]/.test(password) },
    { label: "Contains a lowercase letter", met: /[a-z]/.test(password) },
    { label: "Contains a number", met: /[0-9]/.test(password) },
    { label: "Contains a special character (!@#$%^&*)", met: /[!@#$%^&*]/.test(password) },
  ];
  const allChecksMet = passwordChecks.every((c) => c.met);
  const passwordsMatch =
    confirmPassword.length > 0 && password === confirmPassword;
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

    setPhase("success");
    setTimeout(() => {
      router.push("/dashboard");
      router.refresh();
    }, 1500);
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <div className="p-6">
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
        <div className="w-full max-w-sm">
          {phase === "verifying" && (
            <div className="text-center">
              <div className="w-10 h-10 rounded-full border-2 border-teal/20 border-t-teal animate-spin mx-auto mb-4" />
              <p className="text-sm text-navy/60">Verifying your reset link…</p>
            </div>
          )}

          {phase === "invalid" && (
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
              <h1 className="text-2xl font-bold text-navy mb-2">
                Link no longer valid
              </h1>
              <p className="text-sm text-navy/60 mb-6">
                This password reset link is invalid or has expired. Request a new one to continue.
              </p>
              <Link
                href="/forgot-password"
                className="inline-block px-5 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
              >
                Request a new link
              </Link>
            </div>
          )}

          {phase === "success" && (
            <div className="text-center">
              <div className="w-14 h-14 rounded-full bg-teal flex items-center justify-center mx-auto mb-5 shadow-md shadow-teal/30">
                <svg
                  className="w-7 h-7 text-white"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={3}
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <h1 className="text-2xl font-bold text-navy mb-2">
                Password updated
              </h1>
              <p className="text-sm text-navy/60 mb-6">
                Taking you to your dashboard…
              </p>
              <Link
                href="/dashboard"
                className="inline-block text-sm font-medium text-teal hover:text-teal-dark transition-colors"
              >
                Go to dashboard now
              </Link>
            </div>
          )}

          {(phase === "form" || phase === "submitting") && (
            <>
              <h1 className="text-2xl font-bold text-navy text-center mb-2">
                Set a new password
              </h1>
              <p className="text-sm text-navy/50 text-center mb-8">
                Choose a strong password to finish resetting your account.
              </p>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label
                    htmlFor="password"
                    className="block text-sm font-medium text-navy/70 mb-1.5"
                  >
                    New password
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
                      placeholder="At least 8 characters"
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
                    Confirm password
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
                    placeholder="Re-enter your password"
                  />
                  {confirmPassword.length > 0 && !passwordsMatch && (
                    <p className="mt-2 text-xs text-red-600">Passwords don&apos;t match yet.</p>
                  )}
                  {confirmPassword.length > 0 && passwordsMatch && (
                    <p className="mt-2 text-xs text-teal-dark">Passwords match.</p>
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
                  {phase === "submitting" ? "Updating…" : "Reset password"}
                </button>
              </form>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
