# MQL5

MetaTrader 5（MQL5）相关源码仓库。

## 适用平台

本仓库指标与 EA 适用于 **Exness** 平台（MetaTrader 5）。  
开户 / 访问：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

## 目录

| 路径 | 说明 |
|------|------|
| [`指标/`](./指标/) | 自定义指标（财经日历） |
| [`EA/`](./EA/) | 策略 EA（按类型分类） |

## 指标

- [`指标/EconomicCalendar.mq5`](./指标/EconomicCalendar.mq5) — 基础版
- [`指标/EconomicCalendarAdvanced.mq5`](./指标/EconomicCalendarAdvanced.mq5) — 增强版

详见 [`指标/README.md`](./指标/README.md)。

## EA

分类策略源码见 [`EA/README.md`](./EA/README.md)。

## 本地使用

将 `.mq5` 放到 MT5 对应 `Experts` / `Indicators` / `Include` 目录后编译即可。