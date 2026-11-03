import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "flagcdn.com" },
      { protocol: "https", hostname: "images.unsplash.com" },
      // Google Street View Static API — traveler lessons set at named
      // Madrid locations (Gran Vía, Puerta del Sol, Plaza Mayor, El
      // Retiro, Atocha, Barajas) display real Street View captures.
      { protocol: "https", hostname: "maps.googleapis.com" },
      // Supabase Storage — permanent copies of every traveler lesson
      // image live under /storage/v1/object/public/traveler-images/.
      { protocol: "https", hostname: "*.supabase.co" },
    ],
  },
};

export default nextConfig;
