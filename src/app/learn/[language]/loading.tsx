import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonLine, SkeletonCard } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <main className="flex-1" aria-busy="true">
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-6">
          <SkeletonLine className="h-8 w-64 max-w-full" />
          <SkeletonLine className="h-4 w-40 mt-2" />
        </section>
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-16 space-y-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <SkeletonCard key={i} className="h-40" />
          ))}
        </section>
      </main>
      <Footer />
    </>
  );
}
