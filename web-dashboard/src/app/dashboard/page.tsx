"use client";

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

export default function DashboardOverview() {
  const lineChartData = {
    labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    datasets: [
      {
        fill: true,
        label: "Assessments Conducted",
        data: [65, 59, 80, 81, 56, 55, 40],
        borderColor: "rgb(20, 184, 166)", // teal-500
        backgroundColor: "rgba(20, 184, 166, 0.1)",
        tension: 0.4,
      },
      {
        fill: true,
        label: "Critical Cases Detected",
        data: [28, 48, 40, 19, 86, 27, 90],
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
        <KPICard title="Total Assessments" value="1,248" change="+12%" icon={Activity} color="text-teal-400" bg="bg-teal-500/10" />
        <KPICard title="Critical Triage Cases" value="84" change="+5%" icon={AlertTriangle} color="text-rose-400" bg="bg-rose-500/10" />
        <KPICard title="Active CHWs" value="32" change="Stable" icon={Users} color="text-blue-400" bg="bg-blue-500/10" />
        <KPICard title="Synced Offline Data" value="412" change="+28%" icon={CheckCircle2} color="text-emerald-400" bg="bg-emerald-500/10" />
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

      {/* Recent Activity Table (Mock) */}
      <div className="bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl p-6 shadow-xl">
        <h3 className="text-lg font-semibold mb-4">Recent Critical Cases</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className="text-xs text-slate-400 uppercase bg-slate-800/50">
              <tr>
                <th className="px-4 py-3 rounded-tl-lg">Patient Name</th>
                <th className="px-4 py-3">Location</th>
                <th className="px-4 py-3">Predicted Condition</th>
                <th className="px-4 py-3">Confidence</th>
                <th className="px-4 py-3 rounded-tr-lg">Action Taken</th>
              </tr>
            </thead>
            <tbody>
              <tr className="border-b border-slate-700/50 hover:bg-slate-700/30 transition-colors">
                <td className="px-4 py-3 font-medium">Sunil Perera</td>
                <td className="px-4 py-3 text-slate-400">Colombo 07</td>
                <td className="px-4 py-3 text-rose-400 font-medium">Suspected Dengue</td>
                <td className="px-4 py-3">89%</td>
                <td className="px-4 py-3"><span className="px-2 py-1 bg-teal-500/10 text-teal-400 rounded-md text-xs">Referred to Hospital</span></td>
              </tr>
              <tr className="border-b border-slate-700/50 hover:bg-slate-700/30 transition-colors">
                <td className="px-4 py-3 font-medium">Kamala Silva</td>
                <td className="px-4 py-3 text-slate-400">Kandy</td>
                <td className="px-4 py-3 text-orange-400 font-medium">Leptospirosis</td>
                <td className="px-4 py-3">76%</td>
                <td className="px-4 py-3"><span className="px-2 py-1 bg-teal-500/10 text-teal-400 rounded-md text-xs">Referred to Hospital</span></td>
              </tr>
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
