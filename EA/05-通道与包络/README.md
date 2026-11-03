# 05-通道与包络

适用于 **Exness** MT5。开户：[Exness](https://one.toexness.com/intl/zh/a/30852)

本目录为**通道 / 包络 / 回归平滑**类策略：在平滑价格或波动通道上结合趋势退出、RSI 或 UT Bot 信号。

## 策略一览

| EA | 版本 | 核心逻辑 | 参考回测环境 |
|----|------|----------|--------------|
| `CEZLSMA.mq5` | 1.6 | **Heikin Ashi** 上结合 **Chandelier Exit** + **ZLSMA** | AUDUSD · 15M · 2019–2023 |
| `NWERSIASF.mq5` | 1.4 | **Nadaraya-Watson Envelope** + RSI + **ATR Stop Loss Finder** | USDCAD / AUDUSD / EURCHF · 2H · 2019–2023 |
| `LRCUTB.mq5` | 1.4 | **Linear Regression Candles** + **UT Bot Alerts** | AUDCAD · 15M · 2019–2023 |

## 依赖指标

- `ChandelierExit.mq5`、`ZLSMA.mq5`、`ATR_HeikenAshi.mq5`（CEZLSMA）
- `NadarayaWatsonEnvelope.mq5`、`AtrSlFinder.mq5`（NWERSIASF）
- `LinearRegressionCandles.mq5`、`UTBot.mq5`（LRCUTB）

见 `../_依赖指标/`。

## 使用提示

- 通道类策略在趋势行情中更顺；剧烈震荡时注意假突破。
- Heikin Ashi / 回归 K 线会改变“视觉”收盘逻辑，与真实 OHLC 下单仍以服务器报价为准。
- 多品种参数不要直接照搬，务必在 Exness 账户品种规格下回测。

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)