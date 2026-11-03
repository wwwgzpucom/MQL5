//+------------------------------------------------------------------+
//|                                                TradingHelper.mqh |
//|                                       Copyright 2026, wwwgzpucom |
//|                         https://one.toexness.com/intl/zh/a/30852 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                  TradeHelper.mqh |
//|             Copyright 2018, Kashu Yamazaki, All Rights Reserved. |
//|                                      https://Kashu7100.github.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, wwwgzpucom"
#property link        "https://one.toexness.com/intl/zh/a/30852"
#property strict

#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>

class TradingHelper: public CAccountInfo{
   public:
      void TradingHelper(long magic);
      virtual void ~TradingHelper(void);
      void THInit(long magic);
      string TradeMode(void);
      string CheckBroker(){return Company();};
      datetime GetPositionTime(ulong ticket);
      int PositionsBuy(void);
      int PositionsSell(void);
      double LotsBuy(void);
      double LotsSell(void);
      double CalcProfitBuy(void);
      double CalcProfitSell(void);
      double CalcProfitAll(void);
      void ModifyOrderSL(ulong  ticket, double sl);
      void OrderBuy(double volume=0.1, int deviation=3, double sl=0, double tp=0);
      void OrderSell(double volume=0.1, int deviation=3, double sl=0, double tp=0);
      void OrderCross(double volume=0.1, int deviation=3, double slBuy=0,double tpBuy=0, double slSell=0, double tpSell=0);
      long GetLowestBuyTicket(void);
      long GetHighestSellTicket(void);
      long GetNewestPositionTicket(void); //TODO
      long GetOldestPositionTicket(void); //TODO
      void OrderClose(ulong ticket);
      void OrderCloseAll(void);         
      void OrderCloseAllBuy(void);
      void OrderCloseAllSell(void);
   protected:
      long mMagic;
};

TradingHelper::TradingHelper(long magic){
   THInit(magic);
   printf(CheckBroker());
}

TradingHelper::~TradingHelper(void){
}

void TradingHelper::THInit(long magic){
   mMagic = magic;
}

string TradingHelper::TradeMode(void){
   string str;
   switch((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)){
      case ACCOUNT_TRADE_MODE_DEMO   : str="Demo"; break;
      case ACCOUNT_TRADE_MODE_CONTEST: str="Contest"; break;
      case ACCOUNT_TRADE_MODE_REAL   : str="Real"; break;
      default                        : str="Unknown";
   }
   return str;
}

datetime TradingHelper::GetPositionTime(ulong ticket){
   if(PositionSelectByTicket(ticket))
      return (datetime)PositionGetInteger(POSITION_TIME);
   return (datetime) 0;
}

int TradingHelper::PositionsBuy(void){
   int count=0;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         count++;
      }
   }
   return count;
}

int TradingHelper::PositionsSell(void){
   int count=0;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         count++;
      }
   }
   return count;
}

double TradingHelper::LotsBuy(void){
   double lots=0;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         lots+=PositionGetDouble(POSITION_VOLUME);
      }
   }  
   return lots;
}

double TradingHelper::LotsSell(void){
   double lots=0;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         lots+=PositionGetDouble(POSITION_VOLUME);
      }
   }  
   return lots;
}

double TradingHelper::CalcProfitAll(void){
   CPositionInfo mPosition;
   double profit = 0;
   for(int i=0; i<PositionsTotal(); i++){
      if(!mPosition.SelectByIndex(i)) continue;
      if(mPosition.Symbol()==_Symbol)
         profit += (mPosition.Profit());
   }
   return profit;
}

double TradingHelper::CalcProfitBuy(void){
   double profit = 0;
   for(int i=0; i<PositionsTotal(); i++){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         profit+=PositionGetDouble(POSITION_PROFIT);
      }
   }
   return profit;
}

double TradingHelper::CalcProfitSell(void){
   double profit = 0;
   for(int i=0; i<PositionsTotal(); i++){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         profit+=PositionGetDouble(POSITION_PROFIT);
      }
   }
   return profit;
}

void TradingHelper::ModifyOrderSL(ulong  ticket, double sl){
   MqlTradeRequest request={0};
   MqlTradeResult result={0};
   if(PositionSelectByTicket(ticket)){
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); 
      request.position  = ticket;
      request.action    = TRADE_ACTION_SLTP;
      request.symbol    = position_symbol;
      request.sl        = NormalizeDouble(sl,digits);
      request.tp        = 0;
      request.magic     = mMagic; 
      if(!OrderSend(request,result))
         PrintFormat("OrderSend error %d",GetLastError());
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   }
}

