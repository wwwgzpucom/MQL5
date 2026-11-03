# 风险下单面板（RiskOrderPanel）

按**风险百分比**快速下单，并支持止损 / 止盈与**移动止损**的图表交易辅助面板。

适用于 **Exness** MT5。开户：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

## 文件结构

| 路径 | 说明 |
|------|------|
| `RiskOrderPanel.mq5` | EA 主程序 → `MQL5/Experts/` |
| `Include/TradingPanel.mqh` | 面板 UI |
| `Include/TradingAgent.mqh` | 交易代理逻辑 |
| `Include/TradingHelper.mqh` | 账户/持仓辅助 |
| `Include/TrailingStop.mqh` | 移动止损 |

## 安装

1. 将 `Include/` 下全部 `.mqh` 复制到 `MQL5/Include/`
2. 将 `RiskOrderPanel.mq5` 复制到 `MQL5/Experts/`
3. MetaEditor 编译后拖到图表

## 主要能力

- 按风险 `%` 计算手数下单
- 止损 / 止盈（pips）
- 移动止损启动位与步进
- 多空持仓处理方式可选

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)