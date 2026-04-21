import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";

type CompletionRateProps = { total: number; completed: number };

export function CompletionRate({ total, completed }: CompletionRateProps) {
  const rate = total > 0 ? Math.round((completed / total) * 100) : 0;

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">이번 주 완료율</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-3xl font-bold">{rate}%</p>
        <p className="text-sm text-muted-foreground">
          {completed} / {total}건
        </p>
        <Progress value={rate} className="mt-2" />
      </CardContent>
    </Card>
  );
}
