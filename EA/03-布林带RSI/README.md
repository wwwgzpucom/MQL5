# 03-布林带RSI

适用于 **Exness** MT5。开户：[Exness](https://one.toexness.com/intl/zh/a/30852)

本目录为**均值回归 / 波动带**策略：布林带刻画价格通道，RSI 过滤超买超卖。

## 策略一览

| EA | 版本 | 核心逻辑 | 参考回测环境 |
|----|------|----------|--------------|
| `BBRSI.mq5` | 1.6 | **Bollinger Bands** 触及上下轨 + **RSI** 确认反转或延续 | XAUUSD · 5M · 2021.02–2023.09 |

## 使用提示

- 黄金（XAUUSD）波动大，注意止损、手数与隔夜库存费。
- BB 周期默认较长时反应偏慢，可按自己风格调整 `BBLen` 等参数。
- 震荡市表现通常优于单边强趋势市；趋势日请降低仓位或停用。

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)