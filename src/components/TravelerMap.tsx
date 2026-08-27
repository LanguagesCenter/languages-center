"use client";

import { useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";

export interface TravelerMapCity {
  city: string;
  country: string;
  slug: string;
  coords: [number, number]; // [lng, lat]
}

interface Props {
  language: "spanish" | "french";
  cities: TravelerMapCity[];
  highlightCountryCodes: string[]; // ISO 3166-1 alpha-2
  baseHref: string; // e.g. "/learn/spanish/travel" — dot clicks navigate to `${baseHref}/${slug}`
}

// Default map center and zoom per language. These are the AUTHORITATIVE
// initial view — no auto-fitBounds runs after load, so what you set
// here is what the user sees on first render.
//
// Coordinates are [longitude, latitude] (Mapbox convention).
//   Spanish [-50, 20] @ zoom 2 shows Mexico City through Barcelona and
//   Buenos Aires all in-view without panning.
//   French [10, 45] @ zoom 3 frames Paris + Lyon. See note below re:
//   Montreal being off-screen at this default.
const DEFAULT_CENTER: Record<Props["language"], [number, number]> = {
  spanish: [-50, 20],
  french:  [10, 45],
};

const DEFAULT_ZOOM: Record<Props["language"], number> = {
  spanish: 2,
  french:  3,
};

export default function TravelerMap({
  language,
  cities,
  highlightCountryCodes,
  baseHref,
}: Props) {
  const container = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<mapboxgl.Map | null>(null);
  const router = useRouter();

  useEffect(() => {
    if (!container.current) return;
    const token = process.env.NEXT_PUBLIC_MAPBOX_TOKEN;
    if (!token) {
      // Fail loud in dev, silent in prod — either way the container gets
      // a fallback so the page doesn't blow up.
      console.error("NEXT_PUBLIC_MAPBOX_TOKEN is not set");
      return;
    }
    mapboxgl.accessToken = token;

    const map = new mapboxgl.Map({
      container: container.current,
      style: "mapbox://styles/mapbox/light-v11",
      center: DEFAULT_CENTER[language],
      zoom: DEFAULT_ZOOM[language],
      projection: "mercator",
      cooperativeGestures: true, // don't hijack page scroll on trackpads
    });
    mapRef.current = map;

    map.addControl(new mapboxgl.NavigationControl({ showCompass: false }), "top-right");

    map.on("load", () => {
      // Highlight target-language countries via Mapbox's boundaries
      // tileset. `iso_3166_1` is the ISO alpha-2 code on each feature.
      map.addSource("countries", {
        type: "vector",
        url: "mapbox://mapbox.country-boundaries-v1",
      });
      map.addLayer(
        {
          id: "country-highlight-fill",
          source: "countries",
          "source-layer": "country_boundaries",
          type: "fill",
          filter: ["in", "iso_3166_1", ...highlightCountryCodes],
          paint: {
            "fill-color": "#2a7d6e",
            "fill-opacity": 0.18,
          },
        },
        // Insert below labels so country names stay readable.
        firstSymbolLayerId(map),
      );
      map.addLayer(
        {
          id: "country-highlight-line",
          source: "countries",
          "source-layer": "country_boundaries",
          type: "line",
          filter: ["in", "iso_3166_1", ...highlightCountryCodes],
          paint: {
            "line-color": "#1d6050",
            "line-width": 0.75,
            "line-opacity": 0.6,
          },
        },
        firstSymbolLayerId(map),
      );

      // City markers — one per course. The marker element is sized
      // EXACTLY to the dot (16×16) so `anchor: "center"` places the
      // dot's geometric center precisely on the coordinate. The label
      // is absolutely-positioned outside the button's bounding box; it
      // still triggers the click via event bubbling because it remains
      // a DOM child of the button.
      for (const c of cities) {
        const el = document.createElement("button");
        el.type = "button";
        el.setAttribute("aria-label", `Open ${c.city} traveler course`);
        el.className = "traveler-map-marker";
        el.innerHTML = `
          <span class="traveler-map-marker__dot"></span>
          <span class="traveler-map-marker__label">${escapeHtml(c.city)}</span>
        `;
        el.addEventListener("click", (e) => {
          e.stopPropagation();
          router.push(`${baseHref}/${c.slug}`);
        });
        new mapboxgl.Marker({ element: el, anchor: "center" })
          .setLngLat(c.coords)
          .addTo(map);
      }

      // (Intentionally no fitBounds call — the DEFAULT_CENTER / DEFAULT_ZOOM
      // per language are the authoritative initial view. If you want the
      // map to auto-frame the actual city list later, re-introduce
      // map.fitBounds(bounds, {...}) here.)
    });

    return () => {
      map.remove();
      mapRef.current = null;
    };
  }, [language, cities, highlightCountryCodes, baseHref, router]);

  return (
    <>
      <div
        ref={container}
        className="w-full h-[380px] sm:h-[460px] lg:h-[520px] rounded-2xl overflow-hidden border border-border shadow-sm"
      />
      {/* Marker styles — Tailwind can't reach into the imperatively-created
          Mapbox marker DOM, so inline what we need. Layout note: the
          button element is sized EXACTLY to the dot (16×16, box-sizing:
          border-box) so mapboxgl.Marker({anchor: "center"}) lands the
          dot's center on the coordinate. The label is absolutely
          positioned so it doesn't shift the button's bounding box. */}
      <style jsx global>{`
        .traveler-map-marker {
          position: relative;
          display: block;
          width: 16px;
          height: 16px;
          padding: 0;
          border: none;
          background: transparent;
          cursor: pointer;
          box-sizing: border-box;
          transition: transform 160ms ease-out;
        }
        .traveler-map-marker:hover {
          transform: scale(1.15);
        }
        .traveler-map-marker__dot {
          position: absolute;
          inset: 0;
          border-radius: 999px;
          background: #f97316; /* orange-500 */
          border: 3px solid #ffffff;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.35), 0 0 0 1px rgba(0, 0, 0, 0.05);
          box-sizing: border-box;
        }
        .traveler-map-marker__label {
          position: absolute;
          left: calc(100% + 8px);
          top: 50%;
          transform: translateY(-50%);
          font-size: 12px;
          font-weight: 700;
          color: #1e293b;
          background: rgba(255, 255, 255, 0.96);
          padding: 3px 8px;
          border-radius: 999px;
          box-shadow: 0 1px 3px rgba(0, 0, 0, 0.14);
          white-space: nowrap;
          letter-spacing: -0.01em;
          pointer-events: auto;
        }
      `}</style>
    </>
  );
}

// Mapbox styles have a mix of fill / line / symbol layers. We want our
// highlight fills to sit UNDER the country-name labels; this helper
// finds the first symbol layer's id so we can insert before it.
function firstSymbolLayerId(map: mapboxgl.Map): string | undefined {
  const layers = map.getStyle()?.layers ?? [];
  for (const l of layers) {
    if (l.type === "symbol") return l.id;
  }
  return undefined;
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}
