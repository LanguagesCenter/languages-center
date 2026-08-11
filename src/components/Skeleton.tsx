// Tiny building blocks for loading.tsx skeletons. Kept intentionally
// minimal so each route can compose its own layout without pulling in
// an animation library.

export function SkeletonLine({ className = "" }: { className?: string }) {
  return (
    <div
      className={`animate-pulse bg-navy/5 rounded ${className}`}
      aria-hidden
    />
  );
}

export function SkeletonCard({ className = "" }: { className?: string }) {
  return (
    <div
      className={`animate-pulse bg-white border border-border rounded-2xl p-5 ${className}`}
      aria-hidden
    >
      <div className="h-9 w-12 bg-navy/5 rounded-md mb-4" />
      <div className="h-5 w-32 bg-navy/5 rounded mb-3" />
      <div className="h-3 w-24 bg-navy/5 rounded mb-4" />
      <div className="h-2.5 w-full bg-navy/5 rounded-full mb-4" />
      <div className="h-10 w-full bg-navy/10 rounded-xl" />
    </div>
  );
}

export function SkeletonPageBody({ cards = 6 }: { cards?: number }) {
  return (
    <main className="flex-1" aria-busy="true">
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-6">
        <SkeletonLine className="h-8 w-64" />
        <SkeletonLine className="h-4 w-96 mt-3 max-w-full" />
      </section>
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {Array.from({ length: cards }).map((_, i) => (
            <SkeletonCard key={i} />
          ))}
        </div>
      </section>
    </main>
  );
}
