import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonLine, SkeletonCard } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <main className="flex-1" aria-busy="true">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-6">
          <SkeletonLine className="h-4 w-32 mb-4" />
          <SkeletonLine className="h-10 w-72 max-w-full mb-3" />
          <SkeletonLine className="h-4 w-full max-w-lg" />
        </section>
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-6">
          <SkeletonLine className="h-[380px] sm:h-[460px] lg:h-[520px] w-full rounded-2xl" />
        </section>
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {Array.from({ length: 4 }).map((_, i) => (
              <SkeletonCard key={i} className="h-72" />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
