//+------------------------------------------------------------------+
//|                                                      SysTime.mqh |
//|                        Copyright 2026, wwwgzpucom |
//|                     https://one.toexness.com/intl/zh/a/30852 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, wwwgzpucom"
#property link        "https://one.toexness.com/intl/zh/a/30852"
#property version   "1.0"

#include <WinAPI\sysinfoapi.mqh>

//+------------------------------------------------------------------+
//| Retrieves the current system date and time in UTC format.        |
//+------------------------------------------------------------------+
datetime TimeSystem() {
    SYSTEMTIME st;
    GetSystemTime(st);
    return SystemTimeToDatetime(st);
}

//+------------------------------------------------------------------+
//| Retrieves the current local date and time.                       |
//+------------------------------------------------------------------+
datetime TimeSystemLocal() {
    SYSTEMTIME st;
    GetLocalTime(st);
    return SystemTimeToDatetime(st);
}

//+------------------------------------------------------------------+
//| Convert SYSTEMTIME to datetime.                                  |
//+------------------------------------------------------------------+
datetime SystemTimeToDatetime(SYSTEMTIME &st) {
    string str = StringFormat("%d.%02d.%02d %02d:%02d:%02d",
                              st.wYear, st.wMonth, st.wDay,
                              st.wHour, st.wMinute, st.wSecond);
    return StringToTime(str);
}

//+------------------------------------------------------------------+
//| Overload                                                         |
//+------------------------------------------------------------------+
datetime TimeSystem(MqlDateTime &dt_str) {
    datetime t = TimeSystem();
    TimeToStruct(t, dt_str);
    return t;
}

//+------------------------------------------------------------------+
//| Overload                                                         |
//+------------------------------------------------------------------+
datetime TimeSystemLocal(MqlDateTime &dt_str) {
    datetime t = TimeSystemLocal();
    TimeToStruct(t, dt_str);
    return t;
}

//+------------------------------------------------------------------+
