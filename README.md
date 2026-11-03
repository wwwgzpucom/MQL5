# MQL5

MetaTrader 5（MQL5）相关源码仓库。

## 目录

| 路径 | 说明 |
|------|------|
| [`指标/`](./指标/) | 自定义指标 |

## 指标

### 财经日历

主图信息类指标，展示北京时间当日 USD 相关经济事件。

- [`指标/EconomicCalendar.mq5`](./指标/EconomicCalendar.mq5) — 基础版
- [`指标/EconomicCalendarAdvanced.mq5`](./指标/EconomicCalendarAdvanced.mq5) — 增强版（预期/前值、分色等）

安装与参数说明见 [`指标/README.md`](./指标/README.md)。

## 本地使用

将对应 `.mq5` 复制到 MT5 数据目录下的 `MQL5/Indicators/`，编译后从导航器挂到图表即可。
