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

      // City markers — one per course. The marker element is a PURE
      // 16×16 dot (no children beyond the dot itself) so anchor
      // "center" is unambiguous: the geometric center of the element
      // sits exactly on the [lng, lat] coordinate. City name is
      // rendered as a Mapbox Popup on hover — that keeps the marker
      // element's bounding box guaranteed-square and eliminates any
      // possibility of label DOM affecting positioning.
      for (const c of cities) {
        const el = document.createElement("button");
        el.type = "button";
        el.setAttribute("aria-label", `Open ${c.city} traveler course`);
        el.className = "traveler-map-marker";
        el.addEventListener("click", (e) => {
          e.stopPropagation();
          router.push(`${baseHref}/${c.slug}`);
        });

        new mapboxgl.Marker({ element: el, anchor: "center" })
          .setLngLat(c.coords)
          .addTo(map);

        // Hover popup for the city name — kept independent of the
        // marker's setPopup binding so open/close is symmetric and
        // idempotent (add-to-map on enter, remove on leave).
        const popup = new mapboxgl.Popup({
          closeButton: false,
          closeOnClick: false,
          offset: 14,
          className: "traveler-map-popup",
          anchor: "bottom",
        }).setHTML(`<span>${escapeHtml(c.city)}</span>`);
        el.addEventListener("mouseenter", () => popup.setLngLat(c.coords).addTo(map));
        el.addEventListener("mouseleave", () => popup.remove());
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
      {/* Marker + popup styles — Tailwind can't reach into the
          imperatively-created Mapbox DOM, so inline what we need. The
          marker element is a pure 16×16 orange dot (nothing else in
          the DOM) so anchor "center" is unambiguous. Popup carries
          the city name on hover. */}
      <style jsx global>{`
        .traveler-map-marker {
          display: block;
          width: 16px;
          height: 16px;
          padding: 0;
          margin: 0;
          border: 3px solid #ffffff;
          border-radius: 999px;
          background: #f97316; /* orange-500 */
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.35), 0 0 0 1px rgba(0, 0, 0, 0.05);
          box-sizing: border-box;
          cursor: pointer;
          transition: transform 160ms ease-out;
        }
        .traveler-map-marker:hover {
          transform: scale(1.2);
        }
        .traveler-map-popup .mapboxgl-popup-content {
          padding: 4px 10px;
          border-radius: 999px;
          font-size: 12px;
          font-weight: 700;
          color: #1e293b;
          background: rgba(255, 255, 255, 0.96);
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.18);
          letter-spacing: -0.01em;
        }
        .traveler-map-popup .mapboxgl-popup-tip {
          border-top-color: rgba(255, 255, 255, 0.96);
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
