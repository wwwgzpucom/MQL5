//+------------------------------------------------------------------+
//|                                   EconomicCalendarAdvanced.mq5   |
//|                          高级财经日历指标 - 显示USD相关事件        |
//+------------------------------------------------------------------+
#property copyright "Advanced Economic Calendar Indicator"
#property link      "https://www.mql5.com"
#property version   "1.04"
#property indicator_chart_window
#property indicator_plots 0

//--- 输入参数
input ENUM_CALENDAR_EVENT_IMPORTANCE MinImportance = CALENDAR_IMPORTANCE_MODERATE;  // 最低重要性级别
input bool ShowPastEvents = false;                     // 显示当天已发生事件(仍限北京时间当日)
input bool ShowVerticalLines = true;                   // 在图表上显示垂直线
input bool ShowDetailedInfo = true;                    // 显示详细信息(预期/前值)
input color HighImpColor = clrRed;                     // 高重要性颜色
input color MedImpColor = clrYellow;                   // 中重要性颜色
input color LowImpColor = clrGray;                     // 低重要性颜色
input int FontSize = 9;                                // 字体大小(1-32)
input int RefreshSeconds = 300;                        // 刷新间隔(秒)
input int MaxEventsDisplay = 20;                       // 最大显示事件数
input int InstanceId = 1;                              // 实例ID(同图多实例请设不同值)

//--- 全局变量
datetime lastUpdate = 0;
string objectPrefix = "EcoCalAdv_";
const int BeijingOffsetSec = 8 * 3600;  // 北京时间 UTC+8（无夏令时）

//--- 事件结构
struct EventInfo
{
   ulong event_id;
   datetime time;   // 交易服务器时间（与 Calendar API / 图表时间一致）
   string name;
   string country;
   ENUM_CALENDAR_EVENT_IMPORTANCE importance;
   long actual;
   long forecast;
   long previous;
   uint digits;
   bool hasActual;
   bool hasForecast;
   bool hasPrevious;
};

//+------------------------------------------------------------------+
//| 服务器相对 GMT 偏移（秒）。TimeTradeServer/TimeGMT 可能跨秒差 1s， |
//| 对日历显示可接受；仅拒绝无效时间与明显异常偏移。                   |
//+------------------------------------------------------------------+
bool CalcServerGmtOffset(int &offsetSec)
{
   const datetime srv = TimeTradeServer();
   const datetime gmt = TimeGMT();
   if(srv <= 0 || gmt <= 0)
      return false;

   offsetSec = (int)(srv - gmt);
   if(offsetSec < -15 * 3600 || offsetSec > 15 * 3600)
      return false;
   return true;
}

//+------------------------------------------------------------------+
//| 交易服务器时间 -> 北京时间                                          |
//+------------------------------------------------------------------+
datetime ServerToBeijing(const datetime serverTime, const int serverGmtOffset)
{
   return serverTime - serverGmtOffset + BeijingOffsetSec;
}

