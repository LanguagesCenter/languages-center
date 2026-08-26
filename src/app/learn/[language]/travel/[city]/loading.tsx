import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonLine, SkeletonCard } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <main className="flex-1" aria-busy="true">
        <SkeletonLine className="h-64 sm:h-80 lg:h-[420px] w-full rounded-none" />
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
          <SkeletonCard className="h-24" />
        </section>
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <SkeletonCard key={i} className="h-20" />
          ))}
        </section>
      </main>
      <Footer />
    </>
  );
}
