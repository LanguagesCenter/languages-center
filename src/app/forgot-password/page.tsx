"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { createClient } from "@/lib/supabase/client";

interface FriendlyError {
  title: string;
  body: string;
  rawMessage: string;
  rawStatus?: number;
  rawCode?: string;
  redirectTo: string;
}

function mapAuthError(
  raw: string,
  status: number | undefined,
  code: string | undefined,
  redirectTo: string,
): FriendlyError {
  const m = raw.toLowerCase();
  const base = { rawMessage: raw, rawStatus: status, rawCode: code, redirectTo };

  if (
    m.includes("rate limit") ||
    m.includes("too many") ||
    m.includes("for security purposes")
  ) {
    return {
      ...base,
      title: "Too many requests",
      body: "You've requested several reset emails in a short time. Wait a few minutes, then try again.",
    };
  }

  if (
    m.includes("sending recovery email") ||
    m.includes("sending email") ||
    m.includes("smtp") ||
    m.includes("email rate limit") ||
    m.includes("error sending")
  ) {
    return {
      ...base,
      title: "Email service unavailable",
      body: "Supabase couldn't deliver the reset email. This almost always means custom SMTP isn't configured (or the default mailer's hourly limit was hit). Check Supabase → Authentication → Emails → SMTP Settings.",
    };
  }

  if (m.includes("invalid") && m.includes("email")) {
    return {
      ...base,
      title: "Check your email address",
      body: "That doesn't look like a valid email. Double-check for typos and try again.",
    };
  }

  if (
    m.includes("redirect") ||
    m.includes("not allowed") ||
    m.includes("invalid url")
  ) {
    return {
      ...base,
      title: "Redirect URL not allowed",
      body: `Supabase rejected the redirect URL. Add ${redirectTo} to Authentication → URL Configuration → Redirect URLs.`,
    };
  }

  if (m.includes("network") || m.includes("failed to fetch")) {
    return {
      ...base,
      title: "Connection problem",
      body: "We couldn't reach the Supabase server. Check your internet connection or that the project URL is correct.",
    };
  }

  return {
    ...base,
    title: "Something went wrong",
    body: raw,
  };
}

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState<FriendlyError | null>(null);
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const supabase = createClient();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    const redirectTo = `${window.location.origin}/reset-password`;

    console.group("[forgot-password] resetPasswordForEmail");
    console.log("email:", email);
    console.log("redirectTo:", redirectTo);
    console.log("NEXT_PUBLIC_SUPABASE_URL:", process.env.NEXT_PUBLIC_SUPABASE_URL);
    console.log(
      "NEXT_PUBLIC_SUPABASE_ANON_KEY (first 12 chars):",
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.slice(0, 12) + "…",
    );

    try {
      const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo,
      });

      console.log("data:", data);
      console.log("error:", error);
      if (error) {
        console.log("error.name:", error.name);
        console.log("error.message:", error.message);
        // AuthApiError extras (may not exist on all error shapes)
        const e = error as unknown as { status?: number; code?: string };
        console.log("error.status:", e.status);
        console.log("error.code:", e.code);
        console.groupEnd();
        setError(mapAuthError(error.message, e.status, e.code, redirectTo));
        return;
      }

      console.groupEnd();
      setSent(true);
    } catch (thrown) {
      console.error("Unexpected thrown error:", thrown);
      console.groupEnd();
      const msg = thrown instanceof Error ? thrown.message : String(thrown);
      setError(mapAuthError(msg, undefined, undefined, redirectTo));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Header */}
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

      {/* Form */}
      <div className="flex-1 flex items-center justify-center px-4 pb-20">
        <div className="w-full max-w-sm">
          {sent ? (
            <div className="text-center">
              <div className="w-12 h-12 rounded-full bg-teal-light flex items-center justify-center mx-auto mb-4">
                <svg className="w-6 h-6 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
                </svg>
              </div>
              <h1 className="text-2xl font-bold text-navy mb-2">Check your email</h1>
              <p className="text-sm text-navy/50 mb-6">
                We sent a password reset link to <span className="font-medium text-navy/70">{email}</span>
              </p>
              <Link
                href="/login"
                className="inline-block text-sm font-medium text-teal hover:text-teal-dark transition-colors"
              >
                Back to sign in
              </Link>
            </div>
          ) : (
            <>
              <h1 className="text-2xl font-bold text-navy text-center mb-2">
                Reset your password
              </h1>
              <p className="text-sm text-navy/50 text-center mb-8">
                Enter your email and we'll send you a link to reset your password.
              </p>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label
                    htmlFor="email"
                    className="block text-sm font-medium text-navy/70 mb-1.5"
                  >
                    Email
                  </label>
                  <input
                    id="email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="w-full px-3.5 py-2.5 rounded-xl border border-border bg-white text-navy text-sm placeholder:text-navy/30 focus:outline-none focus:ring-2 focus:ring-teal/30 focus:border-teal transition-colors"
                    placeholder="you@example.com"
                  />
                </div>

                {error && (
                  <div className="rounded-xl border border-red-200 bg-red-50 px-3.5 py-3 text-sm text-red-700">
                    <p className="font-semibold mb-0.5">{error.title}</p>
                    <p className="text-red-700/90 leading-relaxed">{error.body}</p>

                    <details className="mt-3 group">
                      <summary className="cursor-pointer text-xs font-medium text-red-700/80 hover:text-red-900 select-none">
                        Show technical details
                      </summary>
                      <div className="mt-2 rounded-lg bg-red-100/60 border border-red-200 p-2.5 font-mono text-[11px] leading-relaxed text-red-900/90 space-y-1 break-words">
                        <p>
                          <span className="opacity-60">message:</span>{" "}
                          {error.rawMessage}
                        </p>
                        {error.rawStatus !== undefined && (
                          <p>
                            <span className="opacity-60">status:</span> {error.rawStatus}
                          </p>
                        )}
                        {error.rawCode && (
                          <p>
                            <span className="opacity-60">code:</span> {error.rawCode}
                          </p>
                        )}
                        <p>
                          <span className="opacity-60">redirectTo:</span>{" "}
                          {error.redirectTo}
                        </p>
                        <p className="pt-1 text-red-700/70">
                          Open the browser console (Cmd+Opt+J) for the full response.
                        </p>
                      </div>
                    </details>
                  </div>
                )}

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {loading ? "Sending..." : "Send reset link"}
                </button>
              </form>

              <p className="mt-6 text-sm text-center text-navy/50">
                Remember your password?{" "}
                <Link
                  href="/login"
                  className="font-medium text-teal hover:text-teal-dark transition-colors"
                >
                  Sign in
                </Link>
              </p>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
