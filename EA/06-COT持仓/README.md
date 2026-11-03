# 06-COT持仓

适用于 **Exness** MT5。开户：[Exness](https://one.toexness.com/intl/zh/a/30852)

本目录为**基本面持仓报告 + 趋势过滤**策略：用 CFTC **Commitments of Traders (COT)** 数据判断大户多空偏向，再用 **SuperTrend** 做方向与进出场。

## 策略一览

| EA | 版本 | 核心逻辑 | 参考回测环境 |
|----|------|----------|--------------|
| `COT1.mq5` | 1.2 | COT 持仓结构信号 + SuperTrend 趋势确认 | 多品种 · Daily · 2021.01–2024.01 |

## 依赖

- 指标：`SuperTrend.mq5`（`../_依赖指标/`）
- 库：`Cot.mqh`、`EAUtils.mqh`、`Sql.mqh` 等（`../_依赖库/`）
- COT 数据需按库文件约定的路径准备（默认数据目录名可能仍为历史路径前缀，首次运行请检查 Experts/Files 相关目录）

## 使用提示

- 适合**日线**级别；信号频率低，更偏仓位型而非剥头皮。
- COT 为周度发布数据，信号会滞后于突发事件，需结合风控。
- 不同品种 COT 合约映射不同，换品种前确认 Cot 库配置。

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)