"use client";

import { useEffect, useState } from "react";
import { useRouter, useParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, Trash2 } from "lucide-react";
import { formatDate } from "@/lib/utils";

type Task = {
  id: string;
  categoryId: string;
  strategyId: string;
  title: string;
  studyDate: string;
  level: number;
  easinessFactor: number;
  interval: number;
  repetitions: number;
  graduated: boolean;
  createdAt: string;
};

export default function TaskDetailPage() {
  const router = useRouter();
  const params = useParams();
  const [task, setTask] = useState<Task | null>(null);

  useEffect(() => {
    fetch(`/api/tasks/${params.id}`)
      .then((res) => res.json())
      .then(setTask);
  }, [params.id]);

  async function handleDelete() {
    if (!confirm("이 태스크를 삭제하시겠습니까?")) return;
    await fetch(`/api/tasks/${params.id}`, { method: "DELETE" });
    router.push("/");
  }

  if (!task) {
    return <div className="animate-pulse">로딩 중...</div>;
  }

  return (
    <div>
      <Button variant="ghost" size="sm" onClick={() => router.back()} className="mb-4">
        <ArrowLeft className="h-4 w-4 mr-1" />
        뒤로
      </Button>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span>{task.title || "태스크 상세"}</span>
            {task.graduated && <Badge className="bg-indigo-500">졸업</Badge>}
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div>
            <Label className="text-muted-foreground">공부한 날</Label>
            <p>{formatDate(task.studyDate)}</p>
          </div>
          <div>
            <Label className="text-muted-foreground">복습 단계</Label>
            <p>Level {task.level}</p>
          </div>
          <div>
            <Label className="text-muted-foreground">EF / 간격 / 반복수</Label>
            <p>
              {task.easinessFactor.toFixed(2)} / {task.interval}일 / {task.repetitions}회
            </p>
          </div>
        </CardContent>
      </Card>

      <Button variant="destructive" onClick={handleDelete}>
        <Trash2 className="h-4 w-4 mr-1" />
        태스크 삭제
      </Button>
    </div>
  );
}
