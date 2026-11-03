//+------------------------------------------------------------------+
//|                                                 TrailingStop.mqh |
//|                                       Copyright 2026, wwwgzpucom |
//|                         https://one.toexness.com/intl/zh/a/30852 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, wwwgzpucom"
#property link        "https://one.toexness.com/intl/zh/a/30852"
#property strict
#include <TradingHelper.mqh>

enum ENUM_LINE_TYPE{
   LINE_SL = 0,
   LINE_TP = 1,
   LINE_BE = 2,
};

enum ENUM_POSITION_HANDLING{
   NETTING = 0,      //Netting
   LONG_SHORT = 1,   //Long/Short Netting
   HEDGING = 2,      //Hedging
};

struct LineBase{
   ENUM_LINE_TYPE TYPE;
   double BUY;
   double SELL;
}; 

class DrawLine{
   public:
      void Create(LineBase& line);
      void Move(LineBase& line);
      void Reset(string o_type, LineBase& line);
      void Delete(LineBase& line);
};

void DrawLine::Create(LineBase& line){
   switch((ENUM_LINE_TYPE)line.TYPE){
      case(LINE_SL):
         ObjectCreate(0,"LineSLBUY", OBJ_HLINE,0,0,0);
         ObjectSetInteger(0,"LineSLBUY", OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0,"LineSLBUY", OBJPROP_COLOR, Red);
         ObjectMove(0,"LineSLBUY",0,1,line.BUY);
         
         ObjectCreate(0,"LineSLSELL",OBJ_HLINE,0,0,0);
         ObjectSetInteger(0,"LineSLSELL", OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0,"LineSLSELL", OBJPROP_COLOR, Red);
         ObjectMove(0,"LineSLSELL",0,1,line.SELL);
         break;
      case(LINE_TP):
         ObjectCreate(0,"LineTPBUY", OBJ_HLINE,0,0,0);
         ObjectSetInteger(0,"LineTPBUY", OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0,"LineTPBUY", OBJPROP_COLOR, Blue);
         ObjectMove(0,"LineTPBUY",0,1,line.BUY);
         
         ObjectCreate(0,"LineTPSELL",OBJ_HLINE,0,0,0);
         ObjectSetInteger(0,"LineTPSELL", OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0,"LineTPSELL", OBJPROP_COLOR, Blue);
         ObjectMove(0,"LineTPSELL",0,1,line.SELL);
         break;
      case(LINE_BE):
         ObjectCreate(0,"LineBEBUY", OBJ_HLINE,0,0,0);
         ObjectSetInteger(0,"LineBEBUY", OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0,"LineBEBUY", OBJPROP_COLOR, White);
         ObjectMove(0,"LineBEBUY",0,1,line.BUY);
         
         ObjectCreate(0,"LineBESELL",OBJ_HLINE,0,0,0);
         ObjectSetInteger(0,"LineBESELL", OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0,"LineBESELL", OBJPROP_COLOR, White);
         ObjectMove(0,"LineBESELL",0,1,line.SELL);
         break;
      default: break;
   }
}

void DrawLine::Move(LineBase& line){
   switch((ENUM_LINE_TYPE)line.TYPE){
      case(LINE_SL):
         ObjectMove(0,"LineSLBUY",0,1,line.BUY);
         ObjectMove(0,"LineSLSELL",0,1,line.SELL);
         break; 
      case(LINE_TP):
         ObjectMove(0,"LineTPBUY",0,1,line.BUY);
         ObjectMove(0,"LineTPSELL",0,1,line.SELL);
         break;
      case(LINE_BE):
         ObjectMove(0,"LineBEBUY",0,1,line.BUY);
         ObjectMove(0,"LineBESELL",0,1,line.SELL);
         break;
      default: break;
   }
}

void DrawLine::Reset(string o_type, LineBase &line){
   switch((ENUM_LINE_TYPE)line.TYPE){
      case(LINE_SL):
         if(o_type=="BUY"){
            line.BUY = 0;
            ObjectMove(0,"LineSLBUY",0,1,line.BUY);
         }
         else if(o_type=="SELL"){
            line.SELL = 10000;
            ObjectMove(0,"LineSLSELL",0,1,line.SELL);
         }
         break; 
      case(LINE_TP):
         if(o_type=="BUY"){
            line.BUY = 10000;
            ObjectMove(0,"LineTPBUY",0,1,line.BUY);
         }
         else if(o_type=="SELL"){
            line.SELL = 0;
            ObjectMove(0,"LineTPSELL",0,1,line.SELL);
         }
         break;
      case(LINE_BE):
         if(o_type=="BUY"){
            line.BUY = 10000;
            ObjectMove(0,"LineBEBUY",0,1,line.BUY);
         }
         else if(o_type=="SELL"){
            line.SELL = 0;
            ObjectMove(0,"LineBESELL",0,1,line.SELL);
         }
         break;
      default: break;
   }
}

