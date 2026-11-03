# 04-Andean振荡

适用于 **Exness** MT5。开户：[Exness](https://one.toexness.com/intl/zh/a/30852)

本目录策略以自定义指标 **Andean Oscillator（安第斯振荡）** 为核心，结合日内高低点或 Average Force、MACD 做过滤。

## 策略一览

| EA | 版本 | 核心逻辑 | 参考回测环境 |
|----|------|----------|--------------|
| `DHLAOS.mq5` | 1.5 | **Daily High/Low** + Andean Oscillator，偏**剥头皮** | AUDUSD · 5M · 2021.02–2023.09 |
| `AFAOSMD.mq5` | 1.5 | **Average Force** + Andean Oscillator + **MACD** | NZDCAD · 30M · 2019–2023 |

## 依赖指标

请先编译并确保 MT5 能加载：

- `AndeanOscillator.mq5`
- `DailyHighLow.mq5`（DHLAOS）
- `AverageForce.mq5`（AFAOSMD）

路径见 `../_依赖指标/`。

## 使用提示

- 剥头皮版本对点差、滑点敏感；建议在 Exness 模拟盘对比不同时段。
- Andean 周期参数会改变信号频率，过小易噪音、过大易滞后。

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)