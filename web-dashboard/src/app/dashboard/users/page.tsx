"use client";

import { useEffect, useState } from "react";
import { Users, Mail, Phone, Calendar, MoreVertical, Edit2, Trash2, Activity } from "lucide-react";

interface PatientRecord {
  _id: string;
  patient_id: string;
  name: string;
  age: number;
  symptoms: string[];
  diagnosis: string;
}

export default function UserDetailsPage() {
  const [patients, setPatients] = useState<PatientRecord[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const res = await fetch("http://127.0.0.1:8000/patients");
        if (res.ok) {
          const json = await res.json();
          if (json.status === "success") {
            setPatients(json.data.reverse());
          }
        }
      } catch (err) {
        console.error("Failed to fetch patients:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  const adminUsers = [
    {
      id: "USR-1029",
      name: "Dr. Amila Perera",
      role: "Health Official",
      email: "amila.p@health.gov.lk",
      phone: "+94 77 123 4567",
      status: "Active",
      joined: "2023-01-15",
    },
    {
      id: "USR-1030",
      name: "Saman Kumara",
      role: "CHW",
      email: "saman.k@chw.lk",
      phone: "+94 71 987 6543",
      status: "Active",
      joined: "2023-03-22",
    },
  ];

  return (
    <div className="space-y-10">
      
      {/* Admin Users Section */}
      <section>
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold text-white tracking-tight">Staff Management</h2>
            <p className="text-slate-400 text-sm mt-1">Manage Health Officials and CHWs</p>
          </div>
          <button className="px-4 py-2 bg-teal-500 hover:bg-teal-400 text-slate-900 font-semibold rounded-lg shadow-lg shadow-teal-500/20 transition-all">
            + Add Staff
          </button>
        </div>

        <div className="bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl shadow-xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-slate-800/80 border-b border-slate-700/50 text-xs text-slate-300 uppercase">
                <tr>
                  <th className="px-6 py-4">User</th>
                  <th className="px-6 py-4">Role</th>
                  <th className="px-6 py-4">Contact</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-700/50">
                {adminUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-slate-700/30 transition-colors group">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10 bg-slate-700 rounded-full flex items-center justify-center text-teal-400 font-bold border border-slate-600">
                          {user.name.charAt(0)}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-white">{user.name}</div>
                          <div className="text-xs text-slate-400">{user.id}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2.5 py-1 text-xs font-medium rounded-md bg-purple-500/10 text-purple-400 border border-purple-500/20">
                        {user.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex flex-col space-y-1 text-xs text-slate-300">
                        <span>{user.email}</span>
                        <span>{user.phone}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-emerald-500/10 text-emerald-400">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mr-1.5"></span>
                        {user.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right font-medium">
                      <button className="text-slate-400 hover:text-teal-400 transition-colors mr-3"><Edit2 size={16} /></button>
                      <button className="text-slate-400 hover:text-rose-400 transition-colors"><Trash2 size={16} /></button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* Patient Database Section */}
      <section>
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold text-white tracking-tight flex items-center">
              Patient Database 
              {loading && <Activity size={18} className="ml-3 text-teal-400 animate-spin" />}
            </h2>
            <p className="text-slate-400 text-sm mt-1">Live data synced from Mobile App assessments</p>
          </div>
        </div>

        <div className="bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl shadow-xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-slate-800/80 border-b border-slate-700/50 text-xs text-slate-300 uppercase">
                <tr>
                  <th className="px-6 py-4">Patient ID</th>
                  <th className="px-6 py-4">Name / Age</th>
                  <th className="px-6 py-4">Symptoms Logged</th>
                  <th className="px-6 py-4">Predicted Diagnosis</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-700/50">
                {patients.map((p) => (
                  <tr key={p._id} className="hover:bg-slate-700/30 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap text-slate-300 font-mono text-xs">
                      {p.patient_id}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-white">{p.name || "Unknown"}</div>
                      <div className="text-xs text-slate-400">{p.age} years old</div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex flex-wrap gap-1 max-w-xs">
                        {p.symptoms?.map((sym, idx) => (
                          <span key={idx} className="px-2 py-0.5 bg-slate-700 text-slate-300 rounded text-[10px] uppercase">
                            {sym}
                          </span>
                        )) || <span className="text-slate-500 italic">None</span>}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2.5 py-1 text-xs font-medium rounded-md ${
                        p.diagnosis?.toLowerCase().includes("dengue") 
                          ? "bg-rose-500/10 text-rose-400 border border-rose-500/20" 
                          : "bg-teal-500/10 text-teal-400 border border-teal-500/20"
                      }`}>
                        {p.diagnosis || "Pending"}
                      </span>
                    </td>
                  </tr>
                ))}
                {patients.length === 0 && !loading && (
                  <tr>
                    <td colSpan={4} className="px-6 py-10 text-center text-slate-500">
                      No patients synced to the backend yet. Use the Flutter app to submit an assessment.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </section>

    </div>
  );
}
