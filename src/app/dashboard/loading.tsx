import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonLine, SkeletonCard } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <main className="flex-1" aria-busy="true">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-6">
          <SkeletonLine className="h-9 w-72 max-w-full" />
          <SkeletonLine className="h-4 w-56 mt-2" />
        </section>
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-8">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <SkeletonCard key={i} className="h-32" />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
