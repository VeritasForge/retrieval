import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Flame } from "lucide-react";

export function StreakCard({ current }: { current: number }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">스트릭</CardTitle>
      </CardHeader>
      <CardContent className="flex items-center gap-3">
        <Flame className="h-8 w-8 text-orange-500" />
        <div>
          <p className="text-3xl font-bold">{current}일</p>
          <p className="text-sm text-muted-foreground">연속 복습</p>
        </div>
      </CardContent>
    </Card>
  );
}
