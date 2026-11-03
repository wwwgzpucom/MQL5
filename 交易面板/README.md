# 交易面板（Trading Panel）

适用于 **Exness** MetaTrader 5。  
开户 / 访问：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

图表交易辅助面板：快速下单、风险%、止损止盈、移动止损等，减少手工操作。

源码整理自原仓库 `MQL_Trading_Panel`（仅保留 MT5 源码 `.mq5` / `.mqh`）。

## 文件结构

| 路径 | 说明 |
|------|------|
| `TradingPanel.mq5` | EA 主程序（放到 `MQL5/Experts/`） |
| `Include/TradingPanel.mqh` | 面板 UI |
| `Include/TradingAgent.mqh` | 交易代理逻辑 |
| `Include/TradingHelper.mqh` | 账户/持仓辅助 |
| `Include/TrailingStop.mqh` | 移动止损 |

## 安装（MT5）

1. 将 `Include/` 下全部 `.mqh` 复制到终端 `MQL5/Include/`
2. 将 `TradingPanel.mq5` 复制到 `MQL5/Experts/`
3. 用 MetaEditor 编译 `TradingPanel.mq5`
4. 在导航器 → EA 中拖到图表

## 主要输入参数

- `risk`：风险百分比
- `SL` / `TP`：止损 / 止盈（pips）
- `startSL` / `widthSL`：移动止损启动与步进（pips）
- `position_handling`：持仓处理方式

## 版权

`Copyright 2026, wwwgzpucom`  
`#property link`：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

原作者作品基于公开仓库整理；使用前请自行回测与风控，不构成投资建议。