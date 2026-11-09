import { Suspense } from "react";
import Link from "next/link";
import Image from "next/image";
import ResetPasswordClient from "./ResetPasswordClient";

export const metadata = {
  title: "Reset your password — Languages Center",
};

function VerifyingFallback() {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <div className="p-6 flex items-center gap-3">
        <Link
          href="/"
          aria-label="Languages Center home"
          className="group inline-flex items-center gap-2.5 w-fit -mx-1 px-1 py-1 rounded-lg active:opacity-80 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-teal focus-visible:ring-offset-2"
        >
          <Image
            src="/Logo fianl.jpg"
            alt=""
            width={36}
            height={36}
            className="rounded-lg shrink-0 transition-transform duration-200 group-hover:scale-[1.04] group-focus-visible:scale-[1.04]"
          />
          <span className="relative text-lg font-bold text-navy tracking-tight transition-colors duration-200 group-hover:text-teal group-focus-visible:text-teal after:pointer-events-none after:content-[''] after:absolute after:left-0 after:-bottom-0.5 after:h-[2px] after:w-0 after:bg-teal after:transition-[width] after:duration-200 group-hover:after:w-full group-focus-visible:after:w-full">
            Languages Center
          </span>
        </Link>
      </div>
      <div className="flex-1 flex items-center justify-center px-4 pb-20">
        <div className="w-full max-w-sm text-center">
          <div className="w-10 h-10 rounded-full border-2 border-teal/20 border-t-teal animate-spin mx-auto mb-4" />
          <p className="text-sm text-navy/60">Verifying your reset link…</p>
        </div>
      </div>
    </div>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense fallback={<VerifyingFallback />}>
      <ResetPasswordClient />
    </Suspense>
  );
}