//+------------------------------------------------------------------+
//| 北京时间当日范围                                                    |
//| query*：API 查询窗（相对精确日界 ±1h，兼容服务器夏令时切换边界）     |
//| day*Beijing：精确北京自然日，用于过滤，避免一次刷新内重复读 TimeGMT |
//+------------------------------------------------------------------+
void GetBeijingDayRange(const int serverGmtOffset,
                        datetime &queryStartServer, datetime &queryEndServer,
                        datetime &dayStartBeijing, datetime &dayEndBeijing)
{
   datetime beijingNow = TimeGMT() + BeijingOffsetSec;
   MqlDateTime dt;
   TimeToStruct(beijingNow, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   dayStartBeijing = StructToTime(dt);
   dayEndBeijing = dayStartBeijing + 86400;

   const datetime dayStartGMT = dayStartBeijing - BeijingOffsetSec;
   const datetime dayEndGMT = dayEndBeijing - BeijingOffsetSec;
   const int pad = 3600;  // 业务需要：覆盖服务器 DST 切换日边界
   queryStartServer = dayStartGMT + serverGmtOffset - pad;
   queryEndServer = dayEndGMT + serverGmtOffset + pad;
}

//+------------------------------------------------------------------+
//| 排序：时间升序 → 重要性降序 → event_id 升序                         |
//+------------------------------------------------------------------+
void SortEvents(EventInfo &events[], const int count)
{
   for(int i = 0; i < count - 1; i++)
   {
      for(int j = i + 1; j < count; j++)
      {
         const bool swap =
            (events[j].time < events[i].time) ||
            (events[j].time == events[i].time && events[j].importance > events[i].importance) ||
            (events[j].time == events[i].time && events[j].importance == events[i].importance &&
             events[j].event_id < events[i].event_id);
         if(swap)
         {
            EventInfo tmp = events[i];
            events[i] = events[j];
            events[j] = tmp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| 加入 keep 列表                                                     |
//+------------------------------------------------------------------+
void KeepName(string &keepNames[], int &keepCount, const string name)
{
   ArrayResize(keepNames, keepCount + 1);
   keepNames[keepCount++] = name;
}

//+------------------------------------------------------------------+
//| 创建或更新标签                                                        |
//+------------------------------------------------------------------+
void UpsertLabel(const string name,
                 const int x, const int y,
                 const color clr, const int fontSize,
                 const string text, const string font = "Arial")
{
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      {
         PrintFormat("ObjectCreate(%s) failed, err=%d", name, GetLastError());
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, name, OBJPROP_FONT, font);
   }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

//+------------------------------------------------------------------+
//| 绘制垂直线并加入 keep                                              |
//+------------------------------------------------------------------+
void DrawEventLine(const EventInfo &evt, const int index, string &keepNames[], int &keepCount)
{
   const string name = objectPrefix + "VLine_" + IntegerToString(index);

   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_VLINE, 0, evt.time, 0))
      {
         PrintFormat("ObjectCreate(%s) failed, err=%d", name, GetLastError());
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else if(!ObjectMove(0, name, 0, evt.time, 0))
   {
      PrintFormat("ObjectMove(%s) failed, err=%d", name, GetLastError());
   }

   color lineColor = LowImpColor;
   int lineWidth = 1;
   if(evt.importance == CALENDAR_IMPORTANCE_HIGH)
   {
      lineColor = HighImpColor;
      lineWidth = 2;
   }
   else if(evt.importance == CALENDAR_IMPORTANCE_MODERATE)
   {
      lineColor = MedImpColor;
   }

   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, lineWidth);
   ObjectSetString(0, name, OBJPROP_TEXT, evt.name);
   KeepName(keepNames, keepCount, name);
}

//+------------------------------------------------------------------+
//| 显示标题                                                           |
//+------------------------------------------------------------------+
void DisplayTitle(const int count, const int contentTopY, string &keepNames[], int &keepCount)
{
   const int titleY = contentTopY + 40;
   string name = objectPrefix + "Title";
   UpsertLabel(name, 10, titleY, clrAqua, FontSize + 3,
               StringFormat("经济日历 (%d)", count), "Arial Black");
   KeepName(keepNames, keepCount, name);

   name = objectPrefix + "Line";
   UpsertLabel(name, 10, titleY - 20, clrDarkGray, FontSize,
               "----------------------------------------------");
   KeepName(keepNames, keepCount, name);
}

//+------------------------------------------------------------------+
//| 显示事件信息                                                       |
//+------------------------------------------------------------------+
void DisplayEventInfo(const EventInfo &evt, const int yPos, const int index,
                      const bool hasDetail, const int serverGmtOffset,
                      const datetime nowServer,
                      string &keepNames[], int &keepCount)
{
   color eventColor = clrGray;
   string impSymbol = "o";
   switch(evt.importance)
   {
      case CALENDAR_IMPORTANCE_LOW:
         eventColor = LowImpColor;
         impSymbol = "*";
         break;
      case CALENDAR_IMPORTANCE_MODERATE:
         eventColor = MedImpColor;
         impSymbol = "**";
         break;
      case CALENDAR_IMPORTANCE_HIGH:
         eventColor = HighImpColor;
         impSymbol = "***";
         break;
   }

   MqlDateTime dt;
   TimeToStruct(ServerToBeijing(evt.time, serverGmtOffset), dt);
   string timeStr = StringFormat("%02d-%02d %02d:%02d", dt.mon, dt.day, dt.hour, dt.min);
   if(evt.time < nowServer)
      timeStr += " [done]";

   string name = objectPrefix + "Event_" + IntegerToString(index);
   UpsertLabel(name, 10, yPos + (hasDetail ? 15 : 0), eventColor, FontSize,
               StringFormat("%s %s [%s] %s", timeStr, impSymbol, evt.country, evt.name));
   KeepName(keepNames, keepCount, name);

   if(hasDetail)
   {
      name = objectPrefix + "Detail_" + IntegerToString(index);
      string detailText = "";
      if(evt.hasActual)
         detailText += "实际:" + FormatValue(evt.actual, evt.digits) + " ";
      if(evt.hasForecast)
         detailText += "预期:" + FormatValue(evt.forecast, evt.digits) + " ";
      if(evt.hasPrevious)
         detailText += "前值:" + FormatValue(evt.previous, evt.digits);
      UpsertLabel(name, 30, yPos, clrSilver, MathMax(1, FontSize - 1), detailText);
      KeepName(keepNames, keepCount, name);
   }
}

//+------------------------------------------------------------------+
//| 显示更新时间                                                       |
//+------------------------------------------------------------------+
void DisplayUpdateTime(const int baseYPos, const int serverGmtOffset,
                       const datetime nowServer,
                       string &keepNames[], int &keepCount)
{
   const string name = objectPrefix + "UpdateTime";
   UpsertLabel(name, 10, baseYPos + 5, clrDarkGray, MathMax(1, FontSize - 2),
               StringFormat("更新: %s (北京时间)",
                            TimeToString(ServerToBeijing(nowServer, serverGmtOffset),
                                         TIME_DATE|TIME_MINUTES)));
   KeepName(keepNames, keepCount, name);
}

//+------------------------------------------------------------------+
//| 显示状态信息                                                       |
//+------------------------------------------------------------------+
void ShowStatusMessage(const string message, const bool isError,
                       string &keepNames[], int &keepCount)
{
   const string name = objectPrefix + "Status";
   UpsertLabel(name, 10, 80,
               isError ? clrRed : clrSilver,
               FontSize + 1,
               (isError ? "! " : "") + message);
   KeepName(keepNames, keepCount, name);
}

void ShowStatusMessage(const string message, const bool isError)
{
   string keepNames[];
   int keepCount = 0;
   ShowStatusMessage(message, isError, keepNames, keepCount);
   ArrayResize(keepNames, keepCount);
   DeleteStaleObjects(keepNames);
}

//+------------------------------------------------------------------+
//| 格式化数值：字段以百万分之一存储，digits 仅控制小数位               |
//+------------------------------------------------------------------+
string FormatValue(const long value, const uint digits)
{
   if(value == LONG_MAX || value == LONG_MIN)
      return "N/A";
   return DoubleToString((double)value / 1000000.0, (int)MathMin(digits, 6));
}

//+------------------------------------------------------------------+
//| 删除过期对象                                                       |
//+------------------------------------------------------------------+
void DeleteStaleObjects(const string &keepNames[])
{
   const int keepCount = ArraySize(keepNames);
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
   {
      const string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, objectPrefix) != 0)
         continue;

      bool keep = false;
      for(int k = 0; k < keepCount; k++)
      {
         if(name == keepNames[k])
         {
            keep = true;
            break;
         }
      }
      if(!keep && !ObjectDelete(0, name))
         PrintFormat("ObjectDelete(%s) failed, err=%d", name, GetLastError());
   }
}

//+------------------------------------------------------------------+
//| 删除本实例全部对象                                                 |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
   {
      const string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, objectPrefix) == 0 && !ObjectDelete(0, name))
         PrintFormat("ObjectDelete(%s) failed, err=%d", name, GetLastError());
   }
}