void TradingHelper::OrderBuy(double volume=0.1, int deviation=3, double sl=0, double tp=0){
   /*
   Args:
      volume (double): order volume [lots]
      deviation (int): send order within the deviation [points]
      sl (double): stop loss [points]
      tp (double): take profit [points] 
   */
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   request.action       = TRADE_ACTION_DEAL;
   request.magic        = mMagic;
   request.symbol       = _Symbol;
   request.volume       = fmin(fmax(volume, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   request.price        = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   request.type_filling = ORDER_FILLING_IOC;
   request.deviation    = deviation;
   request.type         = ORDER_TYPE_BUY;
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(sl > 0) request.sl = NormalizeDouble(mTick.ask - sl*_Point,_Digits);
      if(tp > 0) request.tp = NormalizeDouble(mTick.ask + tp*_Point,_Digits);
   }
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
}

void TradingHelper::OrderSell(double volume=0.1, int deviation=3, double sl=0, double tp=0){
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   request.action       = TRADE_ACTION_DEAL;
   request.magic        = mMagic;
   request.symbol       = _Symbol;
   request.volume       = fmin(fmax(volume, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   request.price        = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   request.type_filling = ORDER_FILLING_IOC;
   request.deviation    = deviation;
   request.type         = ORDER_TYPE_SELL;
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(sl > 0) request.sl = NormalizeDouble(mTick.bid + sl*_Point,_Digits);
      if(tp > 0) request.tp = NormalizeDouble(mTick.bid - tp*_Point,_Digits);
   }
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
}

void TradingHelper::OrderCross(double volume=0.1,int deviation=3, double slBuy=0,double tpBuy=0, double slSell=0, double tpSell=0){
   OrderBuy(volume, deviation, slBuy, tpBuy);
   OrderSell(volume, deviation, slSell, tpSell);
}

long TradingHelper::GetLowestBuyTicket(void){
   long ticket = -1;
   double lowest_open = 1000;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ulong  magic = PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);                        
      
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         if(PositionGetDouble(POSITION_PRICE_OPEN) < lowest_open){
            lowest_open = PositionGetDouble(POSITION_PRICE_OPEN);
            ticket = position_ticket;
         }
      }
   }
   return ticket;
}

long TradingHelper::GetHighestSellTicket(void){
   long ticket = -1;
   double highest_open = 0;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      ulong  magic = PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);                        
      
      if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         if(PositionGetDouble(POSITION_PRICE_OPEN) > highest_open){
            highest_open = PositionGetDouble(POSITION_PRICE_OPEN);
            ticket = position_ticket;
         }
      }
   }
   return ticket;
}

//TODO
long TradingHelper::GetNewestPositionTicket(void){
   long ticket = -1;
   
   return ticket;
}

//TODO
long TradingHelper::GetOldestPositionTicket(void){
   long ticket = -1;
   
   return ticket;
}

void TradingHelper::OrderClose(ulong ticket){
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   if(PositionSelectByTicket(ticket)){
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
      ulong  magic = PositionGetInteger(POSITION_MAGIC);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      request.action    = TRADE_ACTION_DEAL;
      request.magic     = mMagic;
      request.position  = ticket;       
      request.symbol    = position_symbol;       
      request.volume    = volume;                
      request.deviation = 3;                         
      
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_BID);
         request.type   = ORDER_TYPE_SELL;
         request.type_filling = ORDER_FILLING_IOC;
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      }
      
      if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         request.type   = ORDER_TYPE_BUY;
         request.type_filling = ORDER_FILLING_IOC;
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      }
   }
}

void TradingHelper::OrderCloseAllBuy(void){
   MqlTradeRequest request;
   MqlTradeResult  result;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
      ulong  magic = PositionGetInteger(POSITION_MAGIC);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ZeroMemory(request);
      ZeroMemory(result);
      request.action    = TRADE_ACTION_DEAL;
      request.magic     = mMagic;   
      request.position  = position_ticket;       
      request.symbol    = position_symbol;       
      request.volume    = volume;                
      request.deviation = 3;                         
      
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_BID);
         request.type   = ORDER_TYPE_SELL;
         request.type_filling = ORDER_FILLING_IOC;
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      }
   }
}

void TradingHelper::OrderCloseAllSell(void){
   MqlTradeRequest request;
   MqlTradeResult  result;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
      ulong  magic = PositionGetInteger(POSITION_MAGIC);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ZeroMemory(request);
      ZeroMemory(result);
      request.action    = TRADE_ACTION_DEAL;
      request.magic     = mMagic;     
      request.position  = position_ticket;       
      request.symbol    = position_symbol;      
      request.volume    = volume;                
      request.deviation = 3;                     
                 
      if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         request.type   = ORDER_TYPE_BUY;
         request.type_filling = ORDER_FILLING_IOC;
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      }
   }
}

void TradingHelper::OrderCloseAll(void){
   MqlTradeRequest request;
   MqlTradeResult  result;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
      ulong  magic = PositionGetInteger(POSITION_MAGIC);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ZeroMemory(request);
      ZeroMemory(result);
      request.action    = TRADE_ACTION_DEAL;
      request.magic     = mMagic;
      request.position  = position_ticket;
      request.symbol    = position_symbol;      
      request.volume    = volume;                
      request.deviation = 3;                                     
      
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_BID);
         request.type   = ORDER_TYPE_SELL;
         request.type_filling = ORDER_FILLING_IOC;
      }
      else if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         request.type   = ORDER_TYPE_BUY;
         request.type_filling = ORDER_FILLING_IOC;
      }
      if(!OrderSend(request,result))
         PrintFormat("OrderSend error %d",GetLastError());
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   }
}