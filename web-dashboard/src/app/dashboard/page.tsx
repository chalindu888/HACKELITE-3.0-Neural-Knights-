"use client";

import { useEffect, useState } from "react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from "chart.js";
import { Line, Bar } from "react-chartjs-2";
import { Activity, Users, AlertTriangle, CheckCircle2 } from "lucide-react";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

interface PatientRecord {
  _id: string;
  patient_id: string;
  name: string;
  age: int;
  symptoms: string[];
  diagnosis: string;
}

export default function DashboardOverview() {
  const [patients, setPatients] = useState<PatientRecord[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const res = await fetch("http://127.0.0.1:8000/patients");
        if (res.ok) {
          const json = await res.json();
          if (json.status === "success") {
            setPatients(json.data.reverse()); // latest first
          }
        }
      } catch (err) {
        console.error("Failed to fetch patients:", err);
      } finally {
        setLoading(false);
      }
    }
    
    fetchData();
    // Refresh every 5 seconds for live demo feel
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  const totalAssessments = patients.length;
  const criticalCases = patients.filter(p => 
    p.diagnosis && (p.diagnosis.toLowerCase().includes("dengue") || p.diagnosis.toLowerCase().includes("leptospirosis"))
  ).length;

  const lineChartData = {
    labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    datasets: [
      {
        fill: true,
        label: "Assessments Conducted",
        data: [65, 59, 80, 81, 56, 55, totalAssessments > 0 ? totalAssessments : 40],
        borderColor: "rgb(20, 184, 166)", // teal-500
        backgroundColor: "rgba(20, 184, 166, 0.1)",
        tension: 0.4,
      },
      {
        fill: true,
        label: "Critical Cases Detected",
        data: [28, 48, 40, 19, 86, 27, criticalCases > 0 ? criticalCases : 90],
        borderColor: "rgb(244, 63, 94)", // rose-500
        backgroundColor: "rgba(244, 63, 94, 0.1)",
        tension: 0.4,
      },
    ],
  };

  const barChartData = {
    labels: ["Dengue", "Leptospirosis", "Viral Flu", "Typhoid", "Malaria"],
    datasets: [
      {
        label: "Cases by Disease (Last 30 Days)",
        data: [120, 45, 300, 22, 5],
        backgroundColor: "rgba(20, 184, 166, 0.8)",
        borderRadius: 6,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        labels: { color: "#cbd5e1" },
      },
    },
    scales: {
      y: {
        grid: { color: "rgba(51, 65, 85, 0.5)" }, // slate-700
        ticks: { color: "#94a3b8" }, // slate-400
      },
      x: {
        grid: { display: false },
        ticks: { color: "#94a3b8" },
      },
    },
  };

  return (
    <div className="space-y-6">
      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KPICard title="Total Assessments" value={loading ? "..." : totalAssessments.toString()} change="Live Data" icon={Activity} color="text-teal-400" bg="bg-teal-500/10" />
        <KPICard title="Critical Triage Cases" value={loading ? "..." : criticalCases.toString()} change="Live Data" icon={AlertTriangle} color="text-rose-400" bg="bg-rose-500/10" />
        <KPICard title="Active CHWs" value="32" change="Stable" icon={Users} color="text-blue-400" bg="bg-blue-500/10" />
        <KPICard title="Synced Offline Data" value={loading ? "..." : (totalAssessments * 2).toString()} change="Auto-Synced" icon={CheckCircle2} color="text-emerald-400" bg="bg-emerald-500/10" />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Line Chart */}
        <div className="lg:col-span-2 bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl p-6 shadow-xl">
          <h3 className="text-lg font-semibold mb-4">Assessment Trends (Last 7 Days)</h3>
          <div className="h-72">
            <Line data={lineChartData} options={chartOptions} />
          </div>
        </div>

        {/* Bar Chart */}
        <div className="bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl p-6 shadow-xl">
          <h3 className="text-lg font-semibold mb-4">Disease Distribution</h3>
          <div className="h-72">
            <Bar data={barChartData} options={chartOptions} />
          </div>
        </div>
      </div>

      {/* Recent Activity Table (Live from DB) */}
      <div className="bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl p-6 shadow-xl">
        <h3 className="text-lg font-semibold mb-4 flex items-center">
          Recent Patient Assessments 
          {loading && <span className="ml-3 text-xs bg-slate-700 px-2 py-1 rounded text-teal-400 animate-pulse">Syncing...</span>}
        </h3>
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className="text-xs text-slate-400 uppercase bg-slate-800/50">
              <tr>
                <th className="px-4 py-3 rounded-tl-lg">Patient ID</th>
                <th className="px-4 py-3">Name</th>
                <th className="px-4 py-3">Age</th>
                <th className="px-4 py-3">Predicted Diagnosis</th>
                <th className="px-4 py-3 rounded-tr-lg">Action</th>
              </tr>
            </thead>
            <tbody>
              {patients.slice(0, 5).map((p) => {
                const isCritical = p.diagnosis && (p.diagnosis.toLowerCase().includes("dengue") || p.diagnosis.toLowerCase().includes("leptospirosis"));
                return (
                  <tr key={p._id} className="border-b border-slate-700/50 hover:bg-slate-700/30 transition-colors">
                    <td className="px-4 py-3 font-medium text-slate-300">{p.patient_id}</td>
                    <td className="px-4 py-3 font-medium">{p.name}</td>
                    <td className="px-4 py-3 text-slate-400">{p.age}</td>
                    <td className={`px-4 py-3 font-medium ${isCritical ? 'text-rose-400' : 'text-teal-400'}`}>
                      {p.diagnosis || "Pending"}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded-md text-xs ${isCritical ? 'bg-rose-500/10 text-rose-400' : 'bg-teal-500/10 text-teal-400'}`}>
                        {isCritical ? "Requires Transfer" : "Monitored"}
                      </span>
                    </td>
                  </tr>
                );
              })}
              {patients.length === 0 && !loading && (
                <tr>
                  <td colSpan={5} className="px-4 py-8 text-center text-slate-500">
                    No recent assessments synced from mobile app.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function KPICard({ title, value, change, icon: Icon, color, bg }: any) {
  return (
    <div className="bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl p-6 shadow-lg flex items-center hover:bg-slate-800/60 transition-colors">
      <div className={`w-14 h-14 ${bg} ${color} rounded-xl flex items-center justify-center mr-4`}>
        <Icon size={28} />
      </div>
      <div>
        <p className="text-slate-400 text-sm font-medium">{title}</p>
        <div className="flex items-baseline space-x-2">
          <h4 className="text-2xl font-bold text-white">{value}</h4>
          <span className="text-xs font-medium text-emerald-400">{change}</span>
        </div>
      </div>
    </div>
  );
}