//+------------------------------------------------------------------+
//| 初始化                                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   if(RefreshSeconds < 1 || MaxEventsDisplay < 1 ||
      FontSize < 1 || FontSize > 32 ||
      InstanceId < 1 || InstanceId > 9999)
   {
      Print("输入参数非法: RefreshSeconds/MaxEventsDisplay/FontSize/InstanceId");
      return(INIT_PARAMETERS_INCORRECT);
   }

   objectPrefix = StringFormat("EcoCalAdv_%s_%d_", IntegerToString(ChartID()), InstanceId);
   DeleteAllObjects();

   if(!EventSetTimer(RefreshSeconds))
   {
      PrintFormat("EventSetTimer(%d) failed, err=%d", RefreshSeconds, GetLastError());
      return(INIT_FAILED);
   }

   UpdateCalendar(true);
   PrintFormat("经济日历已启动 prefix=%s", objectPrefix);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 反初始化                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   DeleteAllObjects();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| 定时器                                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdateCalendar(true);
}

//+------------------------------------------------------------------+
//| 新K线检测                                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total <= 0)
      return(0);

   const datetime currentBar = ArrayGetAsSeries(time) ? time[0] : time[rates_total - 1];
   static datetime lastBar = 0;
   if(currentBar != lastBar)
   {
      lastBar = currentBar;
      UpdateCalendar(false);
   }
   return(rates_total);
}

