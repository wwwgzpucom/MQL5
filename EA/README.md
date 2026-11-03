# EA 策略（分类源码）

适用于 **Exness** 平台（MetaTrader 5）。

开户 / 访问：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

本目录仅含 .mq5 / .mqh 源码，按策略类型分类。

## 分类

| 目录 | EA | 说明 |
|------|----|------|
| `01-均线类` | 3MAF, 2MAAOS | 多均线 + Fractals / Andean |
| `02-MACD类` | 3MACD, 2MACDSTO | 三重/双重 MACD |
| `03-布林带RSI` | BBRSI | 布林带 + RSI |
| `04-Andean振荡` | DHLAOS, AFAOSMD | Daily HighLow / AverageForce + Andean |
| `05-通道与包络` | CEZLSMA, NWERSIASF, LRCUTB | 通道、包络、回归类 |
| `06-COT持仓` | COT1 | COT + SuperTrend |

## 依赖

- `_依赖指标/` — 配套自定义指标
- `_依赖库/` — `Include` 头文件（`.mqh`）

安装：将对应 EA 复制到 MT5 的 `MQL5/Experts/`，指标到 `MQL5/Indicators/`，库到 `MQL5/Include/`，再在 MetaEditor 中编译。

## 版权

`Copyright 2026, wwwgzpucom`

`#property link`：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)