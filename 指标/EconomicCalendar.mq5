//+------------------------------------------------------------------+
//|                                            EconomicCalendar.mq5 |
//|                                  显示USD相关的财经日历事件        |
//+------------------------------------------------------------------+
#property copyright "Economic Calendar Indicator"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property indicator_chart_window
#property indicator_plots 0

//--- 输入参数
input ENUM_CALENDAR_EVENT_IMPORTANCE MinImportance = CALENDAR_IMPORTANCE_MODERATE;  // 最低重要性级别
input bool ShowPastEvents = true;                      // 显示当天已发生事件(仍限北京时间当日)
input bool ShowVerticalLines = true;                   // 在图表上显示垂直线
input color TextColor = clrYellow;                     // 默认文字颜色
input int FontSize = 10;                               // 字体大小(1-32)
input int RefreshMinutes = 5;                          // 刷新间隔(分钟)
input int MaxEventsDisplay = 20;                       // 最大显示事件数
input int InstanceId = 1;                              // 实例ID(同图多实例请设不同值)

//--- 全局变量
datetime lastUpdate = 0;
string objectPrefix = "EcoCalendar_";
const int BeijingOffsetSec = 8 * 3600;  // 北京时间 UTC+8（无夏令时）

struct EventInfo
{
   ulong event_id;
   datetime time;   // 交易服务器时间
   string name;
   string country;
   ENUM_CALENDAR_EVENT_IMPORTANCE importance;
   long actual;
   uint digits;
   bool hasActual;
};

//+------------------------------------------------------------------+
//| 服务器相对 GMT 偏移（秒）                                          |
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
//| query*：API 查询窗（精确日界 ±1h，兼容服务器夏令时切换）             |
//| day*Beijing：精确北京自然日，用于过滤                               |
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
   const int pad = 3600;
   queryStartServer = dayStartGMT + serverGmtOffset - pad;
   queryEndServer = dayEndGMT + serverGmtOffset + pad;
}

//+------------------------------------------------------------------+
//| 排序：时间升序 → 重要性降序 → event_id                              |
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
                 const string text)
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
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
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
//| 显示状态                                                           |
//+------------------------------------------------------------------+
void ShowStatus(const string message, const bool isError,
                string &keepNames[], int &keepCount)
{
   const string name = objectPrefix + "Status";
   UpsertLabel(name, 10, 80, isError ? clrRed : clrSilver, FontSize,
               (isError ? "! " : "") + message);
   KeepName(keepNames, keepCount, name);
}

void ShowStatus(const string message, const bool isError)
{
   string keepNames[];
   int keepCount = 0;
   ShowStatus(message, isError, keepNames, keepCount);
   ArrayResize(keepNames, keepCount);
   DeleteStaleObjects(keepNames);
}

//+------------------------------------------------------------------+
//| 显示标题                                                           |
//+------------------------------------------------------------------+
void DisplayTitle(const int count, const int contentTopY,
                  string &keepNames[], int &keepCount)
{
   const string name = objectPrefix + "Title";
   UpsertLabel(name, 10, contentTopY + 30, clrAqua, FontSize + 2,
               StringFormat("今日USD经济日历 (%d)", count));
   KeepName(keepNames, keepCount, name);
}

//+------------------------------------------------------------------+
//| 显示单个事件（含可选竖线）                                          |
//+------------------------------------------------------------------+
void DisplayEvent(const EventInfo &evt, const int yPos, const int index,
                  const int serverGmtOffset, const datetime nowServer,
                  string &keepNames[], int &keepCount)
{
   color eventColor = TextColor;
   string importance = "";
   switch(evt.importance)
   {
      case CALENDAR_IMPORTANCE_LOW:
         importance = "[低]";
         eventColor = clrGray;
         break;
      case CALENDAR_IMPORTANCE_MODERATE:
         importance = "[中]";
         eventColor = clrYellow;
         break;
      case CALENDAR_IMPORTANCE_HIGH:
         importance = "[高]";
         eventColor = clrOrange;
         break;
   }

   MqlDateTime dt;
   TimeToStruct(ServerToBeijing(evt.time, serverGmtOffset), dt);
   string timeStr = StringFormat("%02d-%02d %02d:%02d", dt.mon, dt.day, dt.hour, dt.min);
   if(evt.time < nowServer)
      timeStr += " [done]";

   string text = StringFormat("%s %s %s %s", timeStr, importance, evt.country, evt.name);
   if(evt.hasActual)
      text += StringFormat(" [实际: %s]", FormatValue(evt.actual, evt.digits));

   const string name = objectPrefix + "Event_" + IntegerToString(index);
   UpsertLabel(name, 10, yPos, eventColor, FontSize, text);
   KeepName(keepNames, keepCount, name);

   if(ShowVerticalLines && evt.time >= nowServer)
   {
      const string vname = objectPrefix + "VLine_" + IntegerToString(index);
      if(ObjectFind(0, vname) < 0)
      {
         if(!ObjectCreate(0, vname, OBJ_VLINE, 0, evt.time, 0))
         {
            PrintFormat("ObjectCreate(%s) failed, err=%d", vname, GetLastError());
            return;
         }
         ObjectSetInteger(0, vname, OBJPROP_BACK, true);
         ObjectSetInteger(0, vname, OBJPROP_SELECTABLE, false);
      }
      else if(!ObjectMove(0, vname, 0, evt.time, 0))
      {
         PrintFormat("ObjectMove(%s) failed, err=%d", vname, GetLastError());
      }
      ObjectSetInteger(0, vname, OBJPROP_COLOR, eventColor);
      ObjectSetInteger(0, vname, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, vname, OBJPROP_WIDTH, 1);
      ObjectSetString(0, vname, OBJPROP_TEXT, evt.name);
      KeepName(keepNames, keepCount, vname);
   }
}

//+------------------------------------------------------------------+
//| 初始化                                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   if(RefreshMinutes < 1 || MaxEventsDisplay < 1 ||
      FontSize < 1 || FontSize > 32 ||
      InstanceId < 1 || InstanceId > 9999)
   {
      Print("输入参数非法: RefreshMinutes/MaxEventsDisplay/FontSize/InstanceId");
      return(INIT_PARAMETERS_INCORRECT);
   }

   objectPrefix = StringFormat("EcoCalendar_%s_%d_", IntegerToString(ChartID()), InstanceId);
   DeleteAllObjects();

   if(!EventSetTimer(RefreshMinutes * 60))
   {
      PrintFormat("EventSetTimer failed, err=%d", GetLastError());
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
      ShowStatus("服务器时间未就绪", true);
      return;
   }

   const int refreshSec = RefreshMinutes * 60;
   if(!force && lastUpdate > 0 && (nowServer - lastUpdate) < refreshSec)
      return;

   int serverGmtOffset = 0;
   if(!CalcServerGmtOffset(serverGmtOffset))
   {
      ShowStatus("时区偏移无效，请检查连接", true);
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
      ShowStatus(StringFormat("日历请求失败 err=%d", err), true);
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
      if(events[eventCount].hasActual)
         events[eventCount].actual = values[i].actual_value;
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
         DisplayEvent(events[i], yPos, i, serverGmtOffset, nowServer, keepNames, keepCount);
         yPos += 20;
      }
      DisplayTitle(eventCount, yPos, keepNames, keepCount);
   }
   else
   {
      ShowStatus("今日无符合条件的USD经济事件", false, keepNames, keepCount);
   }

   ArrayResize(keepNames, keepCount);
   DeleteStaleObjects(keepNames);
   ChartRedraw();
   lastUpdate = nowServer;
}
//+------------------------------------------------------------------+
