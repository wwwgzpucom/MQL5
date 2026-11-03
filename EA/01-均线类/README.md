# 01-均线类

适用于 **Exness** MT5。开户：[Exness](https://one.toexness.com/intl/zh/a/30852)

本目录为**均线趋势过滤**类策略：用多条均线判断方向，再叠加辅助信号入场。

## 策略一览

| EA | 版本 | 核心逻辑 | 参考回测环境 |
|----|------|----------|--------------|
| `3MAF.mq5` | 1.5 | 三条 Moving Average 定趋势，Williams Fractals 给进出场点 | USDCAD · 15M · 2021.02–2023.09 |
| `2MAAOS.mq5` | 1.4 | 双均线方向 + **Andean Oscillator** 确认动量 | EURUSD / EURCAD / USDCAD · 4H · 2019–2023 |

## 使用提示

- 先编译依赖指标（如 Andean Oscillator，见 `../_依赖指标/`）。
- 均线周期、品种与周期需按自己的经纪商点差与时区重新优化；示例回测仅供参考。
- 实盘前务必在 Exness 模拟账户充分测试。

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)