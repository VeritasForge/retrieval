"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  Cell,
} from "recharts";

export type BarChartItem = Record<string, unknown> & {
  label: string;
  value: number;
};

export type BaseBarChartProps<T extends BarChartItem> = {
  data: T[];
  orientation?: "vertical" | "horizontal";
  height?: number;
  domain?: [number, number];
  colorAccessor?: (item: T) => string;
  tooltipFormatter?: (value: number, item: T) => string;
  valueAxisAllowDecimals?: boolean;
};

const DEFAULT_FILL = "var(--chart-1)";

export function BaseBarChart<T extends BarChartItem>({
  data,
  orientation = "horizontal",
  height = 200,
  domain,
  colorAccessor,
  tooltipFormatter,
  valueAxisAllowDecimals = false,
}: BaseBarChartProps<T>) {
  const isVertical = orientation === "vertical";

  return (
    <ResponsiveContainer width="100%" height={height}>
      <BarChart data={data} layout={isVertical ? "vertical" : "horizontal"}>
        {isVertical ? (
          <>
            <XAxis
              type="number"
              domain={domain ?? ["auto", "auto"]}
              tick={{ fontSize: 12, fill: "var(--muted-foreground)" }}
              allowDecimals={valueAxisAllowDecimals}
            />
            <YAxis
              dataKey="label"
              type="category"
              width={80}
              tick={{ fontSize: 12, fill: "var(--muted-foreground)" }}
            />
          </>
        ) : (
          <>
            <XAxis
              dataKey="label"
              tick={{ fontSize: 12, fill: "var(--muted-foreground)" }}
            />
            <YAxis
              domain={domain ?? ["auto", "auto"]}
              tick={{ fontSize: 12, fill: "var(--muted-foreground)" }}
              allowDecimals={valueAxisAllowDecimals}
            />
          </>
        )}
        <Tooltip
          cursor={{ fill: "var(--muted)", opacity: 0.3 }}
          contentStyle={{
            backgroundColor: "var(--popover)",
            color: "var(--popover-foreground)",
            border: "1px solid var(--border)",
            borderRadius: "6px",
            fontSize: "12px",
          }}
          formatter={(value, _name, payload) =>
            tooltipFormatter
              ? tooltipFormatter(value as number, payload.payload as T)
              : (value as number)
          }
          labelFormatter={(label) => String(label)}
        />
        <Bar
          dataKey="value"
          radius={isVertical ? [0, 4, 4, 0] : [4, 4, 0, 0]}
          fill={DEFAULT_FILL}
        >
          {colorAccessor &&
            data.map((entry, i) => (
              <Cell key={i} fill={colorAccessor(entry)} />
            ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
}
