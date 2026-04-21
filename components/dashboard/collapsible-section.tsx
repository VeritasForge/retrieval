"use client";

import { useUiStore } from "@/stores/ui-store";
import { ChevronDown, ChevronRight } from "lucide-react";

type SectionKey = "today" | "completed" | "upcoming" | "overdue";

type CollapsibleSectionProps = {
  title: string;
  count: number;
  sectionKey: SectionKey;
  children: React.ReactNode;
};

export function CollapsibleSection({ title, count, sectionKey, children }: CollapsibleSectionProps) {
  const collapsed = useUiStore((s) => s.collapsedSections[sectionKey]);
  const toggleSection = useUiStore((s) => s.toggleSection);

  return (
    <section className="mb-6">
      <button
        onClick={() => toggleSection(sectionKey)}
        className="flex items-center gap-2 mb-3 w-full text-left"
      >
        {collapsed ? (
          <ChevronRight className="h-4 w-4 text-muted-foreground" />
        ) : (
          <ChevronDown className="h-4 w-4 text-muted-foreground" />
        )}
        <h2 className="text-lg font-semibold">
          {title} ({count})
        </h2>
      </button>
      {!collapsed && children}
    </section>
  );
}
