import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "flagcdn.com" },
      { protocol: "https", hostname: "images.unsplash.com" },
      // source.unsplash.com is the random-image redirector; it 302s to
      // an images.unsplash.com URL. Kept separate from images.unsplash.com
      // so next/image will accept src="https://source.unsplash.com/…"
      // as-is (the Lyon cover uses this to grab a random Lyon photo).
      { protocol: "https", hostname: "source.unsplash.com" },
    ],
  },
};

export default nextConfig;
