# 策略 EA（仅源码 .mq5 / .mqh）

适用于 **Exness** MT5。开户：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

本目录**只保留源码**，不含任何 `.ex5` 编译文件。  
**每个分类文件夹内另有 README，说明该目录下各策略逻辑与依赖。**

## 分类

| 分类 | EA | 说明文档 |
|------|----|----------|
| 01-均线类 | 3MAF, 2MAAOS | [README](./01-均线类/README.md) |
| 02-MACD类 | 3MACD, 2MACDSTO | [README](./02-MACD类/README.md) |
| 03-布林带RSI | BBRSI | [README](./03-布林带RSI/README.md) |
| 04-Andean振荡 | DHLAOS, AFAOSMD | [README](./04-Andean振荡/README.md) |
| 05-通道与包络 | CEZLSMA, NWERSIASF, LRCUTB | [README](./05-通道与包络/README.md) |
| 06-COT持仓 | COT1 | [README](./06-COT持仓/README.md) |

## 依赖

- `_依赖指标/`：配套自定义指标 `.mq5`
- `_依赖库/`：`Include` 下的 `.mqh`

安装：将 EA 放到 `MQL5/Experts/`，指标放到 `MQL5/Indicators/`，库放到 `MQL5/Include/` 后编译。