import { formatDate, today } from "@/lib/utils";

export function DashboardHeader() {
  return (
    <div className="flex items-center justify-between mb-6">
      <h1 className="text-2xl font-bold">Garden</h1>
      <span className="text-muted-foreground">{formatDate(today())}</span>
    </div>
  );
}
