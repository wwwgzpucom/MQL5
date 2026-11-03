# 财经日历指标

MetaTrader 5 自定义指标，在主图左下角列出**北京时间当日**与 **USD** 相关的财经日历事件，并可在事件时刻画垂直线。

数据来源：MT5 内置 `CalendarValueHistory` API（需终端能访问 MetaQuotes 经济日历服务）。

## 适用平台

此指标适用于 **Exness** 平台（MetaTrader 5）。

开户 / 访问链接：[https://one.toexness.com/intl/zh/a/30852](https://one.toexness.com/intl/zh/a/30852)

## 文件

| 文件 | 版本 | 说明 |
|------|------|------|
| `EconomicCalendar.mq5` | 1.01 | 基础版：事件列表 + 实际值 + 竖线 |
| `EconomicCalendarAdvanced.mq5` | 1.04 | 增强版：实际/预期/前值、重要性分色、更新时间戳 |

## 安装

1. 将 `.mq5` 复制到终端目录：`MQL5/Indicators/`（或子文件夹）
2. 在 MetaEditor 中编译，或重启 MT5 自动编译
3. 导航器 → 指标 → 拖到图表

同图多实例时，请把各实例的 `InstanceId` 设为不同值。

## 功能对比

| 能力 | EconomicCalendar | EconomicCalendarAdvanced |
|------|:----------------:|:------------------------:|
| 北京时间当日 USD 事件 | ✓ | ✓ |
| 最低重要性过滤 | ✓ | ✓ |
| 已发生事件开关 | ✓ | ✓（默认关） |
| 图表垂直线 | ✓ | ✓（高重要更粗） |
| 显示实际值 | ✓ | ✓ |
| 显示预期 / 前值 | — | ✓ |
| 重要性自定义颜色 | 固定配色 | 可配置 |
| 刷新间隔 | 分钟 | 秒 |
| 更新时间显示 | — | ✓ |

## 输入参数

### EconomicCalendar.mq5

| 参数 | 默认 | 说明 |
|------|------|------|
| `MinImportance` | 中等 | 低于此级别的事件不显示 |
| `ShowPastEvents` | true | 是否显示当日已发生事件 |
| `ShowVerticalLines` | true | 未来事件是否画竖线 |
| `TextColor` | 黄 | 默认文字色（低/中/高会覆盖） |
| `FontSize` | 10 | 字体大小 1–32 |
| `RefreshMinutes` | 5 | 定时刷新间隔（分钟） |
| `MaxEventsDisplay` | 20 | 最多显示条数 |
| `InstanceId` | 1 | 同图多实例区分 |

### EconomicCalendarAdvanced.mq5

| 参数 | 默认 | 说明 |
|------|------|------|
| `MinImportance` | 中等 | 最低重要性 |
| `ShowPastEvents` | false | 是否显示已发生事件 |
| `ShowVerticalLines` | true | 是否画竖线 |
| `ShowDetailedInfo` | true | 显示实际/预期/前值 |
| `HighImpColor` / `MedImpColor` / `LowImpColor` | 红 / 黄 / 灰 | 重要性颜色 |
| `FontSize` | 9 | 字体大小 1–32 |
| `RefreshSeconds` | 300 | 定时刷新间隔（秒） |
| `MaxEventsDisplay` | 20 | 最多显示条数 |
| `InstanceId` | 1 | 同图多实例区分 |

## 行为说明

- **日历日界**：按北京时间（UTC+8，无夏令时）的自然日过滤；API 查询窗相对日界扩 ±1 小时，兼容服务器夏令时切换边界。
- **时间显示**：列表时间为北京时间；竖线时间与图表/服务器时间对齐。
- **刷新**：定时器周期刷新；新 K 线也会触发（受间隔节流）。
- **卸载**：`OnDeinit` 删除本实例创建的全部图表对象。

## 环境要求

- MetaTrader 5（支持经济日历 API）
- Exness 平台账户与终端
- 终端已登录，并能拉取日历数据；否则会显示「日历请求失败」类状态
