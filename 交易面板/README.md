# 交易面板

适用于 **Exness** MetaTrader 5。  
开户 / 访问：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

本目录存放各类**交易面板**项目。  
- **单文件面板**：可直接放 `.mq5`  
- **多文件面板**（主程序 + Include 等）：各自单独建一个子文件夹，名称尽量体现功能

## 面板列表

| 目录 | 说明 |
|------|------|
| [`风险下单面板/`](./风险下单面板/) | 按风险%下单 + SL/TP + 移动止损（RiskOrderPanel） |

## 约定

```
交易面板/
  README.md
  风险下单面板/          # 多文件：功能名作文件夹
    README.md
    RiskOrderPanel.mq5
    Include/...
```