import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonLine, SkeletonCard } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <main className="flex-1" aria-busy="true">
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-14 pb-10 text-center">
          <SkeletonLine className="h-9 w-72 max-w-full mx-auto" />
          <SkeletonLine className="h-4 w-96 max-w-full mx-auto mt-3" />
        </section>
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            <SkeletonCard className="h-96" />
            <SkeletonCard className="h-96" />
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
