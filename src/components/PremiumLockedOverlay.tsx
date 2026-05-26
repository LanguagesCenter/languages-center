import Link from "next/link";

export default function PremiumLockedOverlay({ href = "/pricing" }: { href?: string }) {
  return (
    <div className="absolute inset-0 z-10 backdrop-blur-md bg-white/50 rounded-2xl flex items-center justify-center p-4">
      <div className="bg-white/95 border border-border rounded-2xl shadow-lg p-5 max-w-xs w-full text-center">
        <div className="w-10 h-10 mx-auto mb-3 rounded-full bg-peach-light flex items-center justify-center">
          <svg
            className="w-5 h-5 text-amber-700"
            fill="none"
            stroke="currentColor"
            strokeWidth={2}
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"
            />
          </svg>
        </div>
        <p className="text-sm font-semibold text-navy mb-1">Premium content</p>
        <p className="text-xs text-navy/60 mb-4 leading-relaxed">
          Unlock podcasts, videos and more with a Languages Center subscription.
        </p>
        <Link
          href={href}
          className="inline-block w-full py-2 text-xs font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
        >
          Upgrade to Premium
        </Link>
      </div>
    </div>
  );
}
