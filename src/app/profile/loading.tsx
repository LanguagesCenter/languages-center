import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonLine, SkeletonCard } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <main className="flex-1" aria-busy="true">
        <section className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-6">
          <SkeletonLine className="h-9 w-56" />
          <SkeletonLine className="h-4 w-72 max-w-full mt-2" />
        </section>
        <section className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pb-16 space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <SkeletonCard key={i} className="h-40" />
          ))}
        </section>
      </main>
      <Footer />
    </>
  );
}
