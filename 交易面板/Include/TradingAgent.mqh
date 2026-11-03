//+------------------------------------------------------------------+
//|                                                 TradingAgent.mqh |
//|                                       Copyright 2026, wwwgzpucom |
//|                         https://one.toexness.com/intl/zh/a/30852 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                 TradingAgent.mqh |
//|             Copyright 2018, Kashu Yamazaki, All Rights Reserved. |
//|                                      https://Kashu7100.github.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, wwwgzpucom"
#property link        "https://one.toexness.com/intl/zh/a/30852"
#property strict

#include <TrailingStop.mqh>

enum ENUM_TRADE_MODE{
   LONG_AND_SHORT = 0,  //long&short
   LONG_ONLY = 1,       //long only   
   SHORT_ONLY = 2,      //short only
   NO_POSITIONS = 3,    //no entry
};

enum ENUM_PRINT_MODE{
   DETAILED = 0,        //detailed
   BASIC = 1,           //basic
   NAME = 2,            //only name
   NONE = 3             //do not display
};

class TradingAgent: public TrailingStop{
   public:
      void TradingAgent(string name="", long magic=12345, ENUM_PRINT_MODE print_mode=DETAILED, ENUM_TRADE_MODE trade_mode=LONG_AND_SHORT, ENUM_POSITION_HANDLING position_handling=LONG_SHORT, 
                        bool autoLots=true, double basic_lots=0.1, bool autoSLwidth=true, double startSL=15, double basic_SLwidth=10, double risk=4,
                        int maxPositionsBuy=1, int maxPositionsSell=1);
      void ~TradingAgent(void);
      bool Init(int accountNum, string name="", long magic=12345, ENUM_PRINT_MODE print_mode=DETAILED, ENUM_TRADE_MODE trade_mode=LONG_AND_SHORT, ENUM_POSITION_HANDLING position_handling=LONG_SHORT, 
                bool autoLots=true, double basic_lots=0.1, bool autoSLwidth=true, double startSL=15, double basic_SLwidth=10, double risk=4,
                int maxPositionsBuy=1, int maxPositionsSell=1);
      bool CanTrade(void);
      double CalcBreakEvenBuy(void);
      double CalcBreakEvenSell(void);
      double CalcLots(void);
      double CalcTrailingWidthSL(void);
      void TradeUpdate(void);
      void TradeClose(void);
      void ZeroClose(void);
      void Trade(void);
      // Print methods
      void PrintName(void);
      void PrintProfit(void);
      void PrintPositions(void);
      void PrintSettings(void);
      void SetPrint(void);
      void UpdatePrint(void);
      
   protected:
      int mAccountNum;
      string mName;
      ENUM_PRINT_MODE mPrintMode;
      ENUM_TRADE_MODE mTradeMode;
      ENUM_POSITION_HANDLING mPositionHandling;
      bool mAutoLots;
      bool mAutoTrailing;
      int mMaxPositionsBuy;
      int mMaxPositionsSell;
      double mRisk;
      double mBasicLots;
      double mTickValue;
};

TradingAgent::TradingAgent(string name="", long magic=12345, ENUM_PRINT_MODE print_mode=DETAILED, ENUM_TRADE_MODE trade_mode=LONG_AND_SHORT, ENUM_POSITION_HANDLING position_handling=LONG_SHORT, 
                           bool autoLots=true, double basic_lots=0.1, bool autoSLwidth=true, double startSL=15, double basic_SLwidth=10, double risk=4,
                           int maxPositionsBuy=1, int maxPositionsSell=1)
                           :TrailingStop(magic, startSL, basic_SLwidth, position_handling){
   mName = name;
   mPrintMode = print_mode;
   mTradeMode = trade_mode;
   mPositionHandling = position_handling;
   mAutoLots = autoLots;
   mAutoTrailing = autoSLwidth;
   mMaxPositionsBuy = maxPositionsBuy;
   mMaxPositionsSell = maxPositionsSell;
   mRisk = risk;
   mBasicLots = basic_lots;
}

TradingAgent::~TradingAgent(void){
   ObjectsDeleteAll(0,0,-1);
}

