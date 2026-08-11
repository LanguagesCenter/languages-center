import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonLine, SkeletonCard } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <main className="flex-1" aria-busy="true">
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-14 pb-10">
          <SkeletonLine className="h-4 w-32 mb-6" />
          <SkeletonLine className="h-11 w-16 mb-4 rounded-md" />
          <SkeletonLine className="h-12 w-72 max-w-full mb-3" />
          <SkeletonLine className="h-4 w-56 max-w-full mb-8" />
          <SkeletonLine className="h-12 w-56 rounded-full" />
        </section>
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-14">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
