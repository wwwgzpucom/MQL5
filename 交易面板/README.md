# 交易面板

适用于 **Exness** MetaTrader 5。  
开户 / 访问：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

本目录存放各类**交易面板**项目。  
- **单文件面板**：可直接放 `.mq5`  
- **多文件面板**（主程序 + Include 等）：各自单独建一个子文件夹

## 面板列表

| 目录 | 说明 |
|------|------|
| [`TradingPanel/`](./TradingPanel/) | 图表交易辅助面板（下单 / 风险% / SL·TP / 移动止损） |

## 约定

```
交易面板/
  README.md                 # 本索引
  SomePanel/                # 多文件面板示例
    README.md
    SomePanel.mq5
    Include/...
  SimplePanel.mq5           # 单文件面板可放根下（可选）
```