"use client";

import { useSession, signOut } from "next-auth/react";
import { useTheme } from "@wrksz/themes/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";

export default function SettingsPage() {
  const { data: session } = useSession();
  const { theme, setTheme } = useTheme();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">설정</h1>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle className="text-lg">프로필</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div>
            <Label className="text-muted-foreground">이름</Label>
            <p className="font-medium">{session?.user?.name ?? "-"}</p>
          </div>
          <div>
            <Label className="text-muted-foreground">이메일</Label>
            <p className="font-medium">{session?.user?.email ?? "-"}</p>
          </div>
        </CardContent>
      </Card>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle className="text-lg">테마</CardTitle>
        </CardHeader>
        <CardContent>
          <Select value={theme} onValueChange={(v) => v && setTheme(v)}>
            <SelectTrigger className="w-48">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="light">라이트</SelectItem>
              <SelectItem value="dark">다크</SelectItem>
              <SelectItem value="system">시스템</SelectItem>
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">계정</CardTitle>
        </CardHeader>
        <CardContent>
          <Button variant="destructive" onClick={() => signOut({ callbackUrl: "/login" })}>
            로그아웃
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