//+------------------------------------------------------------------+
//| 主流程：时间范围 → API → 过滤 → 排序/截断 → 绘制 → 清理             |
//+------------------------------------------------------------------+
void UpdateCalendar(const bool force = false)
{
   const datetime nowServer = TimeTradeServer();
   if(nowServer <= 0)
   {
      ShowStatusMessage("服务器时间未就绪", true);
      return;
   }

   if(!force && lastUpdate > 0 && (nowServer - lastUpdate) < RefreshSeconds)
      return;

   int serverGmtOffset = 0;
   if(!CalcServerGmtOffset(serverGmtOffset))
   {
      ShowStatusMessage("时区偏移无效，请检查连接", true);
      lastUpdate = nowServer;
      ChartRedraw();
      return;
   }

   datetime queryStart, queryEnd, dayStartBeijing, dayEndBeijing;
   GetBeijingDayRange(serverGmtOffset, queryStart, queryEnd, dayStartBeijing, dayEndBeijing);

   MqlCalendarValue values[];
   ResetLastError();
   const int historyRet = CalendarValueHistory(values, queryStart, queryEnd, NULL, "USD");
   if(historyRet < 0)
   {
      const int err = GetLastError();
      ShowStatusMessage(StringFormat("日历请求失败 err=%d", err), true);
      PrintFormat("CalendarValueHistory failed: ret=%d err=%d", historyRet, err);
      lastUpdate = nowServer;
      ChartRedraw();
      return;
   }

   EventInfo events[];
   int eventCount = 0;
   const int totalValues = (int)ArraySize(values);

   for(int i = 0; i < totalValues; i++)
   {
      MqlCalendarEvent event;
      if(!CalendarEventById(values[i].event_id, event))
         continue;
      if(event.importance < MinImportance)
         continue;
      if(!ShowPastEvents && values[i].time < nowServer)
         continue;

      const datetime beijingTime = ServerToBeijing(values[i].time, serverGmtOffset);
      if(beijingTime < dayStartBeijing || beijingTime >= dayEndBeijing)
         continue;

      // 扩窗去重
      bool dup = false;
      for(int d = 0; d < eventCount; d++)
      {
         if(events[d].event_id == values[i].event_id && events[d].time == values[i].time)
         {
            dup = true;
            break;
         }
      }
      if(dup)
         continue;

      MqlCalendarCountry country;
      if(!CalendarCountryById(event.country_id, country))
         country.code = "??";

      ArrayResize(events, eventCount + 1);
      events[eventCount].event_id = values[i].event_id;
      events[eventCount].time = values[i].time;
      events[eventCount].name = event.name;
      events[eventCount].country = country.code;
      events[eventCount].importance = event.importance;
      events[eventCount].digits = event.digits;
      events[eventCount].hasActual = values[i].HasActualValue();
      events[eventCount].hasForecast = values[i].HasForecastValue();
      events[eventCount].hasPrevious = values[i].HasPreviousValue();
      if(events[eventCount].hasActual)
         events[eventCount].actual = values[i].actual_value;
      if(events[eventCount].hasForecast)
         events[eventCount].forecast = values[i].forecast_value;
      if(events[eventCount].hasPrevious)
         events[eventCount].previous = values[i].prev_value;
      eventCount++;
   }

   SortEvents(events, eventCount);
   if(eventCount > MaxEventsDisplay)
      eventCount = MaxEventsDisplay;

   string keepNames[];
   int keepCount = 0;

   if(eventCount > 0)
   {
      int yPos = 80;
      for(int i = 0; i < eventCount; i++)
      {
         const bool hasDetail = ShowDetailedInfo &&
                                (events[i].hasActual || events[i].hasForecast || events[i].hasPrevious);
         DisplayEventInfo(events[i], yPos, i, hasDetail, serverGmtOffset, nowServer,
                          keepNames, keepCount);
         if(ShowVerticalLines && events[i].time >= nowServer)
            DrawEventLine(events[i], i, keepNames, keepCount);
         yPos += hasDetail ? 35 : 18;
      }
      DisplayTitle(eventCount, yPos, keepNames, keepCount);
      DisplayUpdateTime(yPos, serverGmtOffset, nowServer, keepNames, keepCount);
   }
   else
   {
      ShowStatusMessage("今日无符合条件的USD经济事件", false, keepNames, keepCount);
   }

   ArrayResize(keepNames, keepCount);
   DeleteStaleObjects(keepNames);
   ChartRedraw();
   lastUpdate = nowServer;
}
//+------------------------------------------------------------------+
