# TradingPanel

图表交易辅助面板：快速下单、风险%、止损止盈、移动止损等。

适用于 **Exness** MT5。开户：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

## 文件结构

| 路径 | 说明 |
|------|------|
| `TradingPanel.mq5` | EA 主程序 → 复制到 `MQL5/Experts/` |
| `Include/TradingPanel.mqh` | 面板 UI |
| `Include/TradingAgent.mqh` | 交易代理逻辑 |
| `Include/TradingHelper.mqh` | 账户/持仓辅助 |
| `Include/TrailingStop.mqh` | 移动止损 |

## 安装

1. 将本目录 `Include/` 下全部 `.mqh` 复制到 `MQL5/Include/`
2. 将 `TradingPanel.mq5` 复制到 `MQL5/Experts/`
3. MetaEditor 编译后拖到图表

## 版权

`Copyright 2026, wwwgzpucom`  
链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)