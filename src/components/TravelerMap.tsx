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

// Reasonable default map centers per language so the initial view frames
// most highlighted countries + cities. The map does an automatic fitBounds
// over the passed-in cities so these are just fallbacks for empty lists —
// they're pre-tuned to be visually close to what fitBounds will produce,
// so there's no flash of an unrelated region before the fit lands.
const DEFAULT_CENTER: Record<Props["language"], [number, number]> = {
  spanish: [-48, 5],  // centered between Spain and the Americas
  french:  [-35, 47], // splits Atlantic between Paris and Montreal
};

const DEFAULT_ZOOM: Record<Props["language"], number> = {
  spanish: 1.5,
  french: 2,
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

      // Frame the cities so every dot is comfortably in-view at load.
      // Right padding is extra-wide so the city labels (which extend to
      // the right of each dot) don't get clipped by the map edge.
      if (cities.length >= 2) {
        const bounds = new mapboxgl.LngLatBounds();
        for (const c of cities) bounds.extend(c.coords);
        map.fitBounds(bounds, {
          padding: { top: 80, bottom: 80, left: 80, right: 140 },
          maxZoom: 4.5,
          duration: 0,
          linear: true,
        });
      } else if (cities.length === 1) {
        map.setCenter(cities[0].coords);
        map.setZoom(4);
      }
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
