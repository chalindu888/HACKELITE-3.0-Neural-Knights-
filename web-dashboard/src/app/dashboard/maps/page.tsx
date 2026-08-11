"use client";

import { useEffect } from "react";
import dynamic from "next/dynamic";
import "leaflet/dist/leaflet.css";

// Dynamically import the map component with SSR disabled
const MapComponent = dynamic(() => import("./MapComponent"), { ssr: false });

export default function MapsPage() {
  return (
    <div className="space-y-6 h-full flex flex-col">
      <div>
        <h2 className="text-2xl font-bold text-white tracking-tight">Regional Heatmaps</h2>
        <p className="text-slate-400 text-sm mt-1">Geospatial analysis of disease outbreaks and triage hotspots</p>
      </div>

      <div className="flex-1 bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl shadow-xl overflow-hidden min-h-[600px] relative">
        <MapComponent />
      </div>
    </div>
  );
}