bool TradingAgent::Init(int accountNum, string name="", long magic=12345, ENUM_PRINT_MODE print_mode=DETAILED, ENUM_TRADE_MODE trade_mode=LONG_AND_SHORT, ENUM_POSITION_HANDLING position_handling=LONG_SHORT, 
                   bool autoLots=true, double basic_lots=0.1, bool autoSLwidth=true, double startSL=15, double basic_SLwidth=10, double risk=4, 
                   int maxPositionsBuy=1, int maxPositionsSell=1){
   TSInit(magic, startSL, basic_SLwidth, position_handling);
   mAccountNum = accountNum;
   mName = name;
   mPrintMode = print_mode;
   mTradeMode = trade_mode;
   mPositionHandling = position_handling;
   mAutoLots = autoLots;
   mAutoTrailing = autoSLwidth;
   mMaxPositionsBuy = maxPositionsBuy;
   mMaxPositionsSell = maxPositionsSell;
   mRisk = risk;
   mBasicLots = basic_lots;
   
   if(mAccountNum == NULL) return true;
   else return (mAccountNum == Login() || TradeMode() == "Demo");
}

bool TradingAgent::CanTrade(void){
   MqlDateTime time;
   TimeGMT(time);
   datetime current = TimeCurrent();
   if(time.day_of_week == FRIDAY){
      datetime from, to;
      if(SymbolInfoSessionTrade(_Symbol, FRIDAY, 0, from, to)){
         if(to < current) return false;
      }
   }
   if(time.day_of_week == SATURDAY){
      return false;
   }
   if(time.day_of_week == SUNDAY){
      datetime from, to;
      if(SymbolInfoSessionTrade(_Symbol, SUNDAY, 0, from, to)){
         if(current < from) return false;
      }
   }
   return true;
}

double TradingAgent::CalcBreakEvenBuy(void){
   CPositionInfo mPosition;
   double price=0;
   double lots=0;
   for(int i=0; i<PositionsTotal(); i++){
      if(!mPosition.SelectByIndex(i)) continue;
      if(mPosition.Symbol() != _Symbol) continue;
      if(mPosition.PositionType()==POSITION_TYPE_BUY){
         price = (price*lots+mPosition.PriceOpen()*mPosition.Volume())/(lots+mPosition.Volume());
         lots += mPosition.Volume();
      }
   }
   return NormalizeDouble(price,_Digits);
}

double TradingAgent::CalcBreakEvenSell(void){
   CPositionInfo mPosition;
   double price=0;
   double lots=0;
   for(int i=0; i<PositionsTotal(); i++){
      if(!mPosition.SelectByIndex(i)) continue;
      if(mPosition.Symbol() != _Symbol) continue;
      if(mPosition.PositionType()==POSITION_TYPE_SELL){
         price = (price*lots+mPosition.PriceOpen()*mPosition.Volume())/(lots+mPosition.Volume());
         lots += mPosition.Volume();
      }
   }
   return NormalizeDouble(price,_Digits);
}

double TradingAgent::CalcLots(void){
   double LotSize = -1;
   if(mAutoLots){
      LotSize = NormalizeDouble(FreeMargin()*mRisk/100*AccountInfoInteger(ACCOUNT_LEVERAGE)/100000,2);
   }
   else
      LotSize = mBasicLots;
   if(LotSize<SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN))
      LotSize = -1;
   else if(LotSize>SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX))
      LotSize = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   return NormalizeDouble(LotSize,2);
}

// TODO: update based on the position opening time
double TradingAgent::CalcTrailingWidthSL(void){
   return NormalizeDouble(mWidthSL,_Digits);
}

void TradingAgent::TradeUpdate(void){
   CalcBreakEven();
   if(mAutoTrailing) 
      UpdateSL(CalcTrailingWidthSL());
   else 
      UpdateSL();
}

void TradingAgent::TradeClose(void){
   switch(mPositionHandling){
      case(NETTING):
         if(ShouldCloseAll()){
            OrderCloseAll();
            ResetLines("");
         }
         break;
      case(LONG_SHORT):
         if(ShouldCloseBuy()){
            OrderCloseAllBuy();
            ResetLines("BUY");
         }
         if(ShouldCloseSell()){
            OrderCloseAllSell();
            ResetLines("SELL");
         }
         break;
      case(HEDGING):
         if(ShouldCloseBuy()){
            long ticket = GetLowestBuyTicket();
            if(ticket>0) OrderClose(ticket);
            ResetLines("BUY");
         }
         if(ShouldCloseSell()){
            long ticket = GetHighestSellTicket();
            if(ticket>0) OrderClose(ticket);
            ResetLines("SELL");
         }
         break;
      default: break;
   }
}

void TradingAgent::ZeroClose(void){
   
}

