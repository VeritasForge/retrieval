"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { useUiStore } from "@/stores/ui-store";
import { ThemeToggle } from "./theme-toggle";
import { Home, BarChart3, FolderOpen, Layers, Settings, PanelLeftClose, PanelLeft } from "lucide-react";
import { Button } from "@/components/ui/button";

const NAV_ITEMS = [
  { href: "/", label: "대시보드", icon: Home },
  { href: "/statistics", label: "통계", icon: BarChart3 },
  { href: "/categories", label: "카테고리", icon: FolderOpen },
  { href: "/strategies", label: "전략", icon: Layers },
  { href: "/settings", label: "설정", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const { sidebarCollapsed, toggleSidebar } = useUiStore();

  return (
    <aside className={cn(
      "hidden md:flex flex-col border-r bg-background h-screen sticky top-0 transition-all",
      sidebarCollapsed ? "w-16" : "w-56"
    )}>
      <div className="flex items-center justify-between p-4">
        {!sidebarCollapsed && <span className="text-lg font-semibold">Retrieval</span>}
        <Button variant="ghost" size="icon" onClick={toggleSidebar}>
          {sidebarCollapsed ? <PanelLeft className="h-4 w-4" /> : <PanelLeftClose className="h-4 w-4" />}
        </Button>
      </div>
      <nav className="flex-1 space-y-1 px-2">
        {NAV_ITEMS.map((item) => {
          const isActive = item.href === "/" ? pathname === "/" : pathname.startsWith(item.href);
          return (
            <Link key={item.href} href={item.href} className={cn(
              "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
              isActive ? "bg-accent text-accent-foreground" : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
            )}>
              <item.icon className="h-4 w-4 shrink-0" />
              {!sidebarCollapsed && <span>{item.label}</span>}
            </Link>
          );
        })}
      </nav>
      <div className="p-2">
        <ThemeToggle />
      </div>
    </aside>
  );
}
