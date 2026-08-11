"use client";

import { useEffect } from "react";
import { MapContainer, TileLayer, Marker, Popup, Circle } from "react-leaflet";
import L from "leaflet";

// Fix for default marker icons in Leaflet with Next.js
const customIcon = new L.Icon({
  iconUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png",
  iconRetinaUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png",
  shadowUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

export default function MapComponent() {
  const mapCenter: [number, number] = [6.9271, 79.8612]; // Colombo, Sri Lanka

  const hotspots = [
    { id: 1, lat: 6.9271, lng: 79.8612, type: "Dengue", cases: 24, radius: 1500, color: "#f43f5e" },
    { id: 2, lat: 7.2906, lng: 80.6337, type: "Leptospirosis", cases: 12, radius: 1000, color: "#f97316" }, // Kandy
    { id: 3, lat: 6.0535, lng: 80.2210, type: "Viral Flu", cases: 45, radius: 2500, color: "#14b8a6" }, // Galle
  ];

  return (
    <MapContainer center={mapCenter} zoom={7} className="w-full h-full min-h-150 rounded-2xl z-0">
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png" // Dark theme map tiles
      />
      
      {/* City Marker */}
      <Marker position={mapCenter} icon={customIcon}>
        <Popup>
          <div className="font-semibold text-slate-800">Colombo District</div>
          <div className="text-slate-600">Primary Surveillance Zone</div>
        </Popup>
      </Marker>

      {/* Disease Hotspots (Circles) */}
      {hotspots.map((spot) => (
        <Circle
          key={spot.id}
          center={[spot.lat, spot.lng]}
          radius={spot.radius}
          pathOptions={{
            color: spot.color,
            fillColor: spot.color,
            fillOpacity: 0.4,
          }}
        >
          <Popup>
            <div className="font-bold text-slate-800">{spot.type} Hotspot</div>
            <div className="text-slate-600 text-sm">Recent Cases: <span className="font-bold text-rose-500">{spot.cases}</span></div>
          </Popup>
        </Circle>
      ))}
    </MapContainer>
  );
}