void TradingAgent::Trade(void){
   TradeUpdate();
   TradeClose();
   UpdatePrint();
}

void TradingAgent::PrintName(void){
   ObjectCreate(0,"Name",OBJ_LABEL,0,0,0);
   ObjectSetString(0,"Name",OBJPROP_TEXT,mName);
   ObjectSetString(0,"Name",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Name",OBJPROP_FONTSIZE,15);
   ObjectSetInteger(0,"Name",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Name",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"Name",OBJPROP_YDISTANCE,20);
}

void TradingAgent::PrintProfit(void){
   ObjectCreate(0,"Profit",OBJ_LABEL,0,0,0);
   ObjectSetString(0,"Profit",OBJPROP_TEXT,"Profit: "+(string)CalcProfitAll());
   ObjectSetString(0,"Profit",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Profit",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Profit",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Profit",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"Profit",OBJPROP_YDISTANCE,45);
}

void TradingAgent::PrintPositions(void){
   ObjectCreate(0,"Positions",OBJ_LABEL,0,0,0);
   //ObjectSetString(0,"Positions",OBJPROP_TEXT,"Positions: "+(string)PositionsTotal());
   ObjectSetString(0,"Positions",OBJPROP_TEXT,"Long: "+(string)PositionsBuy()+"    Short: "+(string)PositionsSell());
   ObjectSetString(0,"Positions",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Positions",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Positions",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Positions",OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,"Positions",OBJPROP_YDISTANCE,45);
}

void TradingAgent::PrintSettings(void){
   ObjectCreate(0,"Settings",OBJ_LABEL,0,0,0);
   ObjectSetString(0,"Settings",OBJPROP_TEXT,"Trade Mode: "+ TradeMode(mTradeMode));
   ObjectSetString(0,"Settings",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Settings",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Settings",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Settings",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"Settings",OBJPROP_YDISTANCE,65);
   
   ObjectCreate(0,"Settings0",OBJ_LABEL,0,0,0);
   ObjectSetString(0,"Settings0",OBJPROP_TEXT,"Position Handling: "+PositionMode(mPositionHandling));
   ObjectSetString(0,"Settings0",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Settings0",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Settings0",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Settings0",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"Settings0",OBJPROP_YDISTANCE,85);
   
   ObjectCreate(0,"Settings1",OBJ_LABEL,0,0,0);
   ObjectSetString(0,"Settings1",OBJPROP_TEXT,"Auto Lots: "+(string)mAutoLots+"  Auto Trailing: "+(string)mAutoTrailing);
   ObjectSetString(0,"Settings1",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Settings1",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Settings1",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Settings1",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"Settings1",OBJPROP_YDISTANCE,105);
   
   ObjectCreate(0,"Settings2",OBJ_LABEL,0,0,0);
   ObjectSetString(0,"Settings2",OBJPROP_TEXT,"Risk: "+(string)mRisk+" %");
   ObjectSetString(0,"Settings2",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Settings2",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Settings2",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Settings2",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"Settings2",OBJPROP_YDISTANCE,125);
}

void TradingAgent::SetPrint(void){
   switch(mPrintMode){
      case(DETAILED):
         PrintName();
         PrintProfit();
         PrintPositions();
         PrintSettings();
         break;
      case(BASIC):
         PrintName();
         PrintProfit();
         PrintPositions();
         break;
      case(NAME):
         PrintName();
         break;
      default: break;
   }
}

void TradingAgent::UpdatePrint(void){
   if(mPrintMode == DETAILED || mPrintMode == BASIC){
      PrintProfit();
      PrintPositions();
   }
}

string PositionMode(ENUM_POSITION_HANDLING mode){
   string pos_mode;
   switch(mode){
      case(NETTING): 
         pos_mode="NETTING";
         break;
      case(LONG_SHORT):
         pos_mode="LONG/SHORT NETTING";
         break;
      case(HEDGING):
         pos_mode="HEDGING";
         break;
   }
   return pos_mode;
}

string TradeMode(ENUM_TRADE_MODE mode){
   string trade_mode;
   switch(mode){
      case(LONG_AND_SHORT): 
         trade_mode="LONG & SHORT";
         break;
      case(LONG_ONLY):
         trade_mode="LONG ONLY";
         break;
      case(SHORT_ONLY):
         trade_mode="SHORT ONLY";
         break;
      default:
         trade_mode="DON'T TAKE POSITONS";
         break;
   }
   return trade_mode;
}