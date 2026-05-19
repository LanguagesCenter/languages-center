"use client";

import { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import Image from "next/image";

export default function CheckoutSuccessPage() {
  const searchParams = useSearchParams();
  const sessionId = searchParams.get("session_id");
  const [status, setStatus] = useState<"loading" | "success" | "error">("loading");

  useEffect(() => {
    if (!sessionId) {
      setStatus("error");
      return;
    }

    fetch("/api/checkout/verify", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ session_id: sessionId }),
    })
      .then((res) => {
        if (res.ok) {
          setStatus("success");
        } else {
          setStatus("error");
        }
      })
      .catch(() => setStatus("error"));
  }, [sessionId]);

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
        <div className="text-center max-w-sm">
          {status === "loading" && (
            <>
              <div className="w-12 h-12 rounded-full bg-peach-light flex items-center justify-center mx-auto mb-4 animate-pulse">
                <svg className="w-6 h-6 text-peach-dark" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                </svg>
              </div>
              <h1 className="text-2xl font-bold text-navy mb-2">Confirming your payment...</h1>
              <p className="text-sm text-navy/50">This will only take a moment.</p>
            </>
          )}

          {status === "success" && (
            <>
              <div className="w-12 h-12 rounded-full bg-teal-light flex items-center justify-center mx-auto mb-4">
                <svg className="w-6 h-6 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                </svg>
              </div>
              <h1 className="text-2xl font-bold text-navy mb-2">Welcome to Premium!</h1>
              <p className="text-sm text-navy/50 mb-6">
                Your subscription is active. You now have full access to all lessons and content.
              </p>
              <Link
                href="/"
                className="inline-block px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
              >
                Start learning
              </Link>
            </>
          )}

          {status === "error" && (
            <>
              <div className="w-12 h-12 rounded-full bg-red-50 flex items-center justify-center mx-auto mb-4">
                <svg className="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </div>
              <h1 className="text-2xl font-bold text-navy mb-2">Something went wrong</h1>
              <p className="text-sm text-navy/50 mb-6">
                We couldn&apos;t verify your payment. Please contact support if you were charged.
              </p>
              <Link
                href="/pricing"
                className="inline-block px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
              >
                Back to pricing
              </Link>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
