# 02-MACD类

适用于 **Exness** MT5。开户：[Exness](https://one.toexness.com/intl/zh/a/30852)

本目录为 **MACD 多周期/多组** 策略：用多套 MACD（可加 Stochastic）做动量与背离过滤，偏短线。

## 策略一览

| EA | 版本 | 核心逻辑 | 参考回测环境 |
|----|------|----------|--------------|
| `3MACD.mq5` | 1.4 | 三组 MACD 共振，偏**剥头皮** | AUDUSD · 5M · 2021.02–2023.09 |
| `2MACDSTO.mq5` | 1.4 | 两组 MACD + **Stochastic** 超买超卖过滤 | NZDUSD · 3H · 2020.01–2023.10 |

## 使用提示

- 快慢线、信号线参数对结果影响很大，换品种/换周期请重新优化。
- 5M 类策略对点差与执行延迟敏感，建议在 Exness 低点差账户验证。
- 注意网格或加仓类参数（若启用）会显著放大回撤。

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)