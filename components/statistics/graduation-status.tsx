import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { GraduationCap } from "lucide-react";

type GraduationProps = {
  count: number;
};

export function GraduationStatus({ count }: GraduationProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">졸업 현황</CardTitle>
      </CardHeader>
      <CardContent className="flex items-center gap-3">
        <GraduationCap className="h-8 w-8 text-indigo-500" />
        <div>
          <p className="text-3xl font-bold">{count}개</p>
          <p className="text-sm text-muted-foreground">마스터한 태스크</p>
        </div>
      </CardContent>
    </Card>
  );
}