void DrawLine::Delete(LineBase& line){
   switch((ENUM_LINE_TYPE)line.TYPE){
      case(LINE_SL):
         ObjectDelete(0,"LineSLBUY");
         ObjectDelete(0,"LineSLSELL");
         break;
      case(LINE_TP):
         ObjectDelete(0,"LineTPBUY");
         ObjectDelete(0,"LineTPSELL");
         break;
      case(LINE_BE):
         ObjectDelete(0,"LineBEBUY");
         ObjectDelete(0,"LineBESELL");
         break;
      default: break;
   }
}

class TrailingStop: public TradingHelper{
   public:
      void TrailingStop(long magic=58218, double startSL=20, double SLwidth=10, ENUM_POSITION_HANDLING position_handling=LONG_SHORT);
      void ~TrailingStop(void);
      void TSInit(long magic=58218, double startSL=20, double SLwidth=10, ENUM_POSITION_HANDLING position_handling=LONG_SHORT);
      void CalcBreakEven(void);
      void ZeroStop(void);
      void UpdateSL(void);
      void UpdateSL(double SLwidth);
      void UpdateZERO(void);
      void ResetLines(string o_type);
      bool ShouldCloseBuy(void);
      bool ShouldCloseSell(void);
      bool ShouldCloseAll(void);
   protected:
      ENUM_POSITION_HANDLING mPositionHandling;
      double mStartSL;
      double mWidthSL;
      LineBase mSL;
      LineBase mBE;
      LineBase mZERO;
      DrawLine mLine;
};

TrailingStop::TrailingStop(long magic=58218, double startSL=20, double SLwidth=10, ENUM_POSITION_HANDLING position_handling=LONG_SHORT)
:TradingHelper(magic){
   TSInit(magic, startSL, SLwidth, position_handling);
}

TrailingStop::~TrailingStop(void){
   mLine.Delete(mSL);
   mLine.Delete(mBE);
}

void TrailingStop::TSInit(long magic=58218, double startSL=20, double SLwidth=10, ENUM_POSITION_HANDLING position_handling=LONG_SHORT){
   THInit(magic);
   mPositionHandling = position_handling;
   mStartSL = startSL*_Point;
   mWidthSL = SLwidth*_Point;
   mSL.TYPE = LINE_SL;
   mSL.BUY = 0;
   mSL.SELL = 10000;
   mBE.TYPE = LINE_BE;
   mBE.BUY = 10000;
   mBE.SELL = 0;
   mZERO.TYPE = LINE_SL;
   mZERO.BUY = 0;
   mZERO.SELL = 10000;
   mLine.Create(mSL);
   mLine.Create(mBE);
   mLine.Create(mZERO);
}

//TODO: take swap into consideration
void TrailingStop::CalcBreakEven(void){
   CPositionInfo mPosition;
   double price[2] = {0,0};
   double lots[2] = {0,0};
   if(PositionsTotal()==0) return;
   switch(mPositionHandling){
      case(NETTING):        
         for(int i=0; i<PositionsTotal(); i++){
            if(!mPosition.SelectByIndex(i)) continue;
            if(mPosition.Symbol() != _Symbol) continue;
            if(mPosition.PositionType()==POSITION_TYPE_BUY){
               price[0] = (price[0]*lots[0]+mPosition.PriceOpen()*mPosition.Volume())/(lots[0]+mPosition.Volume());
               lots[0] += mPosition.Volume();
            }
            else if(mPosition.PositionType()==POSITION_TYPE_SELL){
               price[1] = (price[1]*lots[1]+mPosition.PriceOpen()*mPosition.Volume())/(lots[1]+mPosition.Volume());
               lots[1] += mPosition.Volume();
            }
         }
         if(lots[0] > lots[1]){
            price[0] += (price[0]-price[1])*lots[1]/(lots[0]-lots[1]);
            price[1] = 0;
         }
         else if(lots[0] < lots[1]){
            price[1] -= (price[0]-price[1])*lots[0]/(lots[1]-lots[0]);
            price[0] = 0;
         }
         else{
            price[0] = 0;
            price[1] = 0;
            Alert("There should be a difference between in total volume for long and short positions. Trailing Style: Netting"); 
         }
         break;
      case(LONG_SHORT):    
         for(int i=0; i<PositionsTotal(); i++){
            if(!mPosition.SelectByIndex(i)) continue;
            if(mPosition.Symbol() != _Symbol) continue;
            if(mPosition.PositionType()==POSITION_TYPE_BUY){
               price[0] = (price[0]*lots[0]+mPosition.PriceOpen()*mPosition.Volume())/(lots[0]+mPosition.Volume());
               lots[0] += mPosition.Volume();
            }
            else if(mPosition.PositionType()==POSITION_TYPE_SELL){
               price[1] = (price[1]*lots[1]+mPosition.PriceOpen()*mPosition.Volume())/(lots[1]+mPosition.Volume());
               lots[1] += mPosition.Volume();
            }
         }
         break;
      case(HEDGING):{
         long buy_ticket = GetLowestBuyTicket();
         if(buy_ticket>0 && mPosition.SelectByTicket(buy_ticket)) 
            price[0] = mPosition.PriceOpen();
         
         long sell_ticket = GetHighestSellTicket();
         if(sell_ticket>0 && mPosition.SelectByTicket(sell_ticket)) 
            price[1] = mPosition.PriceOpen();
         }
         break;
      default: break;
   }
   mBE.BUY = (price[0]==0)?(10000):(NormalizeDouble(price[0],_Digits));
   mBE.SELL = NormalizeDouble(price[1],_Digits);
   mLine.Move(mBE);
}

