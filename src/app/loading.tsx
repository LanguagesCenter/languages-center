import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { SkeletonPageBody } from "@/components/Skeleton";

export default function Loading() {
  return (
    <>
      <Navbar />
      <SkeletonPageBody cards={4} />
      <Footer />
    </>
  );
}
