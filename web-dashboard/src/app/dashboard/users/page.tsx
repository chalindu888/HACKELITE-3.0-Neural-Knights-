import { Users, Mail, Phone, Calendar, MoreVertical, Edit2, Trash2 } from "lucide-react";

export default function UserDetailsPage() {
  const users = [
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
    {
      id: "USR-1031",
      name: "Nayani Silva",
      role: "CHW",
      email: "nayani.s@chw.lk",
      phone: "+94 76 555 4444",
      status: "Inactive",
      joined: "2022-11-10",
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">User Management</h2>
          <p className="text-slate-400 text-sm mt-1">Manage Health Officials and Community Health Workers</p>
        </div>
        <button className="px-4 py-2 bg-teal-500 hover:bg-teal-400 text-slate-900 font-semibold rounded-lg shadow-lg shadow-teal-500/20 transition-all">
          + Add New User
        </button>
      </div>

      <div className="bg-slate-800/40 border border-slate-700/50 backdrop-blur-md rounded-2xl shadow-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-800/80 border-b border-slate-700/50">
              <tr>
                <th className="px-6 py-4 text-xs font-semibold text-slate-300 uppercase tracking-wider">User</th>
                <th className="px-6 py-4 text-xs font-semibold text-slate-300 uppercase tracking-wider">Role</th>
                <th className="px-6 py-4 text-xs font-semibold text-slate-300 uppercase tracking-wider">Contact</th>
                <th className="px-6 py-4 text-xs font-semibold text-slate-300 uppercase tracking-wider">Status</th>
                <th className="px-6 py-4 text-xs font-semibold text-slate-300 uppercase tracking-wider">Joined</th>
                <th className="px-6 py-4 text-xs font-semibold text-slate-300 uppercase tracking-wider text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-700/50">
              {users.map((user) => (
                <tr key={user.id} className="hover:bg-slate-700/30 transition-colors group">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10 bg-slate-700 rounded-full flex items-center justify-center text-teal-400 font-bold border border-slate-600 group-hover:border-teal-500/50 transition-colors">
                        {user.name.charAt(0)}
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-white">{user.name}</div>
                        <div className="text-xs text-slate-400">{user.id}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2.5 py-1 text-xs font-medium rounded-md ${
                      user.role === "Health Official" 
                        ? "bg-purple-500/10 text-purple-400 border border-purple-500/20" 
                        : "bg-blue-500/10 text-blue-400 border border-blue-500/20"
                    }`}>
                      {user.role}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex flex-col space-y-1">
                      <div className="flex items-center text-xs text-slate-300">
                        <Mail size={12} className="mr-1.5 text-slate-500" /> {user.email}
                      </div>
                      <div className="flex items-center text-xs text-slate-300">
                        <Phone size={12} className="mr-1.5 text-slate-500" /> {user.phone}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${
                      user.status === "Active" ? "bg-emerald-500/10 text-emerald-400" : "bg-slate-600/50 text-slate-300"
                    }`}>
                      {user.status === "Active" && <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mr-1.5"></span>}
                      {user.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-300">
                    <div className="flex items-center">
                      <Calendar size={14} className="mr-1.5 text-slate-500" />
                      {user.joined}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button className="text-slate-400 hover:text-teal-400 transition-colors mr-3">
                      <Edit2 size={16} />
                    </button>
                    <button className="text-slate-400 hover:text-rose-400 transition-colors">
                      <Trash2 size={16} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
