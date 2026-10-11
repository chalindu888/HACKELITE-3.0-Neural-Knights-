"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Activity, LayoutDashboard, Map, Users, Settings, LogOut } from "lucide-react";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  const navItems = [
    { name: "Overview", href: "/dashboard", icon: LayoutDashboard },
    { name: "Regional Maps", href: "/dashboard/maps", icon: Map },
    { name: "User Details", href: "/dashboard/users", icon: Users },
    { name: "System Logs", href: "/dashboard/logs", icon: Activity },
  ];

  return (
    <div className="flex h-screen bg-slate-900 text-slate-100 overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-800/50 border-r border-slate-700/50 flex flex-col backdrop-blur-xl">
        <div className="h-16 flex items-center px-6 border-b border-slate-700/50">
          <Activity className="text-teal-400 mr-2" size={24} />
          <span className="font-bold text-lg tracking-tight">MediSense AI</span>
        </div>

        <nav className="flex-1 py-6 px-3 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            const Icon = item.icon;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center px-3 py-2.5 rounded-lg transition-all duration-200 group ${
                  isActive
                    ? "bg-teal-500/10 text-teal-400 font-medium"
                    : "text-slate-400 hover:bg-slate-700/50 hover:text-slate-200"
                }`}
              >
                <Icon
                  size={20}
                  className={`mr-3 transition-colors ${
                    isActive ? "text-teal-400" : "text-slate-500 group-hover:text-slate-300"
                  }`}
                />
                {item.name}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-slate-700/50 space-y-1">
          <Link
            href="#"
            className="flex items-center px-3 py-2.5 rounded-lg text-slate-400 hover:bg-slate-700/50 hover:text-slate-200 transition-all"
          >
            <Settings size={20} className="mr-3 text-slate-500" />
            Settings
          </Link>
          <Link
            href="/login"
            className="flex items-center px-3 py-2.5 rounded-lg text-rose-400 hover:bg-rose-500/10 transition-all"
          >
            <LogOut size={20} className="mr-3" />
            Sign Out
          </Link>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 overflow-y-auto bg-slate-900/50">
        <header className="h-16 flex items-center justify-between px-8 border-b border-slate-700/50 bg-slate-800/30 backdrop-blur-md sticky top-0 z-10">
          <h2 className="font-semibold text-lg capitalize">
            {pathname.split("/").pop() === "dashboard" ? "Overview" : pathname.split("/").pop()}
          </h2>
          <div className="flex items-center space-x-4">
            <div className="text-right">
              <div className="text-sm font-medium">Admin User</div>
              <div className="text-xs text-teal-400">Health Official</div>
            </div>
            <div className="w-10 h-10 rounded-full bg-slate-700 border border-slate-600 flex items-center justify-center">
              <Users size={18} className="text-slate-300" />
            </div>
          </div>
        </header>
        <div className="p-8 max-w-7xl mx-auto">{children}</div>
      </main>
    </div>
  );
}