void TrailingStop::ZeroStop(void){
   switch(mPositionHandling){
      case(NETTING):
         for(int i=0; i<PositionsTotal(); i++){
            ulong  position_ticket = PositionGetTicket(i);
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(mBE.BUY > mBE.SELL)
               ModifyOrderSL(position_ticket, mBE.BUY);
            if(mBE.BUY < mBE.SELL)
               ModifyOrderSL(position_ticket, mBE.SELL);
         }
         break;
      case(LONG_SHORT):
         for(int i=0; i<PositionsTotal(); i++){
            ulong  position_ticket = PositionGetTicket(i);
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(type==POSITION_TYPE_BUY)
               ModifyOrderSL(position_ticket, mBE.BUY);
            if(type==POSITION_TYPE_SELL)
               ModifyOrderSL(position_ticket, mBE.SELL);
         }
         break;
      case(HEDGING):{
         long buy_ticket = GetLowestBuyTicket();
         if(buy_ticket>0) ModifyOrderSL(buy_ticket, mBE.BUY);
         long sell_ticket = GetHighestSellTicket();
         if(sell_ticket>0) ModifyOrderSL(sell_ticket, mBE.SELL);
         }
         break;
      default: break;
   }
}

void TrailingStop::UpdateSL(void){
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(mBE.BUY+mStartSL < mTick.bid && mSL.BUY+mWidthSL < mTick.bid)
         mSL.BUY = NormalizeDouble(mTick.bid-mWidthSL,_Digits);
      if(mBE.SELL-mStartSL > mTick.ask && mSL.SELL-mWidthSL > mTick.ask)
         mSL.SELL = NormalizeDouble(mTick.ask+mWidthSL,_Digits);
   }
   mLine.Move(mSL);
}

void TrailingStop::UpdateSL(double SLwidth){
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(mBE.BUY+mStartSL < mTick.bid && mSL.BUY+SLwidth < mTick.bid)
         mSL.BUY = NormalizeDouble(mTick.bid-SLwidth,_Digits);
      if(mBE.SELL-mStartSL > mTick.ask && mSL.SELL-SLwidth > mTick.ask)
         mSL.SELL = NormalizeDouble(mTick.ask+SLwidth,_Digits);
   }
   mLine.Move(mSL);
}

void TrailingStop::UpdateZERO(void){
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      //TODO:compare with positon time
      if(mBE.BUY+10 < mTick.bid && mZERO.BUY+10 < mTick.bid && TimeCurrent()-GetPositionTime(GetNewestPositionTicket()) > 60*3)
         mZERO.BUY = NormalizeDouble(mTick.bid-10,_Digits);
      if(mBE.SELL-10 > mTick.ask && mZERO.SELL-10 > mTick.ask && TimeCurrent()-GetPositionTime(GetNewestPositionTicket()) > 60*3)
         mZERO.SELL = NormalizeDouble(mTick.ask+10,_Digits);
   }
}

void TrailingStop::ResetLines(string o_type){
   if(o_type==""){
      mLine.Reset("BUY",mSL);
      mLine.Reset("SELL",mSL);
      mLine.Reset("BUY",mBE);
      mLine.Reset("SELL",mBE);
      mLine.Reset("BUY",mZERO);
      mLine.Reset("SELL",mZERO);
   } else if(o_type=="BUY"){
      mLine.Reset("BUY",mSL);
      mLine.Reset("BUY",mBE);
      mLine.Reset("BUY",mZERO);
   }
   else if(o_type=="SELL"){
      mLine.Reset("SELL",mSL);
      mLine.Reset("SELL",mBE);
      mLine.Reset("SELL",mZERO);
   }
}

bool TrailingStop::ShouldCloseBuy(void){
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(mSL.BUY >= mTick.bid || mZERO.BUY >= mTick.bid) 
         return true;
      else
         return false;
   }
   else
      return false;
}

bool TrailingStop::ShouldCloseSell(void){
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(mSL.SELL <= mTick.ask || mZERO.SELL <= mTick.ask)
         return true;
      else
         return false;
   }
   else
      return false;
}

bool TrailingStop::ShouldCloseAll(void){
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(mSL.SELL <= mTick.ask || mZERO.SELL <= mTick.ask)
         return true;
      if(mSL.BUY >= mTick.bid || mZERO.BUY >= mTick.bid)
         return true;
      else
         return false;
   }
   else
      return false;
}