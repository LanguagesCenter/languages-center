import { Suspense } from "react";
import Link from "next/link";
import Image from "next/image";
import ResetPasswordClient from "./ResetPasswordClient";
import HomeButton from "@/components/HomeButton";

export const metadata = {
  title: "Reset your password — Languages Center",
};

function VerifyingFallback() {
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
