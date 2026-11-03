//+------------------------------------------------------------------+
//|                                       NovaUltimateTradePanel.mq5 |
//|                                       Copyright 2026, wwwgzpucom |
//|                         https://one.toexness.com/intl/zh/a/30852 |
//+------------------------------------------------------------------+

#include <Trade\PositionInfo.mqh>               // Public Class CPositionInfo
#include <Trade\SymbolInfo.mqh>                 // Public Class CSymbolInfo
#include <Trade\Trade.mqh>                      // Public Clas CTrade
CPositionInfo  objPosition;                     // Properties of open position
CSymbolInfo    objSymbol;                       // symbol info object
CTrade         objTrade;

﻿//+------------------------------------------------------------------+
//|                                       NovaUltimateTradePanel.mq5 |
//|                                       Copyright 2026, wwwgzpucom |
//|                         https://one.toexness.com/intl/zh/a/30852 |
//+------------------------------------------------------------------+

#property copyright   "Copyright 2026, wwwgzpucom"
#property link        "https://one.toexness.com/intl/zh/a/30852"
#property description "全能交易面板：快速下单、拖线SL/TP、组单、移动止损、对冲与自动平仓"
#property version   "1.00"



#include <Controls/Dialog.mqh>
#include <Controls/Button.mqh>
#include <Controls/Panel.mqh>
#include <Controls/Label.mqh>
#include <Controls/ComboBox.mqh>
#include <Controls/Edit.mqh>
#include <Controls/ListView.mqh>
#include <Arrays/ArrayString.mqh>
//#include <Controls/Scrolls.mqh>
//#include <Arrays/ArrayString.mqh>
//#include <Controls/WndClient.mqh>
//#include <Controls\Edit.mqh>

#define SPAN 12
#define DIALOG_WIDTH 581
#define DIALOG_HEIGHT 450
#define UNIT_NUM 150
#define UNIT_WIDTH 44
#define UNIT_HEIGHT 22
//--------------------Panel Functions------------------------//
//---buttononoffunc
string tprun="OFF";
bool tprunclick=false;

string slrun="OFF";
bool slrunclick=false;

string coveragerun="OFF";
bool coveragerunclick=false;

string groupopenrun="OFF";
bool cgroupopenclick=false;

string autobotrun="OFF";
bool autobotrunclick=false;

string earun="OFF";
bool earunclick=false;

string mobileslrun="OFF";
bool mobileslclick=false;

string mobilesllogrun="OFF";
bool mobilesllogclick=false;

string autotpbotlogrun="OFF";
bool autotpbotlogclick=false;

string allowbuyrun="ON";
bool allowbuyclick=false;

string allowsellrun="ON";
bool allowsellclick=false;

string firstruncontrool=NULL;
datetime SecTrigger1;
//--------------

double lotbuy=0.01;
double lotsell=0.01;

double ExtTakeProfit=0.0;
double ExtStopLoss=0.0;
double PendingsLevel=0.0;

ulong magicNumber=10001;
ulong magicNumberTrailling=30001;


bool stoponoff=false;
bool tponoff=false;

bool traillingonoff;
double traillingStep;
double traillingStepx2;
double traillingDistance;
double traillingDistancex2;
bool traillinglog=true;
double traillingloggs[100,3];
bool CloseAreaMode=true;

bool Coverageonoff=false;
bool GroupOpenonoff=false;
double coveragelevel=-100;
double coveragelevelplus=100;

double TotalSellVolume=0.0;
double TotalBuyVolume=0.0;
double CurrentSellVolume=0.0;
double CurrentBuyVolume=0.0;

double DaystartEquity;
datetime DaystartDate;


bool AutoTPBot=false;
double AutoTPBotStopLevel=-10;
double AutoTPBotStepLevel=1;
bool AutoTPBotlog=true;
double AutoTPBotloggs[100,3];

int PanelScreenController=0;
string  comboboxstringVALUE;
int selectedpossticketx;;
//------------------------------------------------------------//
enum DialogElements
  {
   Dialog = 0,

   Panel_Lot,
   Panel_Info,
   Panel_Main,
   Panel_OrderOpener,
   Panel_MobileStop,
   Panel_CloseArea,
   Panel_Coverage,
   Panel_AutoBotTP,
   Panel_GroupOpen,
   Panel_ListCover,
   Panel_DetailedPosControl,
   Panel_DetailedPosControlx2,
//Panel_DetailedPosControlx2x2,

   Label_Lot,
   Label_InfoForEA,
   Label_InfoForEA2,
   Label_Current_Buy_Volume,
   Label_Current_Sell_Volume,
   Label_RunEa,
   Label_EASettings,
   Label_EaIsRun,
   Label_LastHedge,
   Label_AllowBuySell,
   Label_MobileSLText,
   Label_TSLDistanceText,
   Label_TSLStepText,
   Label_CoverageText,
   Label_BalanceEquity,
   Label_ACProfit,
   Label_DailyACProfit,
   Label_Account,
   Label_Server,
   Label_Owner,
   Label_DateAndPing,
   Label_CoverageTextx2,
   Label_AutoBotTPText,
   Label_AutoBotTPTextx2,
   Label_GroupOpenText,
   Label_GroupOpenTextx2,
   Label_ListTicket,
   Label_ListSymbol,
   Label_ListType,
   Label_ListPrice,
   Label_ListTP,
   Label_ListSL,
   Label_ListLOT,
   Label_ListProfit,
   Label_PositionPanelText,

   Label_LogAreaText,
   Label_LogAreaTextx2,

   Label_ChangeLogTextA,
   Label_ChangeLogTextAx2,

   Label_ChangeLogTextB,
   Label_ChangeLogTextBx2,

   Label_ChangeLogTextC,
   Label_ChangeLogTextCx2,

   Label_ChangeLogTextD,
   Label_ChangeLogTextDx2,




   Button_Buy,
   Button_LotUpBuy,
   Button_LotDownBuy,
   Button_Sell,
   Button_LotUppSell,
   Button_LotDownnSell,
   Button_CloseAll,
   Button_OnOff,
   Button_ControlHedgeAll,
   Button_AllowBuy,
   Button_AllowSell,
   Button_InstantCloseBuy,
   Button_InstantCloseSells,
   Button_CloseByTicket,
   Button_CloseMode,
   Button_TPB,
   Button_SLB,
   Button_Reverse,
   Button_MobileSL,
   Button_UpTSLDISTANCE,
   Button_DownTSLDISTANCE,
   Button_UpTSLSTEP,
   Button_DownTSLSTEP,
   Button_Coveragex,
   Button_UpCoverage,
   Button_DownCoverage,
   Button_UpTicketStart,
   Button_DownTicketStart,
   Button_UpTicketStop,
   Button_DownTicketStop,
   Button_LogTSL,
   Button_UpCoveragePlus,
   Button_DownCoveragePlus,
   Button_TPUp,
   Button_TPDown,
   Button_SLUp,
   Button_SLDown,
   Button_UpAutoBotTPStop,
   Button_DownAutoBotTPStop,
   Button_UpAutoBotTPStep,
   Button_DownAutoBotTPStep,
   Button_AutoBotTPRun,
   Button_GroupOpenOnOff,
   Button_LogAutoBotTP,
   Button_GoPanel1,
   Button_GoPanel2,
   Button_SelectPoss,



   Edit_LotBuy,
   Edit_LotSell,
   Edit_TicketStart,
   Edit_TicketStop,
   Edit_TPLVL,
   Edit_SLLVL,
   Edit_TSLDistance,
   Edit_TSLStep,
   Edit_Coverage,
   Edit_CoveragePlus,
   Edit_AutoBotTPStop,
   Edit_AutoBotTPStep,
//Edit_LogValues,

   Edit_LogA,
   Edit_LogB,
   Edit_LogC,
   Edit_LogD,

   ComboBox_PairGroup,
   ComboBox_ListMode,
//ComboBox_SetLogValues,
//ComboBox_LogValues,

   List_Orderx1,
   List_Orderx2,
   List_Orderx3,
   List_Orderx4,
   List_Orderx5,
   List_Orderx6,
   List_Orderx7,
   List_Orderx8,

  };



enum Coordinates {X1, Y1, X2, Y2};
int XY[UNIT_NUM][4];
string N[UNIT_NUM];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetCoordinates()
  {
   XY[Dialog][X1] = 50;
   XY[Dialog][Y1] = 5;
   XY[Dialog][X2] = XY[Dialog][X1] + DIALOG_WIDTH;
   XY[Dialog][Y2] = XY[Dialog][Y1] + DIALOG_HEIGHT;


   XY[Panel_Main][X1] = 0;
   XY[Panel_Main][Y1] = 0;
   XY[Panel_Main][X2] = DIALOG_WIDTH - 2 * SPAN+5+11;
   XY[Panel_Main][Y2] = DIALOG_HEIGHT-28;

   XY[Panel_OrderOpener][X1] = 0;
   XY[Panel_OrderOpener][Y1] = 67;
   XY[Panel_OrderOpener][X2] = DIALOG_WIDTH/2 - 2 * SPAN+5+16;
   XY[Panel_OrderOpener][Y2] = 288;

   XY[Panel_MobileStop][X1] = 0;
   XY[Panel_MobileStop][Y1] = 225;
   XY[Panel_MobileStop][X2] = DIALOG_WIDTH/2 - 2 * SPAN+5+16;
   XY[Panel_MobileStop][Y2] = 288;//224-287

   XY[Panel_CloseArea][X1] = 286;
   XY[Panel_CloseArea][Y1] = 67;
   XY[Panel_CloseArea][X2] = DIALOG_WIDTH - 2 * SPAN+5+11;
   XY[Panel_CloseArea][Y2] =288;

   XY[Panel_Coverage][X1] = 286;
   XY[Panel_Coverage][Y1] = 195;
   XY[Panel_Coverage][X2] = DIALOG_WIDTH - 2 * SPAN+5+11;
   XY[Panel_Coverage][Y2] = 226;

   XY[Panel_AutoBotTP][X1] = 286;
   XY[Panel_AutoBotTP][Y1] = 225;
   XY[Panel_AutoBotTP][X2] = DIALOG_WIDTH - 2 * SPAN+5+11;
   XY[Panel_AutoBotTP][Y2] = 288;

   XY[Panel_GroupOpen][X1] = 0;
   XY[Panel_GroupOpen][Y1] = 195;
   XY[Panel_GroupOpen][X2] = DIALOG_WIDTH/2 - 2 * SPAN+5+16;
   XY[Panel_GroupOpen][Y2] = 226;

   XY[Panel_ListCover][X1] = 6;
   XY[Panel_ListCover][Y1] = 70;
   XY[Panel_ListCover][X2] = DIALOG_WIDTH - 2 * SPAN+5+5;
// XY[Panel_ListCover][Y2] = 362;
   XY[Panel_ListCover][Y2] = 382;



//PANEL-1 VOLUME
   if(PanelScreenController==0)
     {
      XY[Panel_Lot][X1] = 0;
      XY[Panel_Lot][Y1] = 0;
      XY[Panel_Lot][X2] = DIALOG_WIDTH - 2 * SPAN+5+11;
      XY[Panel_Lot][Y2] = UNIT_HEIGHT + 5 * SPAN/1.3; // *5
     }
   if(PanelScreenController==1)
     {
      XY[Panel_Lot][X1] = 0;
      XY[Panel_Lot][Y1] = 0;
      XY[Panel_Lot][X2] = DIALOG_WIDTH - 2 * SPAN+5+11;
      XY[Panel_Lot][Y2] = UNIT_HEIGHT + 3 * SPAN/1.3;
     }



   XY[Label_Lot][X1] = XY[Panel_Lot][X1] + 78;
   XY[Label_Lot][Y1] = XY[Panel_Lot][Y1] - 8;
//XY[Label_Lot][X2] = XY[Label_Lot][X1] + UNIT_WIDTH;
   XY[Label_Lot][X2] = DIALOG_WIDTH - 2 * SPAN;
   XY[Label_Lot][Y2] = XY[Label_Lot][Y1] + UNIT_HEIGHT;

   XY[Label_InfoForEA][X1] = XY[Panel_Lot][X1] + 27;
   XY[Label_InfoForEA][Y1] = XY[Panel_Lot][Y1] + 34;
   XY[Label_InfoForEA][X2] = XY[Label_InfoForEA][X1] + UNIT_WIDTH;
   XY[Label_InfoForEA][Y2] = XY[Label_InfoForEA][Y1] + UNIT_HEIGHT;

   XY[Label_InfoForEA2][X1] = XY[Panel_Lot][X1]  + 90;
   XY[Label_InfoForEA2][Y1] = XY[Panel_Lot][Y1] + 19;
   XY[Label_InfoForEA2][X2] = XY[Label_InfoForEA2][X1] + UNIT_WIDTH;
   XY[Label_InfoForEA2][Y2] = XY[Label_InfoForEA2][Y1] + UNIT_HEIGHT;


   XY[Label_RunEa][X1] = XY[Panel_Lot][X2]- SPAN*8.7;
   XY[Label_RunEa][Y1] = XY[Panel_Lot][Y2] - SPAN*6.3;
   XY[Label_RunEa][X2] = XY[Label_RunEa][X1] + UNIT_WIDTH;
   XY[Label_RunEa][Y2] = XY[Label_RunEa][Y1] + UNIT_HEIGHT;

//PANEL-2 TRADE

   XY[Panel_Info][X1] = 6;
   XY[Panel_Info][Y1] = 293;
   XY[Panel_Info][X2] = DIALOG_WIDTH - 2 * SPAN+10;
   XY[Panel_Info][Y2] = 416;

//XY[Panel_DetailedPosControlx2x2][X1] = 526;
//XY[Panel_DetailedPosControlx2x2][Y1] = 350;
//XY[Panel_DetailedPosControlx2x2][X2] = DIALOG_WIDTH - 2 * SPAN+10;
//XY[Panel_DetailedPosControlx2x2][Y2] = 382;

   XY[Panel_DetailedPosControlx2][X1] = 6;
   XY[Panel_DetailedPosControlx2][Y1] = 350;
   XY[Panel_DetailedPosControlx2][X2] = DIALOG_WIDTH - 2 * SPAN+10;
   XY[Panel_DetailedPosControlx2][Y2] = 382;

   XY[Panel_DetailedPosControl][X1] = 6;
   XY[Panel_DetailedPosControl][Y1] = 384;
   XY[Panel_DetailedPosControl][X2] = DIALOG_WIDTH - 2 * SPAN+10;
   XY[Panel_DetailedPosControl][Y2] = 416;

   XY[Label_EaIsRun][X1] = XY[Panel_Info][X1] +80;
   XY[Label_EaIsRun][Y1] = XY[Panel_Info][Y1] +-12;
   XY[Label_EaIsRun][X2] = XY[Label_EaIsRun][X1] + UNIT_WIDTH;
   XY[Label_EaIsRun][Y2] = XY[Label_EaIsRun][Y1] + UNIT_HEIGHT;

   XY[Label_EASettings][X1] = XY[Panel_Info][X1] +4;
   XY[Label_EASettings][Y1] = XY[Panel_Info][Y1] -12;
   XY[Label_EASettings][X2] = XY[Label_EASettings][X1] + UNIT_WIDTH;
   XY[Label_EASettings][Y2] = XY[Label_EASettings][Y1] + UNIT_HEIGHT;

   XY[Label_Current_Buy_Volume][X1] = XY[Panel_Info][X1] + 10;
   XY[Label_Current_Buy_Volume][Y1] = XY[Panel_Info][Y1] +47;
   XY[Label_Current_Buy_Volume][X2] = XY[Label_Current_Buy_Volume][X1] + UNIT_WIDTH;
   XY[Label_Current_Buy_Volume][Y2] = XY[Label_Current_Buy_Volume][Y1] + UNIT_HEIGHT;

   XY[Label_Current_Sell_Volume][X1] = XY[Label_Current_Buy_Volume][X1] ;
   XY[Label_Current_Sell_Volume][Y1] = XY[Label_Current_Buy_Volume][Y1] +13;
   XY[Label_Current_Sell_Volume][X2] = XY[Label_Current_Sell_Volume][X1] + UNIT_WIDTH;
   XY[Label_Current_Sell_Volume][Y2] = XY[Label_Current_Sell_Volume][Y1] + UNIT_HEIGHT;



   XY[Button_Buy][X1] = XY[Panel_Lot][X1] +SPAN;
   XY[Button_Buy][Y1] = XY[Panel_Lot][Y2] + SPAN*5;
   XY[Button_Buy][X2] = XY[Button_Buy][X1] + 3 * UNIT_WIDTH - SPAN/3;
   XY[Button_Buy][Y2] = XY[Button_Buy][Y1] +10+ UNIT_HEIGHT;

   XY[Edit_LotBuy][X1] = XY[Panel_Lot][X1]+SPAN;
   XY[Edit_LotBuy][Y1] = XY[Panel_Lot][Y2] +SPAN/1.5;
   XY[Edit_LotBuy][X2] = XY[Edit_LotBuy][X1] + UNIT_WIDTH*2.2;
   XY[Edit_LotBuy][Y2] = XY[Edit_LotBuy][Y1] + UNIT_HEIGHT;



   XY[Button_LotUpBuy][X1] = XY[Panel_Lot][X1] + SPAN*8.8+SPAN+1;
   XY[Button_LotUpBuy][Y1] = XY[Panel_Lot][Y2] + SPAN/1.8;
   XY[Button_LotUpBuy][X2] = XY[Button_LotUpBuy][X1] + UNIT_WIDTH/2;
   XY[Button_LotUpBuy][Y2] = XY[Button_LotUpBuy][Y1] + UNIT_HEIGHT/2;

   XY[Button_LotDownBuy][X1] = XY[Button_LotUpBuy][X1];
   XY[Button_LotDownBuy][Y1] = XY[Button_LotUpBuy][Y2]+ SPAN/3;
   XY[Button_LotDownBuy][X2] = XY[Button_LotDownBuy][X1] + UNIT_WIDTH/2;
   XY[Button_LotDownBuy][Y2] = XY[Button_LotDownBuy][Y1] + UNIT_HEIGHT/2;


   XY[Button_TPUp][X1] = XY[Panel_Lot][X1] + SPAN*8.8+SPAN;
   XY[Button_TPUp][Y1] = XY[Panel_Lot][Y2] + SPAN+86;
   XY[Button_TPUp][X2] = XY[Button_TPUp][X1] + UNIT_WIDTH/2;
   XY[Button_TPUp][Y2] = XY[Button_TPUp][Y1] + UNIT_HEIGHT/2;

   XY[Button_TPDown][X1] = XY[Button_TPUp][X1];
   XY[Button_TPDown][Y1] = XY[Button_TPUp][Y2]+ SPAN/3.5;
   XY[Button_TPDown][X2] = XY[Button_TPDown][X1] + UNIT_WIDTH/2;
   XY[Button_TPDown][Y2] = XY[Button_TPDown][Y1] + UNIT_HEIGHT/2;



   XY[Button_SLUp][X1] = XY[Panel_Lot][X1]+149;
   XY[Button_SLUp][Y1] = XY[Panel_Lot][Y2]+ SPAN+86;
   XY[Button_SLUp][X2] = XY[Button_SLUp][X1] + UNIT_WIDTH/2;
   XY[Button_SLUp][Y2] = XY[Button_SLUp][Y1] + UNIT_HEIGHT/2;


   XY[Button_SLDown][X1] = XY[Button_SLUp][X1];
   XY[Button_SLDown][Y1] = XY[Button_SLUp][Y2]+ SPAN/3.5;
   XY[Button_SLDown][X2] = XY[Button_SLDown][X1] + UNIT_WIDTH/2;
   XY[Button_SLDown][Y2] = XY[Button_SLDown][Y1] + UNIT_HEIGHT/2;



   XY[Button_Sell][X1] = XY[Button_Buy][X1]+136 ;
   XY[Button_Sell][Y1] = XY[Panel_Lot][Y2] + SPAN*5;
//XY[Button_Sell][X1] = XY[Button_Buy][X1]+136;
//XY[Button_Sell][Y1] = XY[Label_Current_Sell_Volume][Y1] +35 + SPAN;
   XY[Button_Sell][X2] = XY[Button_Sell][X1] + 3 * UNIT_WIDTH - SPAN/3;
   XY[Button_Sell][Y2] = XY[Button_Sell][Y1] +10+ UNIT_HEIGHT;


   XY[Edit_LotSell][X1] = XY[Panel_Lot][X1]+168+SPAN;
   XY[Edit_LotSell][Y1] = XY[Panel_Lot][Y2]  +SPAN/1.5;
   XY[Edit_LotSell][X2] = XY[Edit_LotSell][X1] + UNIT_WIDTH*2.2;
   XY[Edit_LotSell][Y2] = XY[Edit_LotSell][Y1] + UNIT_HEIGHT;

   XY[Button_LotUppSell][X1] = XY[Panel_Lot][X1]+149;
   XY[Button_LotUppSell][Y1] = XY[Panel_Lot][Y2]+ SPAN/1.8;
   XY[Button_LotUppSell][X2] = XY[Button_LotUppSell][X1] + UNIT_WIDTH/2;
   XY[Button_LotUppSell][Y2] = XY[Button_LotUppSell][Y1] + UNIT_HEIGHT/2;


   XY[Button_LotDownnSell][X1] = XY[Button_LotUppSell][X1];
   XY[Button_LotDownnSell][Y1] = XY[Button_LotUppSell][Y2]+ SPAN/3;
   XY[Button_LotDownnSell][X2] = XY[Button_LotDownnSell][X1] + UNIT_WIDTH/2;
   XY[Button_LotDownnSell][Y2] = XY[Button_LotDownnSell][Y1] + UNIT_HEIGHT/2;

   if(PanelScreenController==1)
     {
      XY[Button_CloseAll][X1] = XY[Panel_DetailedPosControl][X1] + 230 ;
      XY[Button_CloseAll][Y1] = XY[Panel_DetailedPosControl][Y1] + 5 ;
      XY[Button_CloseAll][X2] = XY[Button_CloseAll][X1]+  3 * UNIT_WIDTH - SPAN/3-40;
      XY[Button_CloseAll][Y2] = XY[Button_CloseAll][Y1]+ UNIT_HEIGHT+1;

      XY[Button_ControlHedgeAll][X1] = XY[Panel_DetailedPosControl][X1]+430;
      XY[Button_ControlHedgeAll][Y1] = XY[Panel_DetailedPosControl][Y1] + 5 ;;
      XY[Button_ControlHedgeAll][X2] = XY[Button_ControlHedgeAll][X1]+  3 * UNIT_WIDTH - SPAN/3-40;
      XY[Button_ControlHedgeAll][Y2] = XY[Button_ControlHedgeAll][Y1]+ UNIT_HEIGHT+1;

      XY[Button_Reverse][X1] = XY[Panel_DetailedPosControl][X1]+330;
      XY[Button_Reverse][Y1] = XY[Panel_DetailedPosControl][Y1]+5 ;
      XY[Button_Reverse][X2] = XY[Button_Reverse][X1]+  3 * UNIT_WIDTH - SPAN/3-40;
      XY[Button_Reverse][Y2] = XY[Button_Reverse][Y1]+ UNIT_HEIGHT+1;

     }
   if(PanelScreenController==0)
     {

      XY[Button_CloseAll][X1] = XY[Panel_CloseArea][X1] + 12 ;
      XY[Button_CloseAll][Y1] = XY[Panel_CloseArea][Y1] + 10 ;
      XY[Button_CloseAll][X2] = XY[Button_CloseAll][X1]+  3 * UNIT_WIDTH - SPAN/3-32;
      XY[Button_CloseAll][Y2] = XY[Button_CloseAll][Y1]+ UNIT_HEIGHT+5;


      XY[Button_Reverse][X1] = XY[Button_CloseAll][X2]+3;
      XY[Button_Reverse][Y1] = XY[Button_CloseAll][Y1]  ;
      XY[Button_Reverse][X2] = XY[Button_Reverse][X1]+ UNIT_WIDTH+22 ;
      XY[Button_Reverse][Y2] = XY[Button_Reverse][Y1]+27;

      XY[Button_ControlHedgeAll][X1] = XY[Button_CloseAll][X1]+169;
      XY[Button_ControlHedgeAll][Y1] = XY[Button_CloseAll][Y1];
      XY[Button_ControlHedgeAll][X2] = XY[Button_ControlHedgeAll][X1]+  3 * UNIT_WIDTH - SPAN/3-33;
      XY[Button_ControlHedgeAll][Y2] = XY[Button_ControlHedgeAll][Y1] + UNIT_HEIGHT+5;

     }


   XY[Button_OnOff][X1] = XY[Panel_Lot][X2]- SPAN*3;
   XY[Button_OnOff][Y1] = XY[Panel_Lot][Y2] - SPAN*5.20;
   XY[Button_OnOff][X2] = XY[Button_OnOff][X1] + UNIT_WIDTH/1.4;
   XY[Button_OnOff][Y2] = XY[Button_OnOff][Y1] + UNIT_HEIGHT/1.3;


   XY[Label_LastHedge][X1] = XY[Panel_Info][X1]+10;
   XY[Label_LastHedge][Y1] = XY[Panel_Info][Y1] +34;
   XY[Label_LastHedge][X2] = XY[Label_LastHedge][X1] + UNIT_WIDTH;
   XY[Label_LastHedge][Y2] = XY[Label_LastHedge][Y1] + UNIT_HEIGHT;


   XY[Button_AllowBuy][X1] = XY[Panel_Lot][X1] +SPAN;
   XY[Button_AllowBuy][Y1] = XY[Panel_Lot][Y2] + SPAN+22;
   XY[Button_AllowBuy][X2] = XY[Button_AllowBuy][X1] + 3 * UNIT_WIDTH - SPAN/3;
   XY[Button_AllowBuy][Y2] = XY[Button_AllowBuy][Y1] +5+ UNIT_HEIGHT-5;

   XY[Button_AllowSell][X1] = XY[Panel_Lot][X1] +136+SPAN;
   XY[Button_AllowSell][Y1] = XY[Panel_Lot][Y2] + SPAN+22;
   XY[Button_AllowSell][X2] = XY[Button_AllowSell][X1] + 3 * UNIT_WIDTH - SPAN/3;
   XY[Button_AllowSell][Y2] = XY[Button_AllowSell][Y1] +5+ UNIT_HEIGHT-5;


   XY[Label_AllowBuySell][X1] = XY[Panel_Info][X1] + 10;
   XY[Label_AllowBuySell][Y1] = XY[Panel_Info][Y1] +8;
   XY[Label_AllowBuySell][X2] = XY[Label_AllowBuySell][X1] + UNIT_WIDTH;
   XY[Label_AllowBuySell][Y2] = XY[Label_AllowBuySell][Y1] + UNIT_HEIGHT;

   XY[Button_InstantCloseBuy][X1] = XY[Button_CloseAll][X1];
   XY[Button_InstantCloseBuy][Y1] = XY[Button_CloseAll][Y2]  + SPAN-8;
   XY[Button_InstantCloseBuy][X2] = XY[Button_InstantCloseBuy][X1]+ 95;
   XY[Button_InstantCloseBuy][Y2] = XY[Button_InstantCloseBuy][Y1] + UNIT_HEIGHT*1.3;

   XY[Button_InstantCloseSells][X1] = XY[Button_CloseAll][X1]+169;
   XY[Button_InstantCloseSells][Y1] = XY[Button_CloseAll][Y2]  + SPAN-8;
   XY[Button_InstantCloseSells][X2] = XY[Button_InstantCloseSells][X1]+ 95;
   XY[Button_InstantCloseSells][Y2] = XY[Button_InstantCloseSells][Y1] + UNIT_HEIGHT*1.3;


   XY[Edit_TicketStart][X1] = XY[Button_InstantCloseBuy][X1];
   XY[Edit_TicketStart][Y1] = XY[Button_InstantCloseBuy][Y2] +30;
   XY[Edit_TicketStart][X2] = XY[Edit_TicketStart][X1] + UNIT_WIDTH*2.45;
   XY[Edit_TicketStart][Y2] = XY[Edit_TicketStart][Y1] + UNIT_HEIGHT;


   XY[Edit_TicketStop][X1] = XY[Button_InstantCloseSells][X1]-11;
   XY[Edit_TicketStop][Y1] = XY[Button_InstantCloseSells][Y2]  +30;
   XY[Edit_TicketStop][X2] = XY[Edit_TicketStop][X1] + UNIT_WIDTH*2.45;
   XY[Edit_TicketStop][Y2] = XY[Edit_TicketStop][Y1] + UNIT_HEIGHT;

   XY[Button_CloseByTicket][X1] = XY[Button_CloseAll][X1];
   XY[Button_CloseByTicket][Y1] = XY[Button_CloseAll][Y1]  + SPAN +51;
   XY[Button_CloseByTicket][X2] = XY[Button_CloseByTicket][X1]+ 264;
   XY[Button_CloseByTicket][Y2] = XY[Button_CloseByTicket][Y1] + UNIT_HEIGHT*1;

   XY[Button_CloseMode][X1] = XY[Button_CloseAll][X2]+ 3;
   XY[Button_CloseMode][Y1] = XY[Button_CloseAll][Y2]  + SPAN-8;
   XY[Button_CloseMode][X2] = XY[Button_CloseMode][X1]+ UNIT_WIDTH+22  ;
   XY[Button_CloseMode][Y2] = XY[Button_CloseMode][Y1] + UNIT_HEIGHT*1.3;

   XY[Edit_TPLVL][X1] = XY[Button_Buy][X1]+5;
   XY[Edit_TPLVL][Y1] = XY[Button_Buy][Y2] +SPAN/2;
   XY[Edit_TPLVL][X2] = XY[Edit_TPLVL][X1] + UNIT_WIDTH*2.2;
   XY[Edit_TPLVL][Y2] = XY[Edit_TPLVL][Y1] + UNIT_HEIGHT;


   XY[Edit_SLLVL][X1] = XY[Button_Sell][X1]+26;
   XY[Edit_SLLVL][Y1] = XY[Button_Sell][Y2]  +SPAN/2;
   XY[Edit_SLLVL][X2] = XY[Edit_SLLVL][X1] + UNIT_WIDTH*2.2;
   XY[Edit_SLLVL][Y2] = XY[Edit_SLLVL][Y1] + UNIT_HEIGHT;

   XY[Button_TPB][X1] = XY[Button_Buy][X2]-136.5;
   XY[Button_TPB][Y1] = XY[Button_Buy][Y2]   + SPAN-7;
   XY[Button_TPB][X2] = XY[Button_TPB][X1]+12;
   XY[Button_TPB][Y2] = XY[Button_TPB][Y1] + UNIT_HEIGHT*1.08;

   XY[Button_SLB][X1] = XY[Button_Buy][X2]+132;
   XY[Button_SLB][Y1] = XY[Button_Buy][Y2]  + SPAN-7;
   XY[Button_SLB][X2] = XY[Button_SLB][X1]+ 12 ;
   XY[Button_SLB][Y2] = XY[Button_SLB][Y1] + UNIT_HEIGHT*1.08;






   XY[Button_MobileSL][X1] = XY[Panel_MobileStop][X2] -37;
   XY[Button_MobileSL][Y1] = XY[Panel_MobileStop][Y1] +5;
   XY[Button_MobileSL][X2] = XY[Button_MobileSL][X1] + UNIT_WIDTH/1.3;
   XY[Button_MobileSL][Y2] = XY[Button_MobileSL][Y1] + UNIT_WIDTH/2.5;

   XY[Button_LogTSL][X1] = XY[Panel_MobileStop][X1] +5;
   XY[Button_LogTSL][Y1] = XY[Panel_MobileStop][Y1] +5;
   XY[Button_LogTSL][X2] = XY[Button_LogTSL][X1] + UNIT_WIDTH/1.3;
   XY[Button_LogTSL][Y2] = XY[Button_LogTSL][Y1] + UNIT_WIDTH/2.5;


   XY[Label_MobileSLText][X1] = XY[Button_MobileSL][X1]-160;
   XY[Label_MobileSLText][Y1] = XY[Button_MobileSL][Y1] -13;
   XY[Label_MobileSLText][X2] = XY[Label_MobileSLText][X1] + UNIT_WIDTH;
   XY[Label_MobileSLText][Y2] = XY[Label_MobileSLText][Y1] + UNIT_HEIGHT;

   XY[Label_TSLDistanceText][X1] = XY[Button_MobileSL][X1]-220;
   XY[Label_TSLDistanceText][Y1] = XY[Button_MobileSL][Y1] +4;
   XY[Label_TSLDistanceText][X2] = XY[Label_TSLDistanceText][X1] + UNIT_WIDTH;
   XY[Label_TSLDistanceText][Y2] = XY[Label_TSLDistanceText][Y1] + UNIT_HEIGHT;

   XY[Label_TSLStepText][X1] = XY[Button_MobileSL][X1]-38;
   XY[Label_TSLStepText][Y1] = XY[Button_MobileSL][Y1] +4;
   XY[Label_TSLStepText][X2] = XY[Label_TSLStepText][X1] + UNIT_WIDTH;
   XY[Label_TSLStepText][Y2] = XY[Label_TSLStepText][Y1] + UNIT_HEIGHT;

   XY[Edit_TSLDistance][X1] = XY[Panel_MobileStop][X1]+10;
   XY[Edit_TSLDistance][Y1] = XY[Panel_MobileStop][Y2]-27;
   XY[Edit_TSLDistance][X2] = XY[Edit_TSLDistance][X1] + UNIT_WIDTH*2.2;
   XY[Edit_TSLDistance][Y2] = XY[Edit_TSLDistance][Y1] + UNIT_HEIGHT;

   XY[Edit_TSLStep][X1] = XY[Panel_MobileStop][X1]+181;
   XY[Edit_TSLStep][Y1] = XY[Panel_MobileStop][Y2]-27;
   XY[Edit_TSLStep][X2] = XY[Edit_TSLStep][X1] + UNIT_WIDTH*2.2;
   XY[Edit_TSLStep][Y2] = XY[Edit_TSLStep][Y1] + UNIT_HEIGHT;


   XY[Button_UpTSLDISTANCE][X1] = XY[Panel_MobileStop][X1] + SPAN*8.8+7;
   XY[Button_UpTSLDISTANCE][Y1] = XY[Panel_MobileStop][Y2] - 30;
   XY[Button_UpTSLDISTANCE][X2] = XY[Button_UpTSLDISTANCE][X1] + UNIT_WIDTH/1.6;
   XY[Button_UpTSLDISTANCE][Y2] = XY[Button_UpTSLDISTANCE][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownTSLDISTANCE][X1] = XY[Button_UpTSLDISTANCE][X1];
   XY[Button_DownTSLDISTANCE][Y1] = XY[Button_UpTSLDISTANCE][Y2]+ SPAN/4;
   XY[Button_DownTSLDISTANCE][X2] = XY[Button_DownTSLDISTANCE][X1] + UNIT_WIDTH/1.6;
   XY[Button_DownTSLDISTANCE][Y2] = XY[Button_DownTSLDISTANCE][Y1] + UNIT_HEIGHT/2;

   XY[Button_UpTSLSTEP][X1] = XY[Panel_MobileStop][X1] + SPAN*8.8+43;
   XY[Button_UpTSLSTEP][Y1] = XY[Panel_MobileStop][Y2] - 30;
   XY[Button_UpTSLSTEP][X2] = XY[Button_UpTSLSTEP][X1] + UNIT_WIDTH/1.6;
   XY[Button_UpTSLSTEP][Y2] = XY[Button_UpTSLSTEP][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownTSLSTEP][X1] = XY[Button_UpTSLSTEP][X1];
   XY[Button_DownTSLSTEP][Y1] = XY[Button_UpTSLSTEP][Y2]+ SPAN/4;
   XY[Button_DownTSLSTEP][X2] = XY[Button_DownTSLSTEP][X1] + UNIT_WIDTH/1.6;
   XY[Button_DownTSLSTEP][Y2] = XY[Button_DownTSLSTEP][Y1] + UNIT_HEIGHT/2;


   XY[Label_CoverageText][X1] = XY[Panel_Coverage][X1]+10;
   XY[Label_CoverageText][Y1] = XY[Panel_Coverage][Y2]-43;
   XY[Label_CoverageText][X2] = XY[Label_CoverageText][X1] + UNIT_WIDTH;
   XY[Label_CoverageText][Y2] = XY[Label_CoverageText][Y1] + UNIT_HEIGHT;

   XY[Label_CoverageTextx2][X1] = XY[Panel_Coverage][X1]+10;
   XY[Label_CoverageTextx2][Y1] = XY[Panel_Coverage][Y2]-30;
   XY[Label_CoverageTextx2][X2] = XY[Label_CoverageTextx2][X1] + UNIT_WIDTH;
   XY[Label_CoverageTextx2][Y2] = XY[Label_CoverageTextx2][Y1] + UNIT_HEIGHT;

   XY[Button_Coveragex][X1] = XY[Panel_Coverage][X1] +SPAN+238;
   XY[Button_Coveragex][Y1] = XY[Panel_Coverage][Y2] + SPAN-36;
   XY[Button_Coveragex][X2] = XY[Button_Coveragex][X1] + UNIT_WIDTH/1.3;
   XY[Button_Coveragex][Y2] = XY[Button_Coveragex][Y1] + UNIT_WIDTH/2.5;

   XY[Edit_Coverage][X1] = XY[Panel_Coverage][X1]+170;
   XY[Edit_Coverage][Y1] = XY[Panel_Coverage][Y2] -26;
   XY[Edit_Coverage][X2] = XY[Edit_Coverage][X1] + UNIT_WIDTH*1.5;
   XY[Edit_Coverage][Y2] = XY[Edit_Coverage][Y1] + UNIT_HEIGHT;

   XY[Edit_CoveragePlus][X1] = XY[Panel_Coverage][X1]+53;
   XY[Edit_CoveragePlus][Y1] = XY[Panel_Coverage][Y2] -26;
   XY[Edit_CoveragePlus][X2] = XY[Edit_CoveragePlus][X1] + UNIT_WIDTH*1.5;
   XY[Edit_CoveragePlus][Y2] = XY[Edit_CoveragePlus][Y1] + UNIT_HEIGHT;
   /*
      XY[Button_UpCoverage][X1] = XY[Panel_Coverage][X1] +121;
      XY[Button_UpCoverage][Y1] = XY[Panel_Coverage][Y2] - 26.5;
      XY[Button_UpCoverage][X2] = XY[Button_UpCoverage][X1] + UNIT_WIDTH/2;
      XY[Button_UpCoverage][Y2] = XY[Button_UpCoverage][Y1] + UNIT_HEIGHT/2;

      XY[Button_DownCoverage][X1] = XY[Button_UpCoverage][X1];
      XY[Button_DownCoverage][Y1] = XY[Button_UpCoverage][Y2]+ SPAN/5;
      XY[Button_DownCoverage][X2] = XY[Button_DownCoverage][X1] + UNIT_WIDTH/2;
      XY[Button_DownCoverage][Y2] = XY[Button_DownCoverage][Y1] + UNIT_HEIGHT/2;
   */
   XY[Button_UpCoverage][X1] = XY[Panel_Coverage][X1] + SPAN*8.8+18;
   XY[Button_UpCoverage][Y1] = XY[Panel_Coverage][Y2] - 27;
   XY[Button_UpCoverage][X2] = XY[Button_UpCoverage][X1] + UNIT_WIDTH/2.1;
   XY[Button_UpCoverage][Y2] = XY[Button_UpCoverage][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownCoverage][X1] = XY[Button_UpCoverage][X1];
   XY[Button_DownCoverage][Y1] = XY[Button_UpCoverage][Y2]+ SPAN/5;
   XY[Button_DownCoverage][X2] = XY[Button_DownCoverage][X1] + UNIT_WIDTH/2.1;
   XY[Button_DownCoverage][Y2] = XY[Button_DownCoverage][Y1] + UNIT_HEIGHT/2;

   XY[Button_UpCoveragePlus][X1] = XY[Panel_Coverage][X1] + SPAN*8.8+41;
   XY[Button_UpCoveragePlus][Y1] = XY[Panel_Coverage][Y2] - 27;
   XY[Button_UpCoveragePlus][X2] = XY[Button_UpCoveragePlus][X1] + UNIT_WIDTH/2.1;
   XY[Button_UpCoveragePlus][Y2] = XY[Button_UpCoveragePlus][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownCoveragePlus][X1] = XY[Button_UpCoveragePlus][X1];
   XY[Button_DownCoveragePlus][Y1] = XY[Button_UpCoveragePlus][Y2]+ SPAN/5;
   XY[Button_DownCoveragePlus][X2] = XY[Button_DownCoveragePlus][X1] + UNIT_WIDTH/2.1;
   XY[Button_DownCoveragePlus][Y2] = XY[Button_DownCoveragePlus][Y1] + UNIT_HEIGHT/2;



   XY[Button_UpTicketStart][X1] = XY[Edit_TicketStart][X2] + 4;
   XY[Button_UpTicketStart][Y1] = XY[Edit_TicketStart][Y1] ;
   XY[Button_UpTicketStart][X2] = XY[Button_UpTicketStart][X1] + UNIT_WIDTH/2.1;
   XY[Button_UpTicketStart][Y2] = XY[Button_UpTicketStart][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownTicketStart][X1] = XY[Button_UpTicketStart][X1];
   XY[Button_DownTicketStart][Y1] = XY[Button_UpTicketStart][Y2]+ SPAN/5;
   XY[Button_DownTicketStart][X2] = XY[Button_DownTicketStart][X1] + UNIT_WIDTH/2.1;
   XY[Button_DownTicketStart][Y2] = XY[Button_DownTicketStart][Y1] + UNIT_HEIGHT/2;

   XY[Button_UpTicketStop][X1] = XY[Edit_TicketStart][X2] + 27;
   XY[Button_UpTicketStop][Y1] = XY[Edit_TicketStart][Y1];
   XY[Button_UpTicketStop][X2] = XY[Button_UpTicketStop][X1] + UNIT_WIDTH/2.1;
   XY[Button_UpTicketStop][Y2] = XY[Button_UpTicketStop][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownTicketStop][X1] = XY[Button_UpTicketStop][X1];
   XY[Button_DownTicketStop][Y1] = XY[Button_UpTicketStop][Y2]+ SPAN/5;
   XY[Button_DownTicketStop][X2] = XY[Button_DownTicketStop][X1] + UNIT_WIDTH/2.1;
   XY[Button_DownTicketStop][Y2] = XY[Button_DownTicketStop][Y1] + UNIT_HEIGHT/2;

   XY[Label_BalanceEquity][X1] = XY[Label_Current_Sell_Volume][X1];
   XY[Label_BalanceEquity][Y1] = XY[Label_Current_Sell_Volume][Y1]+30;
   XY[Label_BalanceEquity][X2] = XY[Label_BalanceEquity][X1] + UNIT_WIDTH;
   XY[Label_BalanceEquity][Y2] = XY[Label_BalanceEquity][Y1] + UNIT_HEIGHT;

   XY[Label_ACProfit][X1] = XY[Label_AllowBuySell][X1]+65;
   XY[Label_ACProfit][Y1] = XY[Label_AllowBuySell][Y1];
   XY[Label_ACProfit][X2] = XY[Label_ACProfit][X1] + UNIT_WIDTH;
   XY[Label_ACProfit][Y2] = XY[Label_ACProfit][Y1] + UNIT_HEIGHT;

   XY[Label_DailyACProfit][X1] = XY[Label_Current_Sell_Volume][X1];
   XY[Label_DailyACProfit][Y1] = XY[Label_Current_Sell_Volume][Y1]+15;
   XY[Label_DailyACProfit][X2] = XY[Label_DailyACProfit][X1] + UNIT_WIDTH;
   XY[Label_DailyACProfit][Y2] = XY[Label_DailyACProfit][Y1] + UNIT_HEIGHT;

///---emty
   XY[Label_Owner][X1] = XY[Label_BalanceEquity][X1];
   XY[Label_Owner][Y1] = XY[Label_BalanceEquity][Y1]+17;
   XY[Label_Owner][X2] = XY[Label_Owner][X1] + UNIT_WIDTH;
   XY[Label_Owner][Y2] = XY[Label_Owner][Y1] + UNIT_HEIGHT;

   XY[Label_Account][X1] = XY[Label_BalanceEquity][X1];
   XY[Label_Account][Y1] = XY[Label_BalanceEquity][Y1]+30;
   XY[Label_Account][X2] = XY[Label_Account][X1] + UNIT_WIDTH;
   XY[Label_Account][Y2] = XY[Label_Account][Y1] + UNIT_HEIGHT;


   XY[Label_Server][X1] = XY[Label_BalanceEquity][X1];
   XY[Label_Server][Y1] = XY[Label_BalanceEquity][Y1]+40;
   XY[Label_Server][X2] = XY[Label_Server][X1] + UNIT_WIDTH;
   XY[Label_Server][Y2] = XY[Label_Server][Y1] + UNIT_HEIGHT;

   XY[Label_DateAndPing][X1] = XY[Label_BalanceEquity][X1];
   XY[Label_DateAndPing][Y1] = XY[Label_BalanceEquity][Y1]+12;
   XY[Label_DateAndPing][X2] = XY[Label_DateAndPing][X1] + UNIT_WIDTH;
   XY[Label_DateAndPing][Y2] = XY[Label_DateAndPing][Y1] + UNIT_HEIGHT;
///----




   XY[Label_AutoBotTPText][X1] = XY[Panel_AutoBotTP][X1]+110;
   XY[Label_AutoBotTPText][Y1] = XY[Panel_AutoBotTP][Y1]-8;
   XY[Label_AutoBotTPText][X2] = XY[Label_AutoBotTPText][X1] + UNIT_WIDTH;
   XY[Label_AutoBotTPText][Y2] = XY[Label_AutoBotTPText][Y1] + UNIT_HEIGHT;
//--empty
   XY[Label_AutoBotTPTextx2][X1] = XY[Panel_AutoBotTP][X1]+6;
   XY[Label_AutoBotTPTextx2][Y1] = XY[Panel_AutoBotTP][Y2]-30;
   XY[Label_AutoBotTPTextx2][X2] = XY[Label_AutoBotTPTextx2][X1] + UNIT_WIDTH;
   XY[Label_AutoBotTPTextx2][Y2] = XY[Label_AutoBotTPTextx2][Y1] + UNIT_HEIGHT;
//----




   XY[Edit_AutoBotTPStop][X1] = XY[Panel_AutoBotTP][X1]+10;
   XY[Edit_AutoBotTPStop][Y1] = XY[Panel_AutoBotTP][Y2]-27;
   XY[Edit_AutoBotTPStop][X2] = XY[Edit_AutoBotTPStop][X1] + UNIT_WIDTH*2.2;
   XY[Edit_AutoBotTPStop][Y2] = XY[Edit_AutoBotTPStop][Y1] + UNIT_HEIGHT;

   XY[Edit_AutoBotTPStep][X1] = XY[Panel_AutoBotTP][X1]+181;
   XY[Edit_AutoBotTPStep][Y1] = XY[Panel_AutoBotTP][Y2]-27;
   XY[Edit_AutoBotTPStep][X2] = XY[Edit_AutoBotTPStep][X1] + UNIT_WIDTH*2.2;
   XY[Edit_AutoBotTPStep][Y2] = XY[Edit_AutoBotTPStep][Y1] + UNIT_HEIGHT;




   XY[Button_LogAutoBotTP][X1] = XY[Panel_AutoBotTP][X1] +5;
   XY[Button_LogAutoBotTP][Y1] = XY[Panel_AutoBotTP][Y1] +5;
   XY[Button_LogAutoBotTP][X2] = XY[Button_LogAutoBotTP][X1] + UNIT_WIDTH/1.3;
   XY[Button_LogAutoBotTP][Y2] = XY[Button_LogAutoBotTP][Y1] + UNIT_WIDTH/2.5;







   XY[Button_UpAutoBotTPStop][X1] = XY[Panel_AutoBotTP][X1] + SPAN*8.8+7;
   XY[Button_UpAutoBotTPStop][Y1] = XY[Panel_AutoBotTP][Y2] - 30;
   XY[Button_UpAutoBotTPStop][X2] = XY[Button_UpAutoBotTPStop][X1] + UNIT_WIDTH/1.6;
   XY[Button_UpAutoBotTPStop][Y2] = XY[Button_UpAutoBotTPStop][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownAutoBotTPStop][X1] = XY[Button_UpAutoBotTPStop][X1];
   XY[Button_DownAutoBotTPStop][Y1] = XY[Button_UpAutoBotTPStop][Y2]+ SPAN/4;
   XY[Button_DownAutoBotTPStop][X2] = XY[Button_DownAutoBotTPStop][X1] + UNIT_WIDTH/1.6;
   XY[Button_DownAutoBotTPStop][Y2] = XY[Button_DownAutoBotTPStop][Y1] + UNIT_HEIGHT/2;

   XY[Button_UpAutoBotTPStep][X1] = XY[Panel_AutoBotTP][X1] + SPAN*8.8+43;
   XY[Button_UpAutoBotTPStep][Y1] = XY[Panel_AutoBotTP][Y2] - 30;
   XY[Button_UpAutoBotTPStep][X2] = XY[Button_UpAutoBotTPStep][X1] + UNIT_WIDTH/1.6;
   XY[Button_UpAutoBotTPStep][Y2] = XY[Button_UpAutoBotTPStep][Y1] + UNIT_HEIGHT/2;

   XY[Button_DownAutoBotTPStep][X1] = XY[Button_UpAutoBotTPStep][X1];
   XY[Button_DownAutoBotTPStep][Y1] = XY[Button_UpAutoBotTPStep][Y2]+ SPAN/4;
   XY[Button_DownAutoBotTPStep][X2] = XY[Button_DownAutoBotTPStep][X1] + UNIT_WIDTH/1.6;
   XY[Button_DownAutoBotTPStep][Y2] = XY[Button_DownAutoBotTPStep][Y1] + UNIT_HEIGHT/2;




   XY[Button_AutoBotTPRun][X1] = XY[Panel_AutoBotTP][X1] +SPAN+238;
   XY[Button_AutoBotTPRun][Y1] = XY[Panel_AutoBotTP][Y1] +5;
   XY[Button_AutoBotTPRun][X2] = XY[Button_AutoBotTPRun][X1] + UNIT_WIDTH/1.3;
   XY[Button_AutoBotTPRun][Y2] = XY[Button_AutoBotTPRun][Y1] + UNIT_WIDTH/2.5;

   XY[ComboBox_PairGroup][X1] = XY[Panel_GroupOpen][X1]+115;
   XY[ComboBox_PairGroup][Y1] = XY[Panel_GroupOpen][Y1] +4;
   XY[ComboBox_PairGroup][X2] = XY[ComboBox_PairGroup][X1]  + 3 * UNIT_WIDTH - SPAN;
   XY[ComboBox_PairGroup][Y2] = XY[ComboBox_PairGroup][Y1] + UNIT_HEIGHT+1;


   XY[Label_GroupOpenText][X1] = XY[Panel_GroupOpen][X1]+8;
   XY[Label_GroupOpenText][Y1] = XY[Panel_GroupOpen][Y2]-43;
   XY[Label_GroupOpenText][X2] = XY[Label_GroupOpenText][X1] + UNIT_WIDTH;
   XY[Label_GroupOpenText][Y2] = XY[Label_GroupOpenText][Y1] + UNIT_HEIGHT;

   XY[Label_GroupOpenTextx2][X1] = XY[Panel_GroupOpen][X1]+12;
   XY[Label_GroupOpenTextx2][Y1] = XY[Panel_GroupOpen][Y2]-31;
   XY[Label_GroupOpenTextx2][X2] = XY[Label_GroupOpenTextx2][X1] + UNIT_WIDTH;
   XY[Label_GroupOpenTextx2][Y2] = XY[Label_GroupOpenTextx2][Y1] + UNIT_HEIGHT;



   XY[Button_GroupOpenOnOff][X1] = XY[Panel_GroupOpen][X1] +SPAN+238;
   XY[Button_GroupOpenOnOff][Y1] = XY[Panel_GroupOpen][Y2] + SPAN-36;
   XY[Button_GroupOpenOnOff][X2] = XY[Button_GroupOpenOnOff][X1] + UNIT_WIDTH/1.3;
   XY[Button_GroupOpenOnOff][Y2] = XY[Button_GroupOpenOnOff][Y1] + UNIT_WIDTH/2.5;


   XY[List_Orderx1][X1] = XY[Panel_Lot][X1] + 7;
   XY[List_Orderx1][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx1][X2] = XY[List_Orderx1][X1] + 97;
   XY[List_Orderx1][Y2] = XY[List_Orderx1][Y2] + 378;

   XY[List_Orderx2][X1] = XY[List_Orderx1][X2] ;
   XY[List_Orderx2][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx2][X2] = XY[List_Orderx2][X1] + 63;
   XY[List_Orderx2][Y2] = XY[List_Orderx2][Y2] + 378;

   XY[List_Orderx3][X1] = XY[List_Orderx2][X2] ;
   XY[List_Orderx3][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx3][X2] = XY[List_Orderx3][X1] + 52;
   XY[List_Orderx3][Y2] = XY[List_Orderx4][Y2] + 378;

   XY[List_Orderx4][X1] = XY[List_Orderx3][X2] ;
   XY[List_Orderx4][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx4][X2] = XY[List_Orderx4][X1] + 70;
   XY[List_Orderx4][Y2] = XY[List_Orderx4][Y2] + 378;

   XY[List_Orderx5][X1] = XY[List_Orderx4][X2] ;
   XY[List_Orderx5][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx5][X2] = XY[List_Orderx5][X1] + 70;
   XY[List_Orderx5][Y2] = XY[List_Orderx5][Y2] + 378;

   XY[List_Orderx6][X1] = XY[List_Orderx5][X2] ;
   XY[List_Orderx6][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx6][X2] = XY[List_Orderx6][X1] + 70;
   XY[List_Orderx6][Y2] = XY[List_Orderx6][Y2] + 378;

   XY[List_Orderx7][X1] = XY[List_Orderx6][X2] ;
   XY[List_Orderx7][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx7][X2] = XY[List_Orderx7][X1] + 57;
   XY[List_Orderx7][Y2] = XY[List_Orderx7][Y2] + 378;

   XY[List_Orderx8][X1] = XY[List_Orderx7][X2] ;
   XY[List_Orderx8][Y1] = XY[Panel_Lot][Y2] + 20;
   XY[List_Orderx8][X2] = XY[List_Orderx8][X1] + 80;
   XY[List_Orderx8][Y2] = XY[List_Orderx8][Y2] + 378;






   XY[Label_ListTicket][X1] = XY[List_Orderx1][X1] +16;
   XY[Label_ListTicket][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListTicket][X2] = XY[Label_ListTicket][X1] + UNIT_WIDTH;
   XY[Label_ListTicket][Y2] = XY[Label_ListTicket][Y1] + UNIT_HEIGHT;

   XY[Label_ListSymbol][X1] = XY[List_Orderx2][X1] +0;
   XY[Label_ListSymbol][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListSymbol][X2] = XY[Label_ListSymbol][X1] + UNIT_WIDTH;
   XY[Label_ListSymbol][Y2] = XY[Label_ListSymbol][Y1] + UNIT_HEIGHT;

   XY[Label_ListType][X1] = XY[List_Orderx3][X1]+0 ;
   XY[Label_ListType][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListType][X2] = XY[Label_ListType][X1] + UNIT_WIDTH;
   XY[Label_ListType][Y2] = XY[Label_ListType][Y1] + UNIT_HEIGHT;

   XY[Label_ListPrice][X1] = XY[List_Orderx4][X1]+6 ;
   XY[Label_ListPrice][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListPrice][X2] = XY[Label_ListPrice][X1] + UNIT_WIDTH;
   XY[Label_ListPrice][Y2] = XY[Label_ListPrice][Y1] + UNIT_HEIGHT;

   XY[Label_ListTP][X1] = XY[List_Orderx5][X1]+0;
   XY[Label_ListTP][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListTP][X2] = XY[Label_ListTP][X1] + UNIT_WIDTH;
   XY[Label_ListTP][Y2] = XY[Label_ListTP][Y1] + UNIT_HEIGHT;

   XY[Label_ListSL][X1] = XY[List_Orderx6][X1]+0 ;
   XY[Label_ListSL][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListSL][X2] = XY[Label_ListSL][X1] + UNIT_WIDTH;
   XY[Label_ListSL][Y2] = XY[Label_ListSL][Y1] + UNIT_HEIGHT;

   XY[Label_ListLOT][X1] = XY[List_Orderx7][X1]-4 ;
   XY[Label_ListLOT][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListLOT][X2] = XY[Label_ListLOT][X1] + UNIT_WIDTH;
   XY[Label_ListLOT][Y2] = XY[Label_ListLOT][Y1] + UNIT_HEIGHT;

   XY[Label_ListProfit][X1] = XY[List_Orderx8][X1]+10 ;
   XY[Label_ListProfit][Y1] = XY[Panel_Lot][Y2] - 10;
   XY[Label_ListProfit][X2] = XY[Label_ListProfit][X1] + UNIT_WIDTH;
   XY[Label_ListProfit][Y2] = XY[Label_ListProfit][Y1] + UNIT_HEIGHT;


   XY[Button_GoPanel1][X1] = XY[Panel_DetailedPosControl][X1] +526;
   XY[Button_GoPanel1][Y1] = XY[Panel_DetailedPosControl][Y1] +5;
   XY[Button_GoPanel1][X2] = XY[Button_GoPanel1][X1] + UNIT_WIDTH/1.4;
   XY[Button_GoPanel1][Y2] = XY[Button_GoPanel1][Y1] + UNIT_WIDTH/2;


   XY[Button_GoPanel2][X1] = XY[Panel_Info][X1] +525;
   XY[Button_GoPanel2][Y1] = XY[Panel_Info][Y1] +5;
   XY[Button_GoPanel2][X2] = XY[Button_GoPanel2][X1] + UNIT_WIDTH/1.4;
   XY[Button_GoPanel2][Y2] = XY[Button_GoPanel2][Y1] + UNIT_WIDTH/2;



   XY[ComboBox_ListMode][X1] = XY[Panel_DetailedPosControl][X1]+5;
   XY[ComboBox_ListMode][Y1] = XY[Panel_DetailedPosControl][Y1] +5;
   XY[ComboBox_ListMode][X2] = XY[ComboBox_ListMode][X1]  + 3 * UNIT_WIDTH - SPAN;
   XY[ComboBox_ListMode][Y2] = XY[ComboBox_ListMode][Y1] + UNIT_HEIGHT+1;

   /* XY[ComboBox_SetLogValues][X1] = XY[Panel_DetailedPosControl][X1]+130;
    XY[ComboBox_SetLogValues][Y1] = XY[Panel_DetailedPosControl][Y1] +5;
    XY[ComboBox_SetLogValues][X2] = XY[ComboBox_SetLogValues][X1]  +159;
    XY[ComboBox_SetLogValues][Y2] = XY[ComboBox_SetLogValues][Y1] + UNIT_HEIGHT+1;
    */

   /*
   XY[Edit_LogValues][X1] = XY[Panel_DetailedPosControl][X1]+300;
   XY[Edit_LogValues][Y1] = XY[Panel_DetailedPosControl][Y1] +5;
   XY[Edit_LogValues][X2] = XY[Edit_LogValues][X1]  +50;
   XY[Edit_LogValues][Y2] = XY[Edit_LogValues][Y1] + UNIT_HEIGHT+1;
   */

   XY[Label_PositionPanelText][X1] = XY[Panel_Main][X1]  + 150;
   XY[Label_PositionPanelText][Y1] = XY[Panel_Main][Y1] + 15;
   XY[Label_PositionPanelText][X2] = XY[Label_PositionPanelText][X1] + UNIT_WIDTH;
   XY[Label_PositionPanelText][Y2] = XY[Label_PositionPanelText][Y1] + UNIT_HEIGHT;

   XY[Label_LogAreaText][X1] = XY[Panel_DetailedPosControlx2][X1]  -1;
   XY[Label_LogAreaText][Y1] = XY[Panel_DetailedPosControlx2][Y1] - 13;
   XY[Label_LogAreaText][X2] = XY[Label_LogAreaText][X1] + UNIT_WIDTH;
   XY[Label_LogAreaText][Y2] = XY[Label_LogAreaText][Y1] + UNIT_HEIGHT;

   XY[Label_LogAreaTextx2][X1] = XY[Panel_DetailedPosControlx2][X1]  + 5;
   XY[Label_LogAreaTextx2][Y1] = XY[Panel_DetailedPosControlx2][Y1] ;
   XY[Label_LogAreaTextx2][X2] = XY[Label_LogAreaTextx2][X1] + UNIT_WIDTH;
   XY[Label_LogAreaTextx2][Y2] = XY[Label_LogAreaTextx2][Y1] + UNIT_HEIGHT;





   XY[Label_ChangeLogTextA][X1] = XY[Panel_DetailedPosControlx2][X1]  +5;
   XY[Label_ChangeLogTextA][Y1] = XY[Panel_DetailedPosControlx2][Y1] - 10;
   XY[Label_ChangeLogTextA][X2] = XY[Label_ChangeLogTextA][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextA][Y2] = XY[Label_ChangeLogTextA][Y1] + UNIT_HEIGHT;

   XY[Label_ChangeLogTextAx2][X1] = XY[Panel_DetailedPosControlx2][X1]  + 5;
   XY[Label_ChangeLogTextAx2][Y1] = XY[Panel_DetailedPosControlx2][Y1] +3;
   XY[Label_ChangeLogTextAx2][X2] = XY[Label_ChangeLogTextAx2][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextAx2][Y2] = XY[Label_ChangeLogTextAx2][Y1] + UNIT_HEIGHT;


   XY[Label_ChangeLogTextB][X1] = XY[Panel_DetailedPosControlx2][X1]  +155;
   XY[Label_ChangeLogTextB][Y1] = XY[Panel_DetailedPosControlx2][Y1] - 10;
   XY[Label_ChangeLogTextB][X2] = XY[Label_ChangeLogTextB][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextB][Y2] = XY[Label_ChangeLogTextB][Y1] + UNIT_HEIGHT;

   XY[Label_ChangeLogTextBx2][X1] = XY[Panel_DetailedPosControlx2][X1]  + 158;
   XY[Label_ChangeLogTextBx2][Y1] = XY[Panel_DetailedPosControlx2][Y1] +3;
   XY[Label_ChangeLogTextBx2][X2] = XY[Label_ChangeLogTextBx2][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextBx2][Y2] = XY[Label_ChangeLogTextBx2][Y1] + UNIT_HEIGHT;


   XY[Label_ChangeLogTextC][X1] = XY[Panel_DetailedPosControlx2][X1]  +307;
   XY[Label_ChangeLogTextC][Y1] = XY[Panel_DetailedPosControlx2][Y1] - 10;
   XY[Label_ChangeLogTextC][X2] = XY[Label_ChangeLogTextC][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextC][Y2] = XY[Label_ChangeLogTextC][Y1] + UNIT_HEIGHT;

   XY[Label_ChangeLogTextCx2][X1] = XY[Panel_DetailedPosControlx2][X1]  + 307;
   XY[Label_ChangeLogTextCx2][Y1] = XY[Panel_DetailedPosControlx2][Y1] +3;
   XY[Label_ChangeLogTextCx2][X2] = XY[Label_ChangeLogTextCx2][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextCx2][Y2] = XY[Label_ChangeLogTextCx2][Y1] + UNIT_HEIGHT;


   XY[Label_ChangeLogTextD][X1] = XY[Panel_DetailedPosControlx2][X1]  + 434;
   XY[Label_ChangeLogTextD][Y1] = XY[Panel_DetailedPosControlx2][Y1] - 10;
   XY[Label_ChangeLogTextD][X2] = XY[Label_ChangeLogTextD][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextD][Y2] = XY[Label_ChangeLogTextD][Y1] + UNIT_HEIGHT;


   XY[Label_ChangeLogTextDx2][X1] = XY[Panel_DetailedPosControlx2][X1]  +434;
   XY[Label_ChangeLogTextDx2][Y1] = XY[Panel_DetailedPosControlx2][Y1] +3;
   XY[Label_ChangeLogTextDx2][X2] = XY[Label_ChangeLogTextDx2][X1] + UNIT_WIDTH;
   XY[Label_ChangeLogTextDx2][Y2] = XY[Label_ChangeLogTextDx2][Y1] + UNIT_HEIGHT;



   XY[Edit_LogA][X1] = XY[Panel_DetailedPosControlx2][X1]+90;
   XY[Edit_LogA][Y1] = XY[Panel_DetailedPosControlx2][Y1] +4;
   XY[Edit_LogA][X2] = XY[Edit_LogA][X1]  +60;
   XY[Edit_LogA][Y2] = XY[Edit_LogA][Y1] + UNIT_HEIGHT+2;

   XY[Edit_LogB][X1] = XY[Panel_DetailedPosControlx2][X1]+235;
   XY[Edit_LogB][Y1] = XY[Panel_DetailedPosControlx2][Y1] +4;
   XY[Edit_LogB][X2] = XY[Edit_LogB][X1]  +60;
   XY[Edit_LogB][Y2] = XY[Edit_LogB][Y1] + UNIT_HEIGHT+2;

   XY[Edit_LogC][X1] = XY[Panel_DetailedPosControlx2][X1]+370;
   XY[Edit_LogC][Y1] = XY[Panel_DetailedPosControlx2][Y1] +4;
   XY[Edit_LogC][X2] = XY[Edit_LogC][X1]  +55;
   XY[Edit_LogC][Y2] = XY[Edit_LogC][Y1] + UNIT_HEIGHT+2;

   XY[Edit_LogD][X1] = XY[Panel_DetailedPosControlx2][X1]+500;
   XY[Edit_LogD][Y1] = XY[Panel_DetailedPosControlx2][Y1] +4;
   XY[Edit_LogD][X2] = XY[Edit_LogD][X1]  +55;
   XY[Edit_LogD][Y2] = XY[Edit_LogD][Y1] + UNIT_HEIGHT+2;

   XY[Button_SelectPoss][X1] = XY[Panel_DetailedPosControl][X1] + 130 ;
   XY[Button_SelectPoss][Y1] = XY[Panel_DetailedPosControl][Y1] + 5 ;
   XY[Button_SelectPoss][X2] = XY[Button_SelectPoss][X1]+  3 * UNIT_WIDTH - SPAN/3-40;
   XY[Button_SelectPoss][Y2] = XY[Button_SelectPoss][Y1]+ UNIT_HEIGHT+1;


//Button_GoOrdersPanel
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetNames()
  {
   N[Dialog] = "    NOVA TRADE PANEL  -  MOST USEFUL TRADE EXPERIENCE !";

   N[Panel_Lot] = "  NOVA ULTIMATE TRADE PANEL  ";
   N[Panel_Info] = "Info Panel";
   N[Panel_Main] = "Main Panel";
   N[Panel_OrderOpener] = "Opener Panel";
   N[Panel_MobileStop] = "MobileStop Panel";
   N[Panel_CloseArea] = "Close Area Panel";
   N[Panel_Coverage] = "Auto Close Panel";
   N[Panel_AutoBotTP] = "AutoBot TP Panel";
   N[Panel_GroupOpen] = "Group Open Panel";
   N[Panel_ListCover] = "Panel ListCover";
   N[Panel_DetailedPosControl] = "Panel Detailed Pos Control";
   N[Panel_DetailedPosControlx2] = "Panel Detailed Pos Control 2";
//N[Panel_DetailedPosControlx2x2] = "Panel Detailed Pos Control 2 Wall";



   N[Label_Lot] = "     NOVA ULTIMATE TRADE PANEL ";
   N[Label_InfoForEA] = "                            ";
   N[Label_InfoForEA2] = "  Youtube & IG : ForexNovaProject || forexnovaproject@gmail.com";
   N[Label_Current_Buy_Volume] = "                                  ";
   N[Label_Current_Sell_Volume] = "                                     ";
   N[Label_RunEa] = " ";
   N[Label_EASettings] = "TRADE INFO";
   N[Label_EaIsRun] = "                          ";
   N[Label_LastHedge] = "                                        ";
   N[Label_AllowBuySell] = "Result:";
   N[Label_MobileSLText] = "Mobile/Trailling SL";
   N[Label_TSLDistanceText] = "DISTANCE";
   N[Label_TSLStepText] = "STEP";
   N[Label_CoverageText] = "Auto";
   N[Label_BalanceEquity] = "                                                ";
   N[Label_ACProfit] = "INITIALIZING";
   N[Label_DailyACProfit] = "                     ";
   N[Label_Account] = "                             ";
   N[Label_Server] = "          ";
   N[Label_Owner] = "                            ";
   N[Label_DateAndPing] = "            ";
   N[Label_CoverageTextx2] = "Close";
   N[Label_AutoBotTPText] = "Auto TP Bot";
   N[Label_AutoBotTPTextx2] = "                         ";

   N[Label_GroupOpenText] = "Group Positions";
   N[Label_GroupOpenTextx2] = "Opening Area";

   N[Label_ListTicket] = "   Ticket   ";
   N[Label_ListSymbol] = "   Symbol   ";
   N[Label_ListType] = "   Type   ";
   N[Label_ListPrice] = "   Price   ";
   N[Label_ListTP] = "   TP Price   ";
   N[Label_ListSL] = "   SL Price   ";
   N[Label_ListLOT] = "   Volume   ";
   N[Label_ListProfit] = "   Profit   ";
   N[Label_PositionPanelText] = "Detailed position control and editing section !";

   N[Label_LogAreaText] = "                                                               ";
   N[Label_LogAreaTextx2] = "                                                            ";



   N[Label_ChangeLogTextA] = " Mobile Stop ";
   N[Label_ChangeLogTextAx2] = " Distance Log";

   N[Label_ChangeLogTextB] = "  Mobile Stop  ";
   N[Label_ChangeLogTextBx2] = " Step Log ";

   N[Label_ChangeLogTextC] = " Auto Bot ";
   N[Label_ChangeLogTextCx2] = "(+)TP Log";

   N[Label_ChangeLogTextD] = "  Auto Bot  ";
   N[Label_ChangeLogTextDx2] = "(-)Stop Log";




   N[Button_Buy] = " Instant Buy ";
   N[Button_LotUpBuy] = "+";
   N[Button_LotDownBuy] = "-";
   N[Button_Sell] = "Instant Sell";
   N[Button_LotUppSell] = " + ";
   N[Button_LotDownnSell] = " - ";
   N[Button_CloseAll] = "Close All";
   N[Button_OnOff] = "  OFF  ";
   N[Button_ControlHedgeAll] = "Hedge All";
   N[Button_AllowBuy] = " Pendings ";
   N[Button_AllowSell] = "Pendings";
   N[Button_InstantCloseBuy] = "Close Buys";
   N[Button_InstantCloseSells] = "Close Sells";
   N[Button_CloseByTicket] = "Close By Ticket";
   N[Button_CloseMode] = "ALL";
   N[Button_TPB] = "                               ";
   N[Button_SLB] = "                           ";
   N[Button_Reverse] = "Reverse";
   N[Button_MobileSL] = "OFF";
   N[Button_UpTSLDISTANCE] = "     +     ";
   N[Button_DownTSLDISTANCE] = "           -           ";
   N[Button_UpTSLSTEP] = "      +      ";
   N[Button_DownTSLSTEP] = "            -            ";
   N[Button_Coveragex] = "       OFF       ";
   N[Button_UpCoverage] = "        +        ";
   N[Button_DownCoverage] = "         -         ";
   N[Button_UpTicketStart] = "         +         ";
   N[Button_DownTicketStart] = "             -             ";
   N[Button_UpTicketStop] = "           +           ";
   N[Button_DownTicketStop] = "               -               ";
   N[Button_LogTSL] = "LOG";
   N[Button_UpCoveragePlus] = "                            +                            ";
   N[Button_DownCoveragePlus] = "                              -                              ";

   N[Button_TPUp] = "                           +                           ";
   N[Button_TPDown] = "                          -                          ";
   N[Button_SLUp] = "                         +                         ";
   N[Button_SLDown] = "                   -                   ";

   N[Button_UpAutoBotTPStop] = "                              +                              ";
   N[Button_DownAutoBotTPStop] = "                               -                               ";
   N[Button_UpAutoBotTPStep] = "                      +                      ";
   N[Button_DownAutoBotTPStep] = "                    -                    ";
   N[Button_AutoBotTPRun] = "         OFF         ";
   N[Button_GroupOpenOnOff] = "          OFF          ";
   N[Button_LogAutoBotTP] = " LOG ";
   N[Button_GoPanel1] = "P1";
   N[Button_GoPanel2] = "P2";
   N[Button_SelectPoss] = "Select";








   N[Edit_LotBuy] = "Edit Lot Buy";
   N[Edit_LotSell] = "Edit Lot Sell";
   N[Edit_TicketStart] = "Edit Close By Ticket Start";
   N[Edit_TicketStop] = "Edit Close By Ticket Stop";
   N[Edit_TPLVL] = "Edit TP Level";
   N[Edit_SLLVL] = "Edit SL Level";
   N[Edit_TSLDistance] = "Edit TSL Distance";
   N[Edit_TSLStep] = "Edit TSL Step";
   N[Edit_Coverage] = "Edit Auto Close -$";
   N[Edit_CoveragePlus] = "Edit Auto Close +$";
   N[Edit_AutoBotTPStop] = "Auto Bot TP Step +$";
   N[Edit_AutoBotTPStep] = "Auto Bot TP Stop -$";
//N[Edit_LogValues] = "Log Values";


   N[Edit_LogA] = "Log Edit 1";
   N[Edit_LogB] = "Log Edit 2";
   N[Edit_LogC] = "Log Edit 3";
   N[Edit_LogD] = "Log Edit 4";








   N[ComboBox_PairGroup] = "GROUPS";
   N[ComboBox_ListMode] = "List Modes";
//N[ComboBox_SetLogValues] = "Set Log Values";

   N[List_Orderx1] = "List Orders1";
   N[List_Orderx2] = "List Orders2";
   N[List_Orderx3] = "List Orders3";
   N[List_Orderx4] = "List Orders4";
   N[List_Orderx5] = "List Orders5";
   N[List_Orderx6] = "List Orders6";
   N[List_Orderx7] = "List Orders7";
   N[List_Orderx8] = "List Orders8";


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:

   CPanel            panels[12];
   CButton           buttons[47];
   CLabel            labels[45];
   CEdit             edits[16];
   CComboBox         combobox[2];
   CListView         lists[8];


public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   void              runx(void);
   void              AutoTPBotRunner(void);
   void              FirstInitalize(void);
   void              InfoLabelsRunner(void);
   void              InfoPosCounterRes(void);
   void              InfoOrderCounterRes(void);
   void              TicketEditRes(void);
   void              SetLineTP(double tpp);
   void              SetLineSL(double slp);
   void              SetLinePendings(double pp);
   //void EditRestarts();
   void              ClearLines();
   bool              GetLineTP();
   bool              GetLineSL();
   bool              GetLinePendings();

   CArrayString      Positions;
   CArrayString      Orders;

   void              GetTrades();
   void              ListTrades();
   void              RefreshTrades(string refreshmode);

   void              ListRowSelector(string objj_namee);
   void              ListRowScroller(void);
   void              comboboxstring(void);


protected:
   bool              CreatePanel(void);
   bool              CreateLabel(void);
   bool              CreateButton(void);
   bool              CreateEdit(void);
   bool              CreateComboBox(void);

   bool              CreatePanelX2(void);
   bool              CreateLabelX2(void);
   bool              CreateButtonX2(void);
   bool              CreateEditX2(void);
   bool              CreateComboBoxX2(void);
   bool              CreateList(void);

   void              OnClickButton_Buy(void);
   void              OnClickButton_Sell(void);

   void              OnClickButton_LotUpBuy(void);
   void              OnClickButton_LotDownBuy(void);

   void              OnClickButton_UpTSLSTEP(void);
   void              OnClickButton_DownTSLSTEP(void);
   void              OnClickButton_UpTSLDISTANCE(void);
   void              OnClickButton_DownTSLDISTANCE(void);

   void              OnClickButton_UpTicketStart(void);
   void              OnClickButton_DownTicketStart(void);
   void              OnClickButton_UpTicketStop(void);
   void              OnClickButton_DownTicketStop(void);

   void              OnClickButton_UpCoverage(void);
   void              OnClickButton_DownCoverage(void);
   void              OnClickButton_UpCoveragePlus(void);
   void              OnClickButton_DownCoveragePlus(void);




   void              OnClickButton_LotUppSell(void);
   void              OnClickButton_LotDownnSell(void);

   void              OnClickButton_CloseAll(void);
   void              OnClickButton_CloseMode(void);
   void              OnClickButton_OnOff(void);
   void              OnClickButton_Coveragex(void);

   void              OnClickButton_ControlHedgeAll(void);

   void              OnClickButton_AllowBuy(void);
   void              OnClickButton_AllowSell(void);

   void              OnClickButton_InstantCloseBuy(void);
   void              OnClickButton_InstantCloseSells(void);

   void              OnClickButton_CloseByTicket(void);

   void              OnClickButton_MobileSL(void);
   void              OnClickButton_LogTSL(void);
   void              OnClickButton_Reverse(void);

   void              OnClickButton_Button_TPB(void);
   void              OnClickButton_Button_SLB(void);

   void              OnClickButton_TPUp(void);
   void              OnClickButton_TPDown(void);
   void              OnClickButton_SLUp(void);
   void              OnClickButton_SLDown(void);
   void              OnClickButton_AutoBotTPRun(void);

   void              OnClickButton_UpAutoBotTPStop(void);
   void              OnClickButton_DownAutoBotTPStop(void);
   void              OnClickButton_UpAutoBotTPStep(void);
   void              OnClickButton_DownAutoBotTPStep(void);
   void              OnClickButton_GroupOpenOnOff(void);
   void              OnClickButton_LogAutoBotTP(void);
   void              OnClickButton_GoOrdersPanel(void);
   void              OnClickButton_SelectPoss(void);



   void              EditTPRestarts(void);
   void              EditSLRestarts(void);
   void              Edit0Restarts(void);
   void              Edit1Restarts(void);
   void              Edit6Restarts(void);
   void              Edit7Restarts(void);
   void              Edit8Restarts(void);
   void              Edit9Restarts(void);
   void              Edit10Restarts(void);
   void              Edit11Restarts(void);

  };

EVENT_MAP_BEGIN(CControlsDialog)



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
if(PanelScreenController==0)
  {
   ON_EVENT(ON_CLICK, buttons[0], OnClickButton_Buy)
   ON_EVENT(ON_CLICK, buttons[1], OnClickButton_LotUpBuy)
   ON_EVENT(ON_CLICK, buttons[2], OnClickButton_LotDownBuy)
   ON_EVENT(ON_CLICK, buttons[3], OnClickButton_Sell)
   ON_EVENT(ON_CLICK, buttons[4], OnClickButton_LotUppSell)
   ON_EVENT(ON_CLICK, buttons[5], OnClickButton_LotDownnSell)
   ON_EVENT(ON_CLICK, buttons[6], OnClickButton_CloseAll)
   ON_EVENT(ON_CLICK, buttons[7], OnClickButton_OnOff)
   ON_EVENT(ON_CLICK, buttons[8], OnClickButton_ControlHedgeAll)
   ON_EVENT(ON_CLICK, buttons[9], OnClickButton_AllowBuy)
   ON_EVENT(ON_CLICK, buttons[10], OnClickButton_AllowSell)
   ON_EVENT(ON_CLICK, buttons[11], OnClickButton_InstantCloseBuy)
   ON_EVENT(ON_CLICK, buttons[12], OnClickButton_InstantCloseSells)
   ON_EVENT(ON_CLICK, buttons[13], OnClickButton_CloseByTicket)
   ON_EVENT(ON_CLICK, buttons[14], OnClickButton_CloseMode)
   ON_EVENT(ON_CLICK, buttons[15], OnClickButton_Button_TPB)
   ON_EVENT(ON_CLICK, buttons[16], OnClickButton_Button_SLB)
   ON_EVENT(ON_CLICK, buttons[17], OnClickButton_Reverse)

   ON_EVENT(ON_CLICK, buttons[18], OnClickButton_MobileSL)
   ON_EVENT(ON_CLICK, buttons[30], OnClickButton_LogTSL)

   ON_EVENT(ON_CLICK, buttons[21], OnClickButton_UpTSLSTEP)
   ON_EVENT(ON_CLICK, buttons[22], OnClickButton_DownTSLSTEP)
   ON_EVENT(ON_CLICK, buttons[19], OnClickButton_UpTSLDISTANCE)
   ON_EVENT(ON_CLICK, buttons[20], OnClickButton_DownTSLDISTANCE)

   ON_EVENT(ON_CLICK, buttons[26], OnClickButton_UpTicketStart)
   ON_EVENT(ON_CLICK, buttons[27], OnClickButton_DownTicketStart)
   ON_EVENT(ON_CLICK, buttons[28], OnClickButton_UpTicketStop)
   ON_EVENT(ON_CLICK, buttons[29], OnClickButton_DownTicketStop)


   ON_EVENT(ON_CLICK, buttons[24], OnClickButton_UpCoverage)
   ON_EVENT(ON_CLICK, buttons[25], OnClickButton_DownCoverage)
   ON_EVENT(ON_CLICK, buttons[31], OnClickButton_UpCoveragePlus)
   ON_EVENT(ON_CLICK, buttons[32], OnClickButton_DownCoveragePlus)

   ON_EVENT(ON_CLICK, buttons[23], OnClickButton_Coveragex)
   ON_EVENT(ON_CLICK, buttons[41], OnClickButton_AutoBotTPRun)

   ON_EVENT(ON_CLICK, buttons[33], OnClickButton_TPUp)
   ON_EVENT(ON_CLICK, buttons[34], OnClickButton_TPDown)
   ON_EVENT(ON_CLICK, buttons[35], OnClickButton_SLUp)
   ON_EVENT(ON_CLICK, buttons[36], OnClickButton_SLDown)

   ON_EVENT(ON_CLICK, buttons[37], OnClickButton_UpAutoBotTPStep)
   ON_EVENT(ON_CLICK, buttons[38], OnClickButton_DownAutoBotTPStep)

   ON_EVENT(ON_CLICK, buttons[39], OnClickButton_UpAutoBotTPStop)
   ON_EVENT(ON_CLICK, buttons[40], OnClickButton_DownAutoBotTPStop)

   ON_EVENT(ON_CLICK, buttons[42], OnClickButton_GroupOpenOnOff)
   ON_EVENT(ON_CLICK, buttons[43], OnClickButton_LogAutoBotTP)


   ON_EVENT(ON_END_EDIT, edits[0], Edit0Restarts)
   ON_EVENT(ON_END_EDIT, edits[1], Edit1Restarts)
   ON_EVENT(ON_END_EDIT, edits[4], EditTPRestarts)
   ON_EVENT(ON_END_EDIT, edits[5], EditSLRestarts)
   ON_EVENT(ON_END_EDIT, edits[7], Edit7Restarts)
   ON_EVENT(ON_END_EDIT, edits[6], Edit6Restarts)
   ON_EVENT(ON_END_EDIT, edits[9], Edit8Restarts)
   ON_EVENT(ON_END_EDIT, edits[8], Edit9Restarts)
   ON_EVENT(ON_END_EDIT, edits[10], Edit10Restarts)
   ON_EVENT(ON_END_EDIT, edits[11], Edit11Restarts)

   ON_EVENT(ON_CLICK, buttons[45], OnClickButton_GoOrdersPanel)
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
if(PanelScreenController==1)
  {
   ON_EVENT(ON_CLICK, buttons[44], OnClickButton_GoOrdersPanel)
   ON_EVENT(ON_CLICK, buttons[6], OnClickButton_CloseAll)
   ON_EVENT(ON_CLICK, buttons[17], OnClickButton_Reverse)
   ON_EVENT(ON_CLICK, buttons[8], OnClickButton_ControlHedgeAll)
   ON_EVENT(ON_CLICK, buttons[46], OnClickButton_SelectPoss)

  }

EVENT_MAP_END(CAppDialog)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void)
  {
   Print("NOVA ULTIMATE TRADE PANEL ONLINE");
  }
CControlsDialog::~CControlsDialog(void) {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit0Restarts(void)
  {
   lotbuy= StringToDouble(edits[0].Text());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit1Restarts(void)
  {
   lotsell= StringToDouble(edits[1].Text());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::EditTPRestarts(void)
  {
   SetLineTP(edits[4].Text());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::EditSLRestarts(void)
  {
   SetLineSL(edits[5].Text());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit6Restarts(void)
  {
   traillingDistance= StringToDouble(edits[6].Text());
   traillingDistancex2= traillingDistance/10;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit7Restarts(void)
  {
   traillingStep= StringToDouble(edits[7].Text());
   traillingStepx2=traillingStep/10;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit8Restarts(void)
  {
   coveragelevel= StringToDouble(edits[9].Text());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit9Restarts(void)
  {
   coveragelevelplus= StringToDouble(edits[8].Text());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit10Restarts(void)
  {
   AutoTPBotStepLevel= StringToDouble(edits[10].Text());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::Edit11Restarts(void)
  {
   AutoTPBotStopLevel= StringToDouble(edits[11].Text());

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::comboboxstring(void)
  {
   comboboxstringVALUE=combobox[0].Select();
  }


/*
   N[Edit_Coverage] = "Edit Auto Close -$";
   N[Edit_CoveragePlus] = "Edit Auto Close +$";
   N[Edit_AutoBotTPStop] = "Auto Bot TP Step +$";
   N[Edit_AutoBotTPStep] = "Auto Bot TP Stop -$";
*/
void CControlsDialog::ListRowScroller(void)
  {
   lists[7].offsetchanger(lists[0].offsetcheck());
   lists[1].offsetchanger(lists[0].offsetcheck());
   lists[2].offsetchanger(lists[0].offsetcheck());
   lists[3].offsetchanger(lists[0].offsetcheck());
   lists[4].offsetchanger(lists[0].offsetcheck());
   lists[5].offsetchanger(lists[0].offsetcheck());
   lists[6].offsetchanger(lists[0].offsetcheck());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::ListRowSelector(string objj_namee)
  {
   if(objj_namee=="List Orders8")
     {
      lists[0].Select(lists[7].CurrentSelectedRowNumber());
      lists[1].Select(lists[7].CurrentSelectedRowNumber());
      lists[2].Select(lists[7].CurrentSelectedRowNumber());
      lists[3].Select(lists[7].CurrentSelectedRowNumber());
      lists[4].Select(lists[7].CurrentSelectedRowNumber());
      lists[5].Select(lists[7].CurrentSelectedRowNumber());
      lists[6].Select(lists[7].CurrentSelectedRowNumber());
     }
   if(objj_namee=="List Orders7")
     {
      lists[0].Select(lists[6].CurrentSelectedRowNumber());
      lists[1].Select(lists[6].CurrentSelectedRowNumber());
      lists[2].Select(lists[6].CurrentSelectedRowNumber());
      lists[3].Select(lists[6].CurrentSelectedRowNumber());
      lists[4].Select(lists[6].CurrentSelectedRowNumber());
      lists[5].Select(lists[6].CurrentSelectedRowNumber());
      lists[7].Select(lists[6].CurrentSelectedRowNumber());
     }
   if(objj_namee=="List Orders6")
     {
      lists[0].Select(lists[5].CurrentSelectedRowNumber());
      lists[1].Select(lists[5].CurrentSelectedRowNumber());
      lists[2].Select(lists[5].CurrentSelectedRowNumber());
      lists[3].Select(lists[5].CurrentSelectedRowNumber());
      lists[4].Select(lists[5].CurrentSelectedRowNumber());
      lists[6].Select(lists[5].CurrentSelectedRowNumber());
      lists[7].Select(lists[5].CurrentSelectedRowNumber());
     }
   if(objj_namee=="List Orders5")
     {
      lists[0].Select(lists[4].CurrentSelectedRowNumber());
      lists[1].Select(lists[4].CurrentSelectedRowNumber());
      lists[2].Select(lists[4].CurrentSelectedRowNumber());
      lists[3].Select(lists[4].CurrentSelectedRowNumber());
      lists[5].Select(lists[4].CurrentSelectedRowNumber());
      lists[6].Select(lists[4].CurrentSelectedRowNumber());
      lists[7].Select(lists[4].CurrentSelectedRowNumber());
     }
   if(objj_namee=="List Orders4")
     {
      lists[0].Select(lists[3].CurrentSelectedRowNumber());
      lists[1].Select(lists[3].CurrentSelectedRowNumber());
      lists[2].Select(lists[3].CurrentSelectedRowNumber());
      lists[4].Select(lists[3].CurrentSelectedRowNumber());
      lists[5].Select(lists[3].CurrentSelectedRowNumber());
      lists[6].Select(lists[3].CurrentSelectedRowNumber());
      lists[7].Select(lists[3].CurrentSelectedRowNumber());
     }
   if(objj_namee=="List Orders3")
     {
      lists[0].Select(lists[2].CurrentSelectedRowNumber());
      lists[1].Select(lists[2].CurrentSelectedRowNumber());
      lists[3].Select(lists[2].CurrentSelectedRowNumber());
      lists[4].Select(lists[2].CurrentSelectedRowNumber());
      lists[5].Select(lists[2].CurrentSelectedRowNumber());
      lists[6].Select(lists[2].CurrentSelectedRowNumber());
      lists[7].Select(lists[2].CurrentSelectedRowNumber());
     }
   if(objj_namee=="List Orders2")
     {
      lists[0].Select(lists[1].CurrentSelectedRowNumber());
      lists[2].Select(lists[1].CurrentSelectedRowNumber());
      lists[3].Select(lists[1].CurrentSelectedRowNumber());
      lists[4].Select(lists[1].CurrentSelectedRowNumber());
      lists[5].Select(lists[1].CurrentSelectedRowNumber());
      lists[6].Select(lists[1].CurrentSelectedRowNumber());
      lists[7].Select(lists[1].CurrentSelectedRowNumber());
     }
   if(objj_namee=="List Orders1")
     {
      lists[1].Select(lists[0].CurrentSelectedRowNumber());
      lists[2].Select(lists[0].CurrentSelectedRowNumber());
      lists[3].Select(lists[0].CurrentSelectedRowNumber());
      lists[4].Select(lists[0].CurrentSelectedRowNumber());
      lists[5].Select(lists[0].CurrentSelectedRowNumber());
      lists[6].Select(lists[0].CurrentSelectedRowNumber());
      lists[7].Select(lists[0].CurrentSelectedRowNumber());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::SetLinePendings(double pp)
  {
   if(ObjectFind(0, "PENDINGS ORDER SET LEVEL") == 0)
      ObjectDelete(0, "PENDINGS ORDER SET LEVEL");
   ObjectCreate(0, "PENDINGS ORDER SET LEVEL", OBJ_TREND,0,TimeCurrent(),pp,iTime(_Symbol,NULL,20),pp);
   ObjectSetInteger(0, "PENDINGS ORDER SET LEVEL", OBJPROP_COLOR, clrAqua);
   ObjectSetInteger(0, "PENDINGS ORDER SET LEVEL", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "PENDINGS ORDER SET LEVEL", OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, "PENDINGS ORDER SET LEVEL", OBJPROP_BACK, false);
   ObjectSetInteger(0,"PENDINGS ORDER SET LEVEL",OBJPROP_WIDTH,3);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::SetLineSL(double slp)
  {
   if(ObjectFind(0, "SL LEVEL") == 0)
      ObjectDelete(0, "SL LEVEL");
   ObjectCreate(0, "SL LEVEL", OBJ_TREND,0,TimeCurrent(),slp,iTime(_Symbol,NULL,20),slp);
   ObjectSetInteger(0, "SL LEVEL", OBJPROP_COLOR, clrTomato);
   ObjectSetInteger(0, "SL LEVEL", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "SL LEVEL", OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, "SL LEVEL", OBJPROP_BACK, false);
   ObjectSetInteger(0,"SL LEVEL",OBJPROP_WIDTH,3);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::SetLineTP(double tpp)
  {
   if(ObjectFind(0, "TP LEVEL") == 0)
      ObjectDelete(0, "TP LEVEL");
   ObjectCreate(0, "TP LEVEL", OBJ_TREND,0,TimeCurrent(),tpp,iTime(_Symbol,NULL,20),tpp);
   ObjectSetInteger(0, "TP LEVEL", OBJPROP_COLOR, clrLime);
   ObjectSetInteger(0, "TP LEVEL", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "TP LEVEL", OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, "TP LEVEL", OBJPROP_BACK, false);
   ObjectSetInteger(0,"TP LEVEL",OBJPROP_WIDTH,3);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::TicketEditRes(void)
  {
   if(PositionsTotal()==0)
     {
      edits[3].Text("NO POSITION");
      edits[2].Text("NO POSITION");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::ClearLines(void)
  {
   if(ObjectFind(0, "TP LEVEL") == 0)
      ObjectDelete(0, "TP LEVEL");
   if(ObjectFind(0, "SL LEVEL") == 0)
      ObjectDelete(0, "SL LEVEL");
   if(ObjectFind(0, "PENDINGS ORDER SET LEVEL") == 0)
      ObjectDelete(0, "PENDINGS ORDER SET LEVEL");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::GetLineTP(void)
  {
   if(ObjectFind(0, "TP LEVEL") == 0)
     {
      ExtTakeProfit = (((ObjectGetDouble(0, "TP LEVEL", OBJPROP_PRICE,0))+(ObjectGetDouble(0, "TP LEVEL", OBJPROP_PRICE,1)))/2);
      edits[4].Text(DoubleToString(ExtTakeProfit,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }

   else
     {
      ExtTakeProfit = 0;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::GetLineSL(void)
  {
   if(ObjectFind(0, "SL LEVEL") == 0)
     {
      ExtStopLoss = (((ObjectGetDouble(0, "SL LEVEL", OBJPROP_PRICE,0))+(ObjectGetDouble(0, "SL LEVEL", OBJPROP_PRICE,1)))/2);
      edits[5].Text(DoubleToString(ExtStopLoss,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

     }

   else
     {
      ExtStopLoss = 0;
     }

   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::GetLinePendings(void)
  {
   if(ObjectFind(0, "PENDINGS ORDER SET LEVEL") == 0)
     {
      PendingsLevel = (((ObjectGetDouble(0, "PENDINGS ORDER SET LEVEL", OBJPROP_PRICE,0))+(ObjectGetDouble(0, "PENDINGS ORDER SET LEVEL", OBJPROP_PRICE,1)))/2);
     }

   else
     {
      PendingsLevel = 0;
      return(false);
     }


   return(true);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::GetTrades(void)
  {
   int ticket, digitsx;
   string symbol, item, sType;
   double price, takeProfit, stopLoss, volume, possprofit;
   ENUM_ORDER_TYPE type;

//OPENED POSITIONS
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ticket = PositionGetTicket(i);
      symbol = PositionGetSymbol(i);
      //if(PositionSelectByTicket(ticket) && symbol == _Symbol)
      if(PositionSelectByTicket(ticket))
        {
         type = PositionGetInteger(POSITION_TYPE);
         switch(type)
           {
            case ORDER_TYPE_BUY:
               sType = "BUY";
               break;
            case ORDER_TYPE_BUY_STOP:
               sType = "BUY_STOP";
               break;
            case ORDER_TYPE_BUY_LIMIT:
               sType = "BUY_LIMIT";
               break;
            case ORDER_TYPE_SELL:
               sType = "SELL";
               break;
            case ORDER_TYPE_SELL_STOP:
               sType = "SELL_STOP";
               break;
            case ORDER_TYPE_SELL_LIMIT:
               sType = "SELL_LIMIT";
               break;
           }
         price = PositionGetDouble(POSITION_PRICE_OPEN);
         takeProfit = PositionGetDouble(POSITION_TP);
         stopLoss = PositionGetDouble(POSITION_SL);
         volume = PositionGetDouble(POSITION_VOLUME);
         possprofit = PositionGetDouble(POSITION_PROFIT);
         digitsx = SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         item = ticket +" # "+symbol + " # " + sType + " # " + DoubleToString(price, digitsx) + " # " +DoubleToString(takeProfit, digitsx) + " # " +DoubleToString(stopLoss, digitsx) + " # " + DoubleToString(volume,2) + " # " + DoubleToString(possprofit,2);
         //item = ticket;
         Positions.Add(item);
        }
     }

//PENDING ORDERS
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         symbol = OrderGetString(ORDER_SYMBOL);

         type = OrderGetInteger(ORDER_TYPE);
         if(type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_STOP || type == ORDER_TYPE_SELL_LIMIT)
           {
            switch(type)
              {
               case ORDER_TYPE_BUY:
                  sType = "BUY";
                  break;
               case ORDER_TYPE_BUY_STOP:
                  sType = "BUY_STOP";
                  break;
               case ORDER_TYPE_BUY_LIMIT:
                  sType = "BUY_LIMIT";
                  break;
               case ORDER_TYPE_SELL:
                  sType = "SELL";
                  break;
               case ORDER_TYPE_SELL_STOP:
                  sType = "SELL_STOP";
                  break;
               case ORDER_TYPE_SELL_LIMIT:
                  sType = "SELL_LIMIT";
                  break;
              }
            price = OrderGetDouble(ORDER_PRICE_OPEN);
            takeProfit = OrderGetDouble(ORDER_TP);
            stopLoss = OrderGetDouble(ORDER_SL);
            volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            digitsx = SymbolInfoInteger(symbol,SYMBOL_DIGITS);
            string ssstype;
            if(sType=="BUY_STOP")
              {
               ssstype="Buy_S";
              }
            if(sType=="BUY_LIMIT")
              {
               ssstype="Buy_L";
              }
            if(sType=="SELL_STOP")
              {
               ssstype="Sell_S";
              }
            if(sType=="SELL_LIMIT")
              {
               ssstype="Sell_L";
              }

            item = ticket +" # "+symbol + " # " + ssstype + " # " + DoubleToString(price, digitsx) + " # " +DoubleToString(takeProfit, digitsx) + " # " +DoubleToString(stopLoss, digitsx) + " # " + DoubleToString(volume,2) + " # " + "PENDING";
            Orders.Add(item);
           }

        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::ListTrades(void)
  {
   for(int i = 0; i < Positions.Total()+Orders.Total(); i++)
     {
      //lists[0].Alignment(WND_ALIGN_NONE,20,0,0,0);
      //lists[0].Align(Rect());
      lists[0].ChangeFontSize(i,8);
      lists[1].ChangeFontSize(i,8);
      lists[2].ChangeFontSize(i,8);
      lists[3].ChangeFontSize(i,8);
      lists[4].ChangeFontSize(i,8);
      lists[5].ChangeFontSize(i,8);
      lists[6].ChangeFontSize(i,8);
      lists[7].ChangeFontSize(i,8);
     }
   for(int i = 0; i < Positions.Total(); i++)
     {


      string a[8];
      StringSplit(Positions.At(i),'#',a);

      lists[0].AddItemWS(a[0]);
      lists[1].AddItem(a[1]);
      lists[2].AddItem(a[2]);
      lists[3].AddItem(a[3]);
      lists[4].AddItem(a[4]);
      lists[5].AddItem(a[5]);
      lists[6].AddItem(a[6]);
      lists[7].AddItem(a[7]);
      //lists[0].Alignment(WND_ALIGN_RIGHT,0,0,0,0);

     }
   for(int i = 0; i < Orders.Total(); i++)
     {


      string b[8];
      StringSplit(Orders.At(i),'#',b);

      lists[0].AddItemWS(b[0]);
      lists[1].AddItem(b[1]);
      lists[2].AddItem(b[2]);
      lists[3].AddItem(b[3]);
      lists[4].AddItem(b[4]);
      lists[5].AddItem(b[5]);
      lists[6].AddItem(b[6]);
      lists[7].AddItem(b[7]);
     }
//lists[0].Select(0);
//Alert(lists[0].Select());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::RefreshTrades(string refreshmode)
  {
   if(refreshmode=="OnnnTrade")
     {
      Orders.DeleteRange(0, Orders.Total());
      Positions.DeleteRange(0, Positions.Total());
      GetTrades();
      lists[0].ItemsClear();
      lists[1].ItemsClear();
      lists[2].ItemsClear();
      lists[3].ItemsClear();
      lists[4].ItemsClear();
      lists[5].ItemsClear();
      lists[6].ItemsClear();
      lists[7].ItemsClear();
      ListTrades();
      lists[7].offsetchanger(lists[0].offsetcheck());

     }
   if(refreshmode=="OnnnTick")
     {
      Orders.DeleteRange(0, Orders.Total());
      Positions.DeleteRange(0, Positions.Total());
      GetTrades();
      for(int i = 0; i < Positions.Total()+Orders.Total(); i++)
        {
         lists[7].ChangeFontSize(i,8);
        }

      for(int i = 0; i < Positions.Total(); i++)
        {
         string a[8];
         StringSplit(Positions.At(i),'#',a);
         //lists[7].AddItem(a[7]);
         lists[7].ItemUpdate(i,a[7]);

        }
      //lists[7].Redraw();
      lists[7].offsetchanger(lists[0].offsetcheck());
      lists[7].ColorControl(7);
      lists[2].ColorControl(2);

     }
  }
/*

   for(int i = 0; i < Positions.Total(); i++)
   {


      string a[8];
      StringSplit(Positions.At(i),'#',a);

      lists[0].AddItem(a[0]);
      lists[1].AddItem(a[1]);
      lists[2].AddItem(a[2]);
      lists[3].AddItem(a[3]);
      lists[4].AddItem(a[4]);
      lists[5].AddItem(a[5]);
      lists[6].AddItem(a[6]);
      lists[7].AddItemWS(a[7]);
   }
   for(int i = 0; i < Orders.Total(); i++)
   {


      string b[8];
      StringSplit(Orders.At(i),'#',b);

      lists[0].AddItem(b[0]);
      lists[1].AddItem(b[1]);
      lists[2].AddItem(b[2]);
      lists[3].AddItem(b[3]);
      lists[4].AddItem(b[4]);
      lists[5].AddItem(b[5]);
      lists[6].AddItem(b[6]);
      lists[7].AddItemWS(b[7]);
   }

*/





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
  {
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
      return(false);
   if(PanelScreenController==0)
     {
      if(!CreatePanel())
         return(false);
     }
   if(PanelScreenController==0)
     {
      if(!CreateLabel())
         return(false);
     }
   if(PanelScreenController==0)
     {
      if(!CreateButton())
         return(false);
     }
   if(PanelScreenController==0)
     {
      if(!CreateEdit())
         return(false);
     }
   if(PanelScreenController==0)
     {
      if(!CreateComboBox())
         return(false);
     }

   if(PanelScreenController==1)
     {
      if(!CreatePanelX2())
         return(false);
     }
   if(PanelScreenController==1)
     {
      if(!CreateLabelX2())
         return(false);
     }
   if(PanelScreenController==1)
     {
      if(!CreateButtonX2())
         return(false);
     }
   if(PanelScreenController==1)
     {
      if(!CreateEditX2())
         return(false);
     }
   if(PanelScreenController==1)
     {
      if(!CreateComboBoxX2())
         return(false);
     }
   if(PanelScreenController==1)
     {
      if(!CreateList())
         return(false);
     }


   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreatePanel(void)
  {

   for(int i = 0; i < 9; i++)
     {
      if(!panels[i].Create(m_chart_id, N[Panel_Lot+i], m_subwin, XY[Panel_Lot+i][X1], XY[Panel_Lot+i][Y1], XY[Panel_Lot+i][X2], XY[Panel_Lot+i][Y2]))
         return(false);
      if(i==0)
        {
         if(!panels[i].ColorBackground(clrLavender))
            return(false);
         if(!panels[i].ColorBorder(clrLightSteelBlue))
            return(false);

        }
      if(i==1)
        {
         if(!panels[i].ColorBackground(clrSnow))
            return(false);
         if(!panels[i].ColorBorder(clrLightSteelBlue))
            return(false);

        }
      if(i==2 || i==3 || i==4 || i==5 || i==6 || i==7 || i==8)
        {
         if(!panels[i].ColorBorder(clrCornflowerBlue))
            return(false);

        }
      if(!Add(panels[i]))
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreatePanelX2(void)
  {
   for(int i = 0; i < 1; i++)
     {
      if(!panels[i].Create(m_chart_id, N[Panel_Lot+i], m_subwin, XY[Panel_Lot+i][X1], XY[Panel_Lot+i][Y1], XY[Panel_Lot+i][X2], XY[Panel_Lot+i][Y2]))
         return(false);
      if(!panels[i].ColorBackground(clrLavender))
         return(false);
      if(!panels[i].ColorBorder(clrLightSteelBlue))
         return(false);
      if(!Add(panels[i]))
         return(false);
     }


   if(!panels[9].Create(m_chart_id, N[Panel_Lot+9], m_subwin, XY[Panel_Lot+9][X1], XY[Panel_Lot+9][Y1], XY[Panel_Lot+9][X2], XY[Panel_Lot+9][Y2]))
      return(false);
   if(!panels[9].ColorBorder(clrLightSteelBlue))
      return(false);
   if(!Add(panels[9]))
      return(false);

   if(!panels[10].Create(m_chart_id, N[Panel_Lot+10], m_subwin, XY[Panel_Lot+10][X1], XY[Panel_Lot+10][Y1], XY[Panel_Lot+10][X2], XY[Panel_Lot+10][Y2]))
      return(false);
   if(!panels[10].ColorBorder(clrLightSteelBlue))
      return(false);
   if(!Add(panels[10]))
      return(false);

//if(!panels[11].Create(m_chart_id, N[Panel_Lot+11], m_subwin, XY[Panel_Lot+11][X1], XY[Panel_Lot+11][Y1], XY[Panel_Lot+11][X2], XY[Panel_Lot+11][Y2])) return(false);
//if(!panels[11].ColorBorder(clrLightSteelBlue)) return(false);
//if(!Add(panels[11])) return(false);

//if(!panels[12].Create(m_chart_id, N[Panel_Lot+12], m_subwin, XY[Panel_Lot+12][X1], XY[Panel_Lot+12][Y1], XY[Panel_Lot+12][X2], XY[Panel_Lot+12][Y2])) return(false);
//if(!panels[12].ColorBorder(clrLightSteelBlue)) return(false);
//if(!Add(panels[12])) return(false);

   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel(void)
  {
   for(int i = 0; i < 26; i++)
     {
      if(!labels[i].Create(m_chart_id, N[Label_Lot+i], m_subwin, XY[Label_Lot+i][X1], XY[Label_Lot+i][Y1]+SPAN, XY[Label_Lot+i][X2], XY[Label_Lot+i][Y2]))
         return(false);
      if(!labels[i].Text(N[Label_Lot+i]))
         return(false);
      if(i==0)
        {
         if(!labels[i].Font("Arial Black"))
            return(false);
         if(!labels[i].FontSize(12))
            return(false);
         if(!labels[i].Color(clrDarkSlateBlue))
            return(false);

        }
      if(i==15)
        {
         if(!labels[i].Font("Arial Black"))
            return(false);

         if(!labels[i].FontSize(11))
            return(false);
         if(!labels[i].Color(clrDodgerBlue))
            return(false);
        }
      if(i==1 || i==2)
        {
         if(!labels[i].FontSize(8))
            return(false);
        }
      if(i==3 || i==4 || i==8)
        {
         if(!labels[i].FontSize(8))
            return(false);
        }
      if(i==19 || i==18 || i==17 || i==20)
        {
         if(!labels[i].FontSize(7))
            return(false);
        }
      if(i==9)
        {
         if(!labels[i].FontSize(11))
            return(false);
        }
      if(i==10 || i==11 || i==12)
        {
         if(!labels[i].FontSize(9))
            return(false);
        }
      if(i==14 || i==16)
        {
         if(!labels[i].Font("Arial Black"))
            return(false);

         if(!labels[i].FontSize(8))
            return(false);
         if(!labels[i].Color(clrDarkBlue))
            return(false);
        }
      if(i==10 || i==13 || i==21 ||i==22 ||i==23 || i==24 || i==25)
        {
         if(!labels[i].FontSize(9))
            return(false);
         if(!labels[i].Color(clrDarkSlateBlue))
            return(false);
         if(i==25 || i==24 || i==23 || i==22 ||i==21 || i==13 || i==10)
           {
            if(!labels[i].FontSize(8))
               return(false);
           }

        }
      if(i==6 || i==7)
        {
         if(!labels[i].FontSize(8))
            return(false);
         if(!labels[i].Color(clrDarkSlateBlue))
            return(false);
        }
      if(i==5)
        {
         if(!labels[i].FontSize(8))
            return(false);
        }
      if(i==12 || i==11)
        {

         if(!labels[i].FontSize(7))
            return(false);
        }
      if(!Add(labels[i]))
         return(false);
     }
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabelX2(void)
  {
   for(int i = 0; i < 1; i++)
     {
      if(!labels[i].Create(m_chart_id, N[Label_Lot+i], m_subwin, XY[Label_Lot+i][X1], XY[Label_Lot+i][Y1]+SPAN, XY[Label_Lot+i][X2], XY[Label_Lot+i][Y2]))
         return(false);
      if(!labels[i].Text(N[Label_Lot+i]))
         return(false);
      if(i==0)
        {
         if(!labels[i].Font("Arial Black"))
            return(false);
         if(!labels[i].FontSize(12))
            return(false);
         if(!labels[i].Color(clrDarkSlateBlue))
            return(false);

        }

      if(!Add(labels[i]))
         return(false);
     }
   for(int i = 26; i < 34; i++)
     {
      if(!labels[i].Create(m_chart_id, N[Label_Lot+i], m_subwin, XY[Label_Lot+i][X1], XY[Label_Lot+i][Y1]+SPAN, XY[Label_Lot+i][X2], XY[Label_Lot+i][Y2]))
         return(false);
      if(!labels[i].Text(N[Label_Lot+i]))
         return(false);
      if(!labels[i].FontSize(8))
         return(false);
      if(!labels[i].Color(clrDarkSlateBlue))
         return(false);
      if(!Add(labels[i]))
         return(false);
     }
   for(int i = 34; i < 35; i++)
     {
      if(!labels[i].Create(m_chart_id, N[Label_Lot+i], m_subwin, XY[Label_Lot+i][X1], XY[Label_Lot+i][Y1]+SPAN, XY[Label_Lot+i][X2], XY[Label_Lot+i][Y2]))
         return(false);
      if(!labels[i].Text(N[Label_Lot+i]))
         return(false);
      if(!labels[i].FontSize(8))
         return(false);
      //if(!labels[i].Color(clrDarkSlateBlue)) return(false);
      if(!Add(labels[i]))
         return(false);
     }
   for(int i = 35; i < 37; i++)
     {
      if(!labels[i].Create(m_chart_id, N[Label_Lot+i], m_subwin, XY[Label_Lot+i][X1], XY[Label_Lot+i][Y1]+SPAN, XY[Label_Lot+i][X2], XY[Label_Lot+i][Y2]))
         return(false);
      if(!labels[i].Text(N[Label_Lot+i]))
         return(false);
      if(!labels[i].FontSize(8))
         return(false);
      if(!labels[i].Color(clrDarkSlateBlue))
         return(false);
      if(!Add(labels[i]))
         return(false);
     }
   /*for(int i = 37; i < 45; i++)
   {
      if(!labels[i].Create(m_chart_id, N[Label_Lot+i], m_subwin, XY[Label_Lot+i][X1], XY[Label_Lot+i][Y1]+SPAN, XY[Label_Lot+i][X2], XY[Label_Lot+i][Y2])) return(false);
      if(!labels[i].Text(N[Label_Lot+i])) return(false);
      if(!labels[i].FontSize(7)) return(false);
      if(!labels[i].Font("Roboto")) return(false);
      if(!labels[i].Color(clrBlack)) return(false);
      if(!Add(labels[i])) return(false);
   }*/
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButton(void)
  {
   for(int i = 0; i < 44; i++)
     {
      if(!buttons[i].Create(m_chart_id, N[Button_Buy+i], m_subwin, XY[Button_Buy+i][X1], XY[Button_Buy+i][Y1], XY[Button_Buy+i][X2], XY[Button_Buy+i][Y2]))
         return(false);
      if(!buttons[i].Text(N[Button_Buy+i]))
         return(false);
      if(i==0)
        {
         if(!buttons[i].ColorBackground(clrDodgerBlue))
            return(false);
        }
      if(i==3)
        {
         if(!buttons[i].ColorBackground(clrOrangeRed))
            return(false);
        }

      if(i==6)
        {
         if(!buttons[i].ColorBackground(clrGray))
            return(false);
         //earun=true;
         if(!buttons[i].Text("Close All"))
            return(false);

        }
      if(i==7)
        {
         if(!buttons[i].ColorBackground(clrOrangeRed))
            return(false);
         //earun=true;
         if(!buttons[i].FontSize(7))
            return(false);

        }
      if(i==8)
        {
         if(!buttons[i].ColorBackground(clrMediumSpringGreen))
            return(false);
         //earun=true;
         if(!buttons[i].FontSize(9))
            return(false);
        }
      if(i==9)
        {
         if(!buttons[i].ColorBackground(clrDeepSkyBlue))
            return(false);
         //earun=true;
         //if(!buttons[i].FontSize(6)) return(false);
        }
      if(i==10)
        {
         if(!buttons[i].ColorBackground(clrTomato))
            return(false);
         //earun=true;
         //if(!buttons[i].FontSize(6)) return(false);
        }
      if(i==11 || i==12 || i==14)
        {
         if(!buttons[i].ColorBackground(clrLightCyan))
            return(false);
         //earun=true;
         if(!buttons[i].FontSize(9))
            return(false);

        }
      if(i==15 || i==16)
        {
         if(!buttons[i].ColorBackground(clrOrangeRed))
            return(false);
         if(!buttons[i].FontSize(8))
            return(false);


        }
      if(i==17)
        {
         if(!buttons[i].ColorBackground(clrLightCyan))
            return(false);

         if(!buttons[i].FontSize(8))
            return(false);
        }
      if(i==18 || i==23 || i==30 || i==41 || i==42 || i==43)
        {
         if(!buttons[i].ColorBackground(clrTomato))
            return(false);

         if(!buttons[i].FontSize(7))
            return(false);
        }

      if(!buttons[i].ColorBorder(clrLightBlue))
         return(false);
      if(!buttons[i].Font("Arial Black"))
         return(false);
      if(!Add(buttons[i]))
         return(false);
     }

   if(!buttons[45].Create(m_chart_id, N[Button_Buy+45], m_subwin, XY[Button_Buy+45][X1], XY[Button_Buy+45][Y1], XY[Button_Buy+45][X2], XY[Button_Buy+45][Y2]))
      return(false);
   if(!buttons[45].Text(N[Button_Buy+45]))
      return(false);
   if(!buttons[45].FontSize(8))
      return(false);
   if(!buttons[45].ColorBorder(clrLightBlue))
      return(false);
   if(!buttons[45].ColorBackground(clrPaleTurquoise))
      return(false);
   if(!buttons[45].Font("Arial Black"))
      return(false);
   if(!Add(buttons[45]))
      return(false);

   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonX2(void)
  {
   for(int i = 44; i < 45; i++)
     {
      if(!buttons[i].Create(m_chart_id, N[Button_Buy+i], m_subwin, XY[Button_Buy+i][X1], XY[Button_Buy+i][Y1], XY[Button_Buy+i][X2], XY[Button_Buy+i][Y2]))
         return(false);
      if(!buttons[i].Text(N[Button_Buy+i]))
         return(false);
      if(!buttons[i].FontSize(8))
         return(false);
      if(!buttons[i].ColorBorder(clrLightBlue))
         return(false);
      if(!buttons[i].ColorBackground(clrPaleTurquoise))
         return(false);
      if(!buttons[i].Font("Arial Black"))
         return(false);
      if(!Add(buttons[i]))
         return(false);
     }
   for(int i = 6; i < 7; i++)
     {
      if(!buttons[i].Create(m_chart_id, N[Button_Buy+i], m_subwin, XY[Button_Buy+i][X1], XY[Button_Buy+i][Y1], XY[Button_Buy+i][X2], XY[Button_Buy+i][Y2]))
         return(false);
      if(!buttons[i].Text(N[Button_Buy+i]))
         return(false);
      if(!buttons[i].FontSize(10))
         return(false);
      if(!buttons[i].ColorBorder(clrLightBlue))
         return(false);
      if(!buttons[i].ColorBackground(clrGray))
         return(false);
      if(!buttons[i].Font("Arial Black"))
         return(false);
      if(!buttons[i].Text("Close"))
         return(false);
      if(!Add(buttons[i]))
         return(false);
     }
   for(int i = 8; i < 9; i++)
     {
      if(!buttons[i].Create(m_chart_id, N[Button_Buy+i], m_subwin, XY[Button_Buy+i][X1], XY[Button_Buy+i][Y1], XY[Button_Buy+i][X2], XY[Button_Buy+i][Y2]))
         return(false);
      if(!buttons[i].Text(N[Button_Buy+i]))
         return(false);
      if(!buttons[i].FontSize(10))
         return(false);
      if(!buttons[i].ColorBorder(clrLightBlue))
         return(false);
      if(!buttons[i].ColorBackground(clrMediumSpringGreen))
         return(false);
      if(!buttons[i].Font("Arial Black"))
         return(false);
      if(!buttons[i].Text("Hedge"))
         return(false);
      if(!Add(buttons[i]))
         return(false);
     }
   for(int i = 17; i < 18; i++)
     {
      if(!buttons[i].Create(m_chart_id, N[Button_Buy+i], m_subwin, XY[Button_Buy+i][X1], XY[Button_Buy+i][Y1], XY[Button_Buy+i][X2], XY[Button_Buy+i][Y2]))
         return(false);
      if(!buttons[i].Text(N[Button_Buy+i]))
         return(false);
      if(!buttons[i].FontSize(10))
         return(false);
      if(!buttons[i].ColorBorder(clrLightBlue))
         return(false);
      if(!buttons[i].ColorBackground(clrLightCyan))
         return(false);
      if(!buttons[i].Font("Arial Black"))
         return(false);
      if(!Add(buttons[i]))
         return(false);
     }
   for(int i = 46; i < 47; i++)
     {
      if(!buttons[i].Create(m_chart_id, N[Button_Buy+i], m_subwin, XY[Button_Buy+i][X1], XY[Button_Buy+i][Y1], XY[Button_Buy+i][X2], XY[Button_Buy+i][Y2]))
         return(false);
      if(!buttons[i].Text(N[Button_Buy+i]))
         return(false);
      if(!buttons[i].FontSize(10))
         return(false);
      if(!buttons[i].ColorBorder(clrLightBlue))
         return(false);
      //if(!buttons[i].ColorBackground(clrLightCyan)) return(false);
      if(!buttons[i].Font("Arial Black"))
         return(false);
      if(!Add(buttons[i]))
         return(false);
     }
   return(true);


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit(void)
  {

   for(int i = 0; i < 12; i++)
     {

      if(!edits[i].Create(m_chart_id, N[Edit_LotBuy+i], m_subwin, XY[Edit_LotBuy+i][X1], XY[Edit_LotBuy+i][Y1], XY[Edit_LotBuy+i][X2], XY[Edit_LotBuy+i][Y2]))
         return(false);
      if(!Add(edits[i]))
         return(false);
      if(!edits[i].ColorBorder(clrLightSteelBlue))
         return(false);


     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEditX2(void)
  {
   /*
      for(int i = 12; i <16; i++)
      {

      if(!edits[i].Create(m_chart_id, N[Edit_LotBuy+i], m_subwin, XY[Edit_LotBuy+i][X1], XY[Edit_LotBuy+i][Y1], XY[Edit_LotBuy+i][X2], XY[Edit_LotBuy+i][Y2])) return(false);
      if(!Add(edits[i])) return(false);
      if(!edits[i].ColorBorder(clrLightSteelBlue)) return(false);


      }*/
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateComboBox(void)
  {

   for(int i = 0; i < 1; i++)
     {
      //ComboBox_PairGroup
      if(!combobox[i].Create(m_chart_id, N[ComboBox_PairGroup+i], m_subwin, XY[ComboBox_PairGroup+i][X1], XY[ComboBox_PairGroup+i][Y1], XY[ComboBox_PairGroup+i][X2], XY[ComboBox_PairGroup+i][Y2]))
         return(false);
      if(!Add(combobox[i]))
         return(false);


      combobox[0].ItemAdd("SELECT");
      combobox[0].ItemAdd("EUR GROUP");
      combobox[0].ItemAdd("USD GROUP");
      combobox[0].ItemAdd("GBP GROUP");
      combobox[0].Select(0);

     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateComboBoxX2(void)
  {

   for(int i = 1; i < 2; i++)
     {
      if(!combobox[i].Create(m_chart_id, N[ComboBox_PairGroup+i], m_subwin, XY[ComboBox_PairGroup+i][X1], XY[ComboBox_PairGroup+i][Y1], XY[ComboBox_PairGroup+i][X2], XY[ComboBox_PairGroup+i][Y2]))
         return(false);
      if(!Add(combobox[i]))
         return(false);
     }
   combobox[1].ItemAdd("List Mode All");

   combobox[1].Select(0);


//combobox[2].ItemAdd("Select Log Value");
//combobox[2].ItemAdd("Mobile SL Distance");
// combobox[2].ItemAdd("Mobile SL Step");
//combobox[2].ItemAdd("TP Bot +");
//combobox[2].ItemAdd("TP Bot -");
//combobox[2].Select(0);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateList(void)
  {

   if(!lists[0].Create(m_chart_id, N[List_Orderx1+0], m_subwin,7,71,104,381))
      return(false);
   if(!lists[1].Create(m_chart_id, N[List_Orderx1+1], m_subwin,104,71,167,381))
      return(false);
   if(!lists[2].Create(m_chart_id, N[List_Orderx1+2], m_subwin,167,71,219,381))
      return(false);
   if(!lists[3].Create(m_chart_id, N[List_Orderx1+3], m_subwin,219,71,289,381))
      return(false);
   if(!lists[4].Create(m_chart_id, N[List_Orderx1+4], m_subwin,289,71,359,381))
      return(false);
   if(!lists[5].Create(m_chart_id, N[List_Orderx1+5], m_subwin,359,71,429,381))
      return(false);
   if(!lists[6].Create(m_chart_id, N[List_Orderx1+6], m_subwin,429,71,486,381))
      return(false);
   if(!lists[7].Create(m_chart_id, N[List_Orderx1+7], m_subwin,486,71,566,381))
      return(false);

   for(int i = 0; i < 8; i++)
     {
      if(!Add(lists[i]))
         return(false);
      if(!lists[i].ColorBorder(clrNONE))
         return(false);
     }
   return(true);
  }




CControlsDialog ExtDialog;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_GoOrdersPanel(void)
  {

//ObjectsDeleteAll(0,"List Orders");
//CListView::Destroy(0);
   bool controlchangecheck=false;

   if(PanelScreenController==0 && controlchangecheck==false)
     {
      PanelScreenController=1;
      controlchangecheck=true;
     }
   if(PanelScreenController==1 && controlchangecheck==false)
     {
      PanelScreenController=0;
      controlchangecheck=true;
     }

   ENUM_TIMEFRAMES periodx=(ENUM_TIMEFRAMES)Period();

   if(periodx!=PERIOD_M1)
     {
      bool canchanche=ChartSetSymbolPeriod(0,Symbol(),PERIOD_M1);
      if(!canchanche)
        {
         canchanche;
        }
      Sleep(100);
      bool canchanchere=ChartSetSymbolPeriod(0,Symbol(),periodx);
      if(periodx!=Period())
        {
         canchanchere;
        }
     }
   if(periodx==PERIOD_M1)
     {
      bool canchanche=ChartSetSymbolPeriod(0,Symbol(),PERIOD_M5);
      if(!canchanche)
        {
         canchanche;
        }
      Sleep(100);
      bool canchanchere=ChartSetSymbolPeriod(0,Symbol(),periodx);
      if(periodx!=Period())
        {
         canchanchere;
        }
     }


  }
//OnClickButton_SelectPoss
void CControlsDialog::OnClickButton_SelectPoss(void)
  {
   if(PanelScreenController==1)
     {
      selectedpossticketx=lists[0].Select();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_CloseMode(void)
  {
   bool closemodeclick=false;
   if(CloseAreaMode==false && closemodeclick==false)
     {
      CloseAreaMode=true;
      closemodeclick=true;
      buttons[14].Text("ALL");
      buttons[14].FontSize(9);
      buttons[14].Font("Arial Black");

     }
   if(CloseAreaMode==true && closemodeclick==false)
     {
      CloseAreaMode=false;
      closemodeclick=true;
      buttons[14].Text(Symbol());
      buttons[14].FontSize(7);
      buttons[14].Font("Arial Black");

     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_Button_TPB(void)
  {
   if(earun=="ON")
     {
      if(tprun=="ON" && tprunclick==false)
        {
         tprun="OFF";
         buttons[15].ColorBackground(clrOrangeRed);
         edits[4].Text("   TP OFF   ");
         if(ObjectFind(0, "TP LEVEL") == 0)
            ObjectDelete(0, "TP LEVEL");
         tprunclick=true;
         tponoff=false;
        }

      if(tprun=="OFF"&& tprunclick==false)
        {
         ExtTakeProfit=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+(SymbolInfoDouble(Symbol(),SYMBOL_POINT)*100);
         tponoff=true;
         SetLineTP(ExtTakeProfit);
         tprun="ON";
         buttons[15].ColorBackground(clrMediumSpringGreen);
         edits[4].Text(ExtTakeProfit);
         tprunclick=true;
        }
      tprunclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_Button_SLB(void)
  {
   if(earun=="ON")
     {
      if(slrun=="ON" && slrunclick==false)
        {
         slrun="OFF";
         buttons[16].ColorBackground(clrOrangeRed);
         edits[5].Text("   SL OFF   ");
         if(ObjectFind(0, "SL LEVEL") == 0)
            ObjectDelete(0, "SL LEVEL");
         slrunclick=true;
         stoponoff=false;
         if(traillingonoff==true)
           {
            OnClickButton_MobileSL();
           }
        }

      if(slrun=="OFF"&& slrunclick==false)
        {
         ExtStopLoss=SymbolInfoDouble(Symbol(),SYMBOL_BID)-(SymbolInfoDouble(Symbol(),SYMBOL_POINT)*100);
         stoponoff=true;
         SetLineSL(ExtStopLoss);
         slrun="ON";
         buttons[16].ColorBackground(clrMediumSpringGreen);
         edits[5].Text(ExtStopLoss);
         slrunclick=true;
        }
      slrunclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_GroupOpenOnOff(void)
  {
   if(earun=="ON")
     {
      if(groupopenrun=="ON" && cgroupopenclick==false)
        {
         groupopenrun="OFF";
         buttons[42].ColorBackground(clrOrangeRed);
         buttons[42].Text("OFF");
         cgroupopenclick=true;
         GroupOpenonoff=false;


        }

      if(groupopenrun=="OFF"&& cgroupopenclick==false)
        {

         groupopenrun="ON";
         buttons[42].ColorBackground(clrMediumSpringGreen);
         buttons[42].Text("ON");
         cgroupopenclick=true;
         GroupOpenonoff=true;
        }
      cgroupopenclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }



  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_Coveragex(void)
  {
   if(earun=="ON")
     {
      if(coveragerun=="ON" && coveragerunclick==false)
        {
         coveragerun="OFF";
         buttons[23].ColorBackground(clrOrangeRed);
         buttons[23].Text("OFF");
         coveragerunclick=true;
         Coverageonoff=false;
        }

      if(coveragerun=="OFF"&& coveragerunclick==false)
        {

         coveragerun="ON";
         buttons[23].ColorBackground(clrMediumSpringGreen);
         buttons[23].Text("ON");
         coveragerunclick=true;
         Coverageonoff=true;
        }
      coveragerunclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_AutoBotTPRun(void)
  {
   if(earun=="ON")
     {
      if(autobotrun=="ON" && autobotrunclick==false)
        {
         autobotrun="OFF";
         buttons[41].ColorBackground(clrOrangeRed);
         buttons[41].Text("OFF");
         autobotrunclick=true;
         AutoTPBot=false;
        }

      if(autobotrun=="OFF"&& autobotrunclick==false)
        {

         autobotrun="ON";
         buttons[41].ColorBackground(clrMediumSpringGreen);
         buttons[41].Text("ON");
         autobotrunclick=true;
         AutoTPBot=true;
        }
      autobotrunclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_TPUp(void)
  {
   if(earun=="ON")
     {
      if(tprun=="ON")
        {
         double midlvobj;
         midlvobj=(((ObjectGetDouble(0, "TP LEVEL", OBJPROP_PRICE,0))+(ObjectGetDouble(0, "TP LEVEL", OBJPROP_PRICE,1)))/2);
         midlvobj=midlvobj+(SymbolInfoDouble(Symbol(),SYMBOL_POINT)*1);
         SetLineTP(midlvobj);
         ExtTakeProfit=midlvobj;
         edits[4].Text(DoubleToString(ExtTakeProfit,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
        }
      if(tprun=="OFF")
        {
         Alert("Take Profit function is STOPPED(OFF), please turn it ON using the Red Buttons.");
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_TPDown(void)
  {
   if(earun=="ON")
     {
      if(tprun=="ON")
        {
         double midlvobj;
         midlvobj=(((ObjectGetDouble(0, "TP LEVEL", OBJPROP_PRICE,0))+(ObjectGetDouble(0, "TP LEVEL", OBJPROP_PRICE,1)))/2);
         midlvobj=midlvobj-(SymbolInfoDouble(Symbol(),SYMBOL_POINT)*1);
         SetLineTP(midlvobj);
         ExtTakeProfit=midlvobj;
         edits[4].Text(DoubleToString(ExtTakeProfit,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
        }
      if(tprun=="OFF")
        {
         Alert("Take Profit function is STOPPED(OFF), please turn it ON using the Red Buttons.");
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_SLUp(void)
  {
   if(earun=="ON")
     {
      if(slrun=="ON")
        {
         double midlvobj;
         midlvobj=(((ObjectGetDouble(0, "SL LEVEL", OBJPROP_PRICE,0))+(ObjectGetDouble(0, "SL LEVEL", OBJPROP_PRICE,1)))/2);
         midlvobj=midlvobj+(SymbolInfoDouble(Symbol(),SYMBOL_POINT)*1);
         SetLineSL(midlvobj);
         ExtStopLoss=midlvobj;
         edits[5].Text(DoubleToString(ExtStopLoss,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
        }
      if(slrun=="OFF")
        {
         Alert("Stop Loss function is STOPPED(OFF), please turn it ON using the Red Buttons.");
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_SLDown(void)
  {
   if(earun=="ON")
     {
      if(slrun=="ON")
        {
         double midlvobj;
         midlvobj=(((ObjectGetDouble(0, "SL LEVEL", OBJPROP_PRICE,0))+(ObjectGetDouble(0, "SL LEVEL", OBJPROP_PRICE,1)))/2);
         midlvobj=midlvobj-(SymbolInfoDouble(Symbol(),SYMBOL_POINT)*1);
         SetLineSL(midlvobj);
         ExtStopLoss=midlvobj;
         edits[5].Text(DoubleToString(ExtStopLoss,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
        }
      if(slrun=="OFF")
        {
         Alert("Stop Loss function is STOPPED(OFF), please turn it ON using the Red Buttons.");
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
  }













//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_LotUpBuy(void)
  {
   lotbuy=lotbuy+0.01;
   edits[0].Text(DoubleToString(lotbuy, 2));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_LotDownBuy(void)
  {
   lotbuy=lotbuy-0.01;
   edits[0].Text(DoubleToString(lotbuy, 2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_LotUppSell(void)
  {
   lotsell=lotsell+0.01;
   edits[1].Text(DoubleToString(lotsell, 2));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_LotDownnSell(void)
  {
   lotsell=lotsell-0.01;
   edits[1].Text(DoubleToString(lotsell, 2));
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpCoverage(void)
  {
   if(coveragelevel+1<0)
     {
      coveragelevel=coveragelevel-1;
      edits[9].Text(coveragelevel);
      edits[9].Color(clrRed);
     }
   if(coveragelevel+1==0)
     {
      coveragelevel=coveragelevel-1;
      edits[9].Text(coveragelevel);
      edits[9].Color(clrRed);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownCoverage(void)
  {
   if(coveragelevel+1<0)
     {
      coveragelevel=coveragelevel+1;
      edits[9].Text(coveragelevel);
      edits[9].Color(clrRed);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpCoveragePlus(void)
  {
   if(coveragelevelplus-1>0)
     {
      coveragelevelplus=coveragelevelplus+1;
      edits[8].Text(coveragelevelplus);
      edits[8].Color(clrLimeGreen);
     }
   if(coveragelevelplus-1==0)
     {
      coveragelevelplus=coveragelevelplus+1;
      edits[8].Text(coveragelevelplus);
      edits[8].Color(clrLimeGreen);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownCoveragePlus(void)
  {
   if(coveragelevelplus-1>0)
     {
      coveragelevelplus=coveragelevelplus-1;
      edits[8].Text(coveragelevelplus);
      edits[8].Color(clrLimeGreen);
     }
  }





//-------------------------------



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpAutoBotTPStop(void)
  {
   if(AutoTPBotStopLevel+1<0)
     {
      AutoTPBotStopLevel=AutoTPBotStopLevel-1;
      edits[11].Text(AutoTPBotStopLevel);
      edits[11].Color(clrRed);
     }
   if(AutoTPBotStopLevel+1==0)
     {
      AutoTPBotStopLevel=AutoTPBotStopLevel-1;
      edits[11].Text(AutoTPBotStopLevel);
      edits[11].Color(clrRed);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownAutoBotTPStop(void)
  {

   if(AutoTPBotStopLevel+1<0)
     {
      AutoTPBotStopLevel=AutoTPBotStopLevel+1;
      edits[11].Text(AutoTPBotStopLevel);
      edits[11].Color(clrRed);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpAutoBotTPStep(void)
  {

   if(AutoTPBotStepLevel-1>0)
     {
      AutoTPBotStepLevel=AutoTPBotStepLevel+1;
      edits[10].Text(AutoTPBotStepLevel);
      edits[10].Color(clrLimeGreen);
     }
   if(AutoTPBotStepLevel-1==0)
     {
      AutoTPBotStepLevel=AutoTPBotStepLevel+1;
      edits[10].Text(AutoTPBotStepLevel);
      edits[10].Color(clrLimeGreen);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownAutoBotTPStep(void)
  {

   if(AutoTPBotStepLevel-1>0)
     {
      AutoTPBotStepLevel=AutoTPBotStepLevel-1;
      edits[10].Text(AutoTPBotStepLevel);
      edits[10].Color(clrLimeGreen);
     }
  }




//----------------------------------



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpTicketStart(void)
  {
   int total=PositionsTotal();
   for(int kxl=0; kxl<total; kxl++)
     {
      ulong  position_ticket=PositionGetTicket(kxl);
      if(edits[2].Text()=="" || edits[2].Text()==NULL || edits[2].Text()=="        ---        " || edits[2].Text()=="NO POSITION")
        {
         if(PositionsTotal()!=0 && kxl==0)
           {
            edits[2].Text(position_ticket);
           }
        }
     }

   int editvaluex;
   editvaluex=edits[2].Text();

   if(PositionsTotal()==0)
     {
      edits[2].Text("NO POSITION");
     }
   if(edits[2].Text()!="NO POSITION" && PositionsTotal()!=0)
     {
      edits[2].Text(editvaluex+1);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownTicketStart(void)
  {
   int total=PositionsTotal();
   for(int kxl=0; kxl<total; kxl++)
     {
      ulong  position_ticket=PositionGetTicket(kxl);
      if(edits[2].Text()=="" || edits[2].Text()==NULL || edits[2].Text()=="        ---        " || edits[2].Text()=="NO POSITION")
        {
         if(PositionsTotal()!=0 && kxl==0)
           {
            edits[2].Text(position_ticket);
           }
        }
     }

   int editvaluex;
   editvaluex=edits[2].Text();

   if(PositionsTotal()==0)
     {
      edits[2].Text("NO POSITION");
     }
   if(edits[2].Text()!="NO POSITION" && PositionsTotal()!=0)
     {
      edits[2].Text(editvaluex-1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpTicketStop(void)
  {
   int total=PositionsTotal();
   for(int kxl=0; kxl<total; kxl++)
     {
      ulong  position_ticket=PositionGetTicket(kxl);
      if(edits[3].Text()=="" || edits[3].Text()==NULL || edits[3].Text()=="        ---        " || edits[3].Text()=="NO POSITION")
        {
         if(PositionsTotal()!=0 && kxl==total-1)
           {
            edits[3].Text(position_ticket);
           }
        }
     }

   int editvaluex;
   editvaluex=edits[3].Text();

   if(PositionsTotal()==0)
     {
      edits[3].Text("NO POSITION");
     }
   if(edits[3].Text()!="NO POSITION" && PositionsTotal()!=0)
     {
      edits[3].Text(editvaluex+1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownTicketStop(void)
  {
   int total=PositionsTotal();
   for(int kxl=0; kxl<total; kxl++)
     {
      ulong  position_ticket=PositionGetTicket(kxl);
      if(edits[3].Text()=="" || edits[3].Text()==NULL || edits[3].Text()=="        ---        " || edits[3].Text()=="NO POSITION")
        {
         if(PositionsTotal()!=0 && kxl==total-1)
           {
            edits[3].Text(position_ticket);
           }
        }
     }

   int editvaluex;
   editvaluex=edits[3].Text();

   if(PositionsTotal()==0)
     {
      edits[3].Text("NO POSITION");
     }
   if(edits[3].Text()!="NO POSITION" && PositionsTotal()!=0)
     {
      edits[3].Text(editvaluex-1);
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpTSLSTEP(void)
  {

   if(traillingonoff==true)
     {
      traillingStep=traillingStep+1.0;
      edits[7].Text(DoubleToString(traillingStep, 1));
      traillingStepx2=traillingStep/10;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownTSLSTEP(void)
  {
   if(traillingonoff==true)
     {
      traillingStep=traillingStep-1.0;
      edits[7].Text(DoubleToString(traillingStep, 1));
      traillingStepx2=traillingStep/10;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_UpTSLDISTANCE(void)
  {
   if(traillingonoff==true)
     {
      traillingDistance=traillingDistance+2.0;
      traillingDistancex2=traillingDistance/10;
      edits[6].Text(DoubleToString(traillingDistance, 1));
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_DownTSLDISTANCE(void)
  {
   if(traillingonoff==true)
     {
      traillingDistance=traillingDistance-2.0;
      traillingDistancex2=traillingDistance/10;
      edits[6].Text(DoubleToString(traillingDistance, 1));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_Buy(void)
  {
   if(earun=="ON")
     {
      if(stoponoff==true)
        {
         ExtStopLoss=edits[5].Text();
        }
      if(tponoff==true)
        {
         ExtTakeProfit=edits[4].Text();
        }
      if(stoponoff==false)
        {
         ExtStopLoss=0.0;
        }
      if(tponoff==false)
        {
         ExtTakeProfit=0.0;
        }
      if(groupopenrun=="ON")
        {
         comboboxstring();
        }
      Buy(lotbuy,ExtStopLoss,ExtTakeProfit,0,0,Symbol());
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_Sell(void)
  {
   if(earun=="ON")
     {
      if(stoponoff==true)
        {
         ExtStopLoss=edits[5].Text();
        }
      if(tponoff==true)
        {
         ExtTakeProfit=edits[4].Text();
        }
      if(stoponoff==false)
        {
         ExtStopLoss=0.0;
        }
      if(tponoff==false)
        {
         ExtTakeProfit=0.0;
        }
      if(groupopenrun=="ON")
        {
         comboboxstring();
        }
      Sell(lotsell,ExtStopLoss,ExtTakeProfit,0,0,Symbol());
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_CloseAll(void)
  {
   if(earun=="ON" && PanelScreenController==0)
     {
      if(CloseAreaMode==true)
        {
         CloseAllPositions(0,0,"noticket",1);
        }
      if(CloseAreaMode==false)
        {
         CloseAllPositions(1,0,"noticket",1);
        }
     }
   if(earun=="ON" && PanelScreenController==1)
     {
      if(CloseAreaMode==true)
        {
         CloseAllPositions(0,0,"ticket",selectedpossticketx);
        }
      if(CloseAreaMode==false)
        {
         CloseAllPositions(1,0,"ticket",selectedpossticketx);
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseAllPositions(int moduus=0,int typexx=0,string ticketmode="noticket",int ticketnumm=0)
  {
   //Print(ticketmode+" : "+ticketnumm);
   int contClosePositionFail=0;
   int positionsTotal=PositionsTotal();
   for(int i=positionsTotal-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(ticketmode=="noticket")
        {
         if(typexx==0)
           {
            if(moduus==1 && position_symbol==Symbol())
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
            if(moduus==0)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
           }

         if(typexx==1 && type==POSITION_TYPE_BUY)
           {
            if(moduus==1 && position_symbol==Symbol())
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
            if(moduus==0)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
           }

         if(typexx==2 && type==POSITION_TYPE_SELL)
           {
            if(moduus==1 && position_symbol==Symbol())
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
            if(moduus==0)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
           }

        }


      if(ticketmode=="ticket")
        {
         if(typexx==0 && ticket==ticketnumm)
           {
            if(moduus==1 && position_symbol==Symbol() && ticket==ticketnumm)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
            if(moduus==0 && ticket==ticketnumm)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
           }

         if(typexx==1 && type==POSITION_TYPE_BUY && ticket==ticketnumm)
           {
            if(moduus==1 && position_symbol==Symbol() && ticket==ticketnumm)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
            if(moduus==0 && ticket==ticketnumm)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
           }

         if(typexx==2 && type==POSITION_TYPE_SELL && ticket==ticketnumm)
           {
            if(moduus==1 && position_symbol==Symbol() && ticket==ticketnumm)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
            if(moduus==0 && ticket==ticketnumm)
              {
               bool restulClosePositon=ClosePosition(ticket);
               if(!restulClosePositon)
                  contClosePositionFail++;
              }
           }

        }

     }
   return(contClosePositionFail>0 ?true : false);
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_Reverse()
  {
//10001
//int startmagicka;
if(PanelScreenController==0)
{
   if(earun=="ON")
     {
      int total=PositionsTotal();
      string OpenedCurrentSymbols[][3];
      ArrayResize(OpenedCurrentSymbols,total*2);

      for(int kxl=0; kxl<total; kxl++)
        {
         ulong  position_ticket=PositionGetTicket(kxl);
         string position_symbol=PositionGetString(POSITION_SYMBOL);
         double volume=PositionGetDouble(POSITION_VOLUME);
         ulong  magic=PositionGetInteger(POSITION_MAGIC);
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         bool IsVritenPos=false;

         for(int xc=0; xc<(total*2); xc++)
           {
            if(OpenedCurrentSymbols[xc,0]==position_symbol)
              {
               if(type==POSITION_TYPE_SELL)
                 {
                  OpenedCurrentSymbols[xc,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,1]))+volume),2);
                 }
               if(type==POSITION_TYPE_BUY)
                 {
                  OpenedCurrentSymbols[xc,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,2]))+volume),2);
                 }

               IsVritenPos=true;
              }
           }
         if(IsVritenPos==false)
           {
            for(int xcv=0; xcv<(total*2); xcv++)
              {
               if(OpenedCurrentSymbols[xcv,0]==NULL)
                 {
                  OpenedCurrentSymbols[xcv,0]=position_symbol;

                  if(type==POSITION_TYPE_SELL)
                    {
                     OpenedCurrentSymbols[xcv,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,1]))+volume),2);
                    }
                  if(type==POSITION_TYPE_BUY)
                    {
                     OpenedCurrentSymbols[xcv,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,2]))+volume),2);
                    }

                  break;
                 }
              }
           }
        }
      if(CloseAreaMode==true)
        {
         CloseAllPositions(0,0,"noticket",1);
        }
      if(CloseAreaMode==false)
        {
         CloseAllPositions(1,0,"noticket",1);
        }

      for(int xcv=0; xcv<(total*2); xcv++)
        {
         if(CloseAreaMode==true)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="")
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1!=0.0)
                 {
                  Buy(V1,0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V2!=0.0)
                 {
                  Sell(V2,0,0,0,0,OpenedCurrentSymbols[xcv,0]);
                 }
              }
           }
         if(CloseAreaMode==false)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="" && OpenedCurrentSymbols[xcv,0]==Symbol())
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1!=0.0)
                 {
                  Buy(V1,0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V2!=0.0)
                 {
                  Sell(V2,0,0,0,0,OpenedCurrentSymbols[xcv,0]);
                 }

              }
           }
        }
     }
}
if(PanelScreenController==1)
{
   if(earun=="ON")
     {
      int total=PositionsTotal();
      string OpenedCurrentSymbols[][3];
      ArrayResize(OpenedCurrentSymbols,total*2);

      for(int kxl=0; kxl<total; kxl++)
        {
         ulong  position_ticket=PositionGetTicket(kxl);
         string position_symbol=PositionGetString(POSITION_SYMBOL);
         double volume=PositionGetDouble(POSITION_VOLUME);
         ulong  magic=PositionGetInteger(POSITION_MAGIC);
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         bool IsVritenPos=false;

         for(int xc=0; xc<(total*2); xc++)
           {
            if(OpenedCurrentSymbols[xc,0]==position_symbol && position_ticket==selectedpossticketx)
              {
               if(type==POSITION_TYPE_SELL)
                 {
                  OpenedCurrentSymbols[xc,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,1]))+volume),2);
                 }
               if(type==POSITION_TYPE_BUY)
                 {
                  OpenedCurrentSymbols[xc,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,2]))+volume),2);
                 }

               IsVritenPos=true;
              }
           }
         if(IsVritenPos==false)
           {
            for(int xcv=0; xcv<(total*2); xcv++)
              {
               if(OpenedCurrentSymbols[xcv,0]==NULL && position_ticket==selectedpossticketx)
                 {
                  OpenedCurrentSymbols[xcv,0]=position_symbol;

                  if(type==POSITION_TYPE_SELL)
                    {
                     OpenedCurrentSymbols[xcv,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,1]))+volume),2);
                    }
                  if(type==POSITION_TYPE_BUY)
                    {
                     OpenedCurrentSymbols[xcv,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,2]))+volume),2);
                    }

                  break;
                 }
              }
           }
        }
      if(CloseAreaMode==true)
        {
         CloseAllPositions(0,0,"ticket",selectedpossticketx);
        }
      if(CloseAreaMode==false)
        {
         CloseAllPositions(1,0,"ticket",selectedpossticketx);
        }

      for(int xcv=0; xcv<(total*2); xcv++)
        {
         if(CloseAreaMode==true)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="")
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1!=0.0)
                 {
                  Buy(V1,0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V2!=0.0)
                 {
                  Sell(V2,0,0,0,0,OpenedCurrentSymbols[xcv,0]);
                 }
              }
           }
         if(CloseAreaMode==false)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="" && OpenedCurrentSymbols[xcv,0]==Symbol())
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1!=0.0)
                 {
                  Buy(V1,0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V2!=0.0)
                 {
                  Sell(V2,0,0,0,0,OpenedCurrentSymbols[xcv,0]);
                 }

              }
           }
        }
     }
}   
     
     
     
     
     
     
     
     
     
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_ControlHedgeAll(void)
  {
  if(PanelScreenController==0)
  {
   if(earun=="ON")
     {
      int total=PositionsTotal();
      string OpenedCurrentSymbols[][3];
      ArrayResize(OpenedCurrentSymbols,total*2);

      for(int kxl=0; kxl<total; kxl++)
        {
         ulong  position_ticket=PositionGetTicket(kxl);
         string position_symbol=PositionGetString(POSITION_SYMBOL);
         double volume=PositionGetDouble(POSITION_VOLUME);
         ulong  magic=PositionGetInteger(POSITION_MAGIC);
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         bool IsVritenPos=false;

         for(int xc=0; xc<(total*2); xc++)
           {
            if(OpenedCurrentSymbols[xc,0]==position_symbol)
              {
               if(type==POSITION_TYPE_SELL)
                 {
                  OpenedCurrentSymbols[xc,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,1]))+volume),2);
                 }
               if(type==POSITION_TYPE_BUY)
                 {
                  OpenedCurrentSymbols[xc,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,2]))+volume),2);
                 }

               IsVritenPos=true;
              }
           }
         if(IsVritenPos==false)
           {
            for(int xcv=0; xcv<(total*2); xcv++)
              {
               if(OpenedCurrentSymbols[xcv,0]==NULL)
                 {
                  OpenedCurrentSymbols[xcv,0]=position_symbol;

                  if(type==POSITION_TYPE_SELL)
                    {
                     OpenedCurrentSymbols[xcv,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,1]))+volume),2);
                    }
                  if(type==POSITION_TYPE_BUY)
                    {
                     OpenedCurrentSymbols[xcv,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,2]))+volume),2);
                    }

                  break;
                 }
              }
           }
        }

      for(int xcv=0; xcv<(total*2); xcv++)
        {
         if(CloseAreaMode==true)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="")
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1>V2)
                 {
                  Buy((V1-V2),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V1<V2)
                 {
                  Sell((V2-V1),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
              }
           }
         if(CloseAreaMode==false)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="" && OpenedCurrentSymbols[xcv,0]==Symbol())
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1>V2)
                 {
                  Buy((V1-V2),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V1<V2)
                 {
                  Sell((V2-V1),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
              }
           }
        }

     }
    } 
    
  if(PanelScreenController==1)
  {
   if(earun=="ON")
     {
      int total=PositionsTotal();
      string OpenedCurrentSymbols[][3];
      ArrayResize(OpenedCurrentSymbols,total*2);

      for(int kxl=0; kxl<total; kxl++)
        {
         ulong  position_ticket=PositionGetTicket(kxl);
         string position_symbol=PositionGetString(POSITION_SYMBOL);
         double volume=PositionGetDouble(POSITION_VOLUME);
         ulong  magic=PositionGetInteger(POSITION_MAGIC);
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         bool IsVritenPos=false;

         for(int xc=0; xc<(total*2); xc++)
           {
            if(OpenedCurrentSymbols[xc,0]==position_symbol && position_ticket==selectedpossticketx)
              {
               if(type==POSITION_TYPE_SELL)
                 {
                  OpenedCurrentSymbols[xc,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,1]))+volume),2);
                 }
               if(type==POSITION_TYPE_BUY)
                 {
                  OpenedCurrentSymbols[xc,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,2]))+volume),2);
                 }

               IsVritenPos=true;
              }
           }
         if(IsVritenPos==false)
           {
            for(int xcv=0; xcv<(total*2); xcv++)
              {
               if(OpenedCurrentSymbols[xcv,0]==NULL && position_ticket==selectedpossticketx)
                 {
                  OpenedCurrentSymbols[xcv,0]=position_symbol;

                  if(type==POSITION_TYPE_SELL)
                    {
                     OpenedCurrentSymbols[xcv,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,1]))+volume),2);
                    }
                  if(type==POSITION_TYPE_BUY)
                    {
                     OpenedCurrentSymbols[xcv,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,2]))+volume),2);
                    }

                  break;
                 }
              }
           }
        }

      for(int xcv=0; xcv<(total*2); xcv++)
        {
         if(CloseAreaMode==true)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="")
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1>V2)
                 {
                  Buy((V1-V2),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V1<V2)
                 {
                  Sell((V2-V1),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
              }
           }
         if(CloseAreaMode==false)
           {
            if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="" && OpenedCurrentSymbols[xcv,0]==Symbol())
              {
               double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2);
               double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2);
               if(V1>V2)
                 {
                  Buy((V1-V2),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
               if(V1<V2)
                 {
                  Sell((V2-V1),0.0,0.0,0.0,0.0,OpenedCurrentSymbols[xcv,0]);
                 }
              }
           }
        }

     }
    }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }
     selectedpossticketx=NULL;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_OnOff(void)
  {
   if(earun=="ON" && earunclick==false|| earun==NULL&& earunclick==false)
     {
      earun="OFF";
      buttons[7].ColorBackground(clrOrangeRed);
      buttons[7].Text("OFF");
      //Alert(earun);
      earunclick=true;
      labels[7].Text("| PANEL STOPPED");


      ClearLines();
      slrun="OFF";
      buttons[16].ColorBackground(clrOrangeRed);
      edits[5].Text("   SL OFF   ");
      slrunclick=true;
      stoponoff=false;
      tprun="OFF";
      buttons[15].ColorBackground(clrOrangeRed);
      edits[4].Text("   TP OFF   ");
      tprunclick=true;
      tponoff=false;
     }

   if(earun=="OFF"&& earunclick==false|| earun==NULL&& earunclick==false)
     {
      buttons[7].ColorBackground(clrSpringGreen);
      buttons[7].Text("ON");
      earun="ON";
      //Alert(earun);
      earunclick=true;
      labels[7].Text("| PANEL STARTED");
      SetLinePendings(SymbolInfoDouble(Symbol(),SYMBOL_BID));
     }
   earunclick=false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_MobileSL(void)
  {
   if(earun=="ON")
     {
      if(mobileslrun=="ON" && mobileslclick==false)
        {
         mobileslrun="OFF";
         buttons[18].ColorBackground(clrOrangeRed);
         mobileslclick=true;
         traillingonoff=false;
         if(mobilesllogrun=="OFF")
           {
            OnClickButton_LogTSL();
           }
        }

      if(mobileslrun=="OFF"&& mobileslclick==false)
        {
         if(edits[7].Text()=="" || edits[7].Text()==NULL)
           {
            traillingStep=10.0;
            traillingStepx2=traillingStep/10;
            edits[7].Text(DoubleToString(traillingStep,1));
           }
         if(edits[6].Text()=="" || edits[6].Text()==NULL)
           {
            traillingDistance=40.0;
            traillingDistancex2=traillingDistance/10;
            edits[6].Text(DoubleToString(traillingDistance,1));
           }
         if(edits[7].Text()!="" && edits[7].Text()!=NULL)
           {
            traillingStep=edits[7].Text();
           }
         if(edits[6].Text()!="" && edits[6].Text()!=NULL)
           {
            traillingDistance=edits[6].Text();
           }


         traillingonoff=true;
         mobileslrun="ON";
         buttons[18].ColorBackground(clrMediumSpringGreen);
         mobileslclick=true;

         if(slrun=="OFF")
           {
            CControlsDialog::OnClickButton_Button_SLB();
           }
         if(mobilesllogrun=="OFF")
           {
            OnClickButton_LogTSL();
           }
        }
      mobileslclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }








//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_LogAutoBotTP(void)
  {
   if(earun=="ON")
     {
      if(autotpbotlogrun=="ON" && autotpbotlogclick==false)
        {
         autotpbotlogrun="OFF";
         buttons[43].ColorBackground(clrOrangeRed);
         autotpbotlogclick=true;
         AutoTPBotlog=false;
        }

      if(autotpbotlogrun=="OFF"&& autotpbotlogclick==false)
        {
         AutoTPBotlog=true;
         autotpbotlogrun="ON";
         buttons[43].ColorBackground(clrMediumSpringGreen);
         autotpbotlogclick=true;
        }
      autotpbotlogclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//-----------------------------------




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_LogTSL(void)
  {
   if(earun=="ON")
     {
      if(mobilesllogrun=="ON" && mobilesllogclick==false)
        {
         mobilesllogrun="OFF";
         buttons[30].ColorBackground(clrOrangeRed);
         mobilesllogclick=true;
         traillinglog=false;
        }

      if(mobilesllogrun=="OFF"&& mobilesllogclick==false)
        {
         traillinglog=true;
         mobilesllogrun="ON";
         buttons[30].ColorBackground(clrMediumSpringGreen);
         mobilesllogclick=true;
        }
      mobilesllogclick=false;
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//-----------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_AllowBuy(void)
  {
   if(earun=="ON")
     {
      if(stoponoff==true)
        {
         ExtStopLoss=edits[5].Text();
        }
      if(tponoff==true)
        {
         ExtTakeProfit=edits[4].Text();
        }
      if(stoponoff==false)
        {
         ExtStopLoss=0.0;
        }
      if(tponoff==false)
        {
         ExtTakeProfit=0.0;
        }

      if(SymbolInfoDouble(Symbol(),SYMBOL_BID)>PendingsLevel)
        {
         Buy(lotbuy,ExtStopLoss,ExtTakeProfit,1,PendingsLevel,Symbol());
        }
      if(SymbolInfoDouble(Symbol(),SYMBOL_BID)<PendingsLevel)
        {
         Buy(lotbuy,ExtStopLoss,ExtTakeProfit,2,PendingsLevel,Symbol());
        }
      if(SymbolInfoDouble(Symbol(),SYMBOL_BID)==PendingsLevel)
        {
         Alert("Please Check Pending Order Aqua Line Level");
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_AllowSell(void)
  {
   if(earun=="ON")
     {
      if(stoponoff==true)
        {
         ExtStopLoss=edits[5].Text();
        }
      if(tponoff==true)
        {
         ExtTakeProfit=edits[4].Text();
        }
      if(stoponoff==false)
        {
         ExtStopLoss=0.0;
        }
      if(tponoff==false)
        {
         ExtTakeProfit=0.0;
        }

      if(SymbolInfoDouble(Symbol(),SYMBOL_BID)>PendingsLevel)
        {
         Sell(lotsell,ExtStopLoss,ExtTakeProfit,2,PendingsLevel,Symbol());
        }
      if(SymbolInfoDouble(Symbol(),SYMBOL_BID)<PendingsLevel)
        {
         Sell(lotsell,ExtStopLoss,ExtTakeProfit,1,PendingsLevel,Symbol());
        }
      if(SymbolInfoDouble(Symbol(),SYMBOL_BID)==PendingsLevel)
        {
         Alert("Please Check Pending Order Aqua Line Level");
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//---------------------
void CControlsDialog::OnClickButton_InstantCloseBuy(void)
  {
   if(earun=="ON")
     {

      if(CloseAreaMode==true)
        {
         CloseAllPositions(0,1,"noticket",1);
        }
      if(CloseAreaMode==false)
        {
         CloseAllPositions(1,1,"noticket",1);
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_InstantCloseSells(void)
  {
   if(earun=="ON")
     {

      if(CloseAreaMode==true)
        {
         CloseAllPositions(0,2,"noticket",1);
        }
      if(CloseAreaMode==false)
        {
         CloseAllPositions(1,2,"noticket",1);
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton_CloseByTicket(void)
  {

   if(earun=="ON")
     {

      int total;
      total=PositionsTotal();
      for(int kxl=0; kxl<total; kxl++)
        {
         ulong  position_ticket=PositionGetTicket(kxl);
         string position_symbol=PositionGetString(POSITION_SYMBOL);
         double volume=PositionGetDouble(POSITION_VOLUME);
         ulong  magic=PositionGetInteger(POSITION_MAGIC);
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         if(edits[2].Text()!="NO POSITION" && edits[2].Text()!="" && edits[2].Text()!=NULL && edits[2].Text()!="        ---        "   &&   edits[3].Text()!="" && edits[3].Text()!=NULL && edits[3].Text()!="        ---        " && edits[2].Text()!="NO POSITION")
           {
            for(int xxcc=int(edits[2].Text()); xxcc<=int(edits[3].Text()); xxcc++)
              {
               ClosePosition(xxcc);
              }
           }
         if(edits[2].Text()!="" && edits[2].Text()!=NULL && edits[2].Text()!="        ---        " && edits[2].Text()!="NO POSITION")
           {
            if(edits[3].Text()=="" || edits[3].Text()==NULL || edits[3].Text()=="        ---        " || edits[3].Text()=="NO POSITION")
              {
               ClosePosition(edits[2].Text());
              }
           }
        }
     }
   if(earun=="OFF")
     {
      Alert("Panel Stoped(OFF), Please Turn ON by Button In The Upper Right Corner");
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::AutoTPBotRunner(void)
  {


   if(AutoTPBot==true)
     {
      int total;
      total=PositionsTotal();

      ulong  position_ticket=PositionGetTicket(total);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      string position_profit=PositionGetDouble(POSITION_PROFIT);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(AutoTPBotStopLevel>-100000 && AutoTPBotStopLevel<-0.01)
        {
         if(position_profit<AutoTPBotStopLevel)
           {
            ClosePosition(position_ticket);
           }
        }
      AutoTPBot=false;
      AutoTPBot=false;
     }

   if(AutoTPBot==true)
     {

      int total;
      total=PositionsTotal();

      ulong  position_ticket=PositionGetTicket(total);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      string position_profit=PositionGetDouble(POSITION_PROFIT);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(AutoTPBotStepLevel<100000 && AutoTPBotStepLevel>0.01)
        {
         if(position_profit>AutoTPBotStepLevel)
           {
            ClosePosition(position_ticket);

            if(type==POSITION_TYPE_BUY)
              {
               Buy(volume,0,0,0,0,position_symbol);
              }
            if(type==POSITION_TYPE_SELL)
              {
               Sell(volume,0,0,1,0,position_symbol);
              }
           }
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::runx()
  {
   edits[4].Text("   TP OFF   ");
   edits[5].Text("   SL OFF   ");
   edits[1].Text(DoubleToString(lotsell, 2));
   edits[0].Text(DoubleToString(lotbuy, 2));
   edits[0].Color(clrBlue);
   edits[1].Color(clrRed);

   SetLinePendings(SymbolInfoDouble(Symbol(),SYMBOL_BID));

   edits[8].Text(coveragelevelplus);
   edits[8].Color(clrLimeGreen);
   edits[9].Text(coveragelevel);
   edits[9].Color(clrRed);

   edits[10].Text(AutoTPBotStepLevel);
   edits[10].Color(clrLimeGreen);
   edits[11].Text(AutoTPBotStopLevel);
   edits[11].Color(clrRed);

   earun="OFF";
   slrun="OFF";
   tprun="OFF";

   if(firstruncontrool!=NULL)
     {
      OnClickButton_OnOff();
      firstruncontrool=Symbol();
     }
   if(firstruncontrool==NULL)
     {
      firstruncontrool=Symbol();

      long accountnumberx;
      string serverx;
      string ownerx;

      accountnumberx=AccountInfoInteger(ACCOUNT_LOGIN);
      serverx=AccountInfoString(ACCOUNT_SERVER);
      ownerx=AccountInfoString(ACCOUNT_NAME);

      //Alert("Welcome, Hello Customer "+ownerx);
      //Alert("Forex Signals Ultimate Trade Panel,");
      //Alert("Will give you the most useful trading experience!");
      //Alert("Detailed videos on usage Youtube.com/ForexSignals");
      //Alert("You can find it on this channel. All your questions are explained in the relevant videos.");
      //Alert("If there is an error or bug, send an e-mail to the developer!");
      //Alert("Mail us :  eurousdforexlive@gmail.com");
      //Alert("We wish you good trading. Forex Signals..");
      //Alert("Your Trade Server: "+accountnumberx+" | "+serverx);




      //Alert("");
      //Alert("");
      //Alert("");
      //Alert("");
      //Alert("");
      //Alert("");


     }

   /*
   Welcome Hello Customer *Owner*.
   Forex Signals Ultimate Trade Panel,
   It will give you the most useful trading experience!

   Detailed videos on usage Youtube.com/ForexSignals
   You can find it on his channel. All your questions are explained in the relevant videos.

   If there is an error, send an e-mail to the developer!
   eurousdforexlive@gmail.com

   We wish you good trading. Forex Signals..
   Your Trade Server: *Server*



   */
   InfoOrderCounterRes();
   InfoPosCounterRes();
   TicketEditRes();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::InfoLabelsRunner()
  {


//double DaystartEquity;
//datetime DaystartDate;
   double balancex;
   double profitxx;
   double equuix;
   long accountnumberx;
   string serverx;
   string ownerx;
   string currencyx;
   double percentageprofitx;
   accountnumberx=AccountInfoInteger(ACCOUNT_LOGIN);
   balancex=AccountInfoDouble(ACCOUNT_BALANCE);
   equuix=AccountInfoDouble(ACCOUNT_EQUITY);
   serverx=AccountInfoString(ACCOUNT_SERVER);
   ownerx=AccountInfoString(ACCOUNT_NAME);
   currencyx=AccountInfoString(ACCOUNT_CURRENCY);
   profitxx=AccountInfoDouble(ACCOUNT_PROFIT);
   percentageprofitx=MathAbs(100*(1-(balancex / (balancex - profitxx))));

   if(DaystartDate!=iTime(Symbol(),PERIOD_D1,0))
     {
      DaystartEquity=equuix;
      DaystartDate=iTime(Symbol(),PERIOD_D1,0);
     }

   if(profitxx<0.00)
     {
      labels[15].Text(DoubleToString(profitxx,2)+" / "+"%"+DoubleToString(percentageprofitx,2));
      labels[15].Color(clrTomato);
     }
   if(profitxx>0.00 || profitxx==0.00)
     {
      labels[15].Text(DoubleToString(profitxx,2)+" / "+"%"+DoubleToString(percentageprofitx,2));
      labels[15].Color(clrDodgerBlue);
     }

   labels[14].Text("Balance: "+DoubleToString(balancex,2)+" | Equity: "+DoubleToString(equuix,2));
   labels[16].Text("Day Start: "+DoubleToString(DaystartEquity,2)+" | "+DoubleToString((equuix-DaystartEquity),2)+" "+currencyx);
//labels[17].Text("Account: "+accountnumberx+" | "+serverx);
//labels[19].Text("Owner: "+ownerx);



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::InfoPosCounterRes()
  {
   int total=PositionsTotal();
   string OpenedCurrentSymbols[][3];
   ArrayResize(OpenedCurrentSymbols,total*2);

   for(int kxl=0; kxl<total; kxl++)
     {
      ulong  position_ticket=PositionGetTicket(kxl);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      bool IsVritenPos=false;

      for(int xc=0; xc<(total*2); xc++)
        {
         if(OpenedCurrentSymbols[xc,0]==position_symbol)
           {
            if(type==POSITION_TYPE_SELL)
              {
               OpenedCurrentSymbols[xc,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,1]))+volume),2);
              }
            if(type==POSITION_TYPE_BUY)
              {
               OpenedCurrentSymbols[xc,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,2]))+volume),2);
              }

            IsVritenPos=true;
           }
        }
      if(IsVritenPos==false)
        {
         for(int xcv=0; xcv<(total*2); xcv++)
           {
            if(OpenedCurrentSymbols[xcv,0]==NULL)
              {
               OpenedCurrentSymbols[xcv,0]=position_symbol;

               if(type==POSITION_TYPE_SELL)
                 {
                  OpenedCurrentSymbols[xcv,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,1]))+volume),2);
                 }
               if(type==POSITION_TYPE_BUY)
                 {
                  OpenedCurrentSymbols[xcv,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,2]))+volume),2);
                 }

               break;
              }
           }
        }
     }



   double totalbuyvolume;
   double totalsellvolume;
   double symbolbuyvolume;
   double symbolsellvolume;

   for(int xcv=0; xcv<(total*2); xcv++)
     {

      if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="")
        {
         double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2); // Sell
         double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2); // Buy

         totalbuyvolume=totalbuyvolume+V2;
         totalsellvolume=totalsellvolume+V1;

         if(OpenedCurrentSymbols[xcv,0]==Symbol())
           {
            symbolbuyvolume=symbolbuyvolume+V2;
            symbolsellvolume=symbolsellvolume+V1;

           }

        }


     }




   labels[3].Text("Volumes All    Buy: "+DoubleToString(totalbuyvolume,2)+" | Sell: "+DoubleToString(totalsellvolume,2));
   labels[4].Text("Volumes Symbol    Buy: "+DoubleToString(symbolbuyvolume,2)+" | Sell: "+DoubleToString(symbolsellvolume,2));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::InfoOrderCounterRes()
  {
   int total=OrdersTotal();
   string OpenedCurrentSymbols[][3];
   ArrayResize(OpenedCurrentSymbols,total*2);

   for(int kxl=0; kxl<total; kxl++)
     {
      ulong  position_ticket=OrderGetTicket(kxl);
      string position_symbol=OrderGetString(ORDER_SYMBOL);
      double volume=OrderGetDouble(ORDER_VOLUME_CURRENT);
      ulong  magic=OrderGetInteger(ORDER_MAGIC);
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);

      bool IsVritenPos=false;

      for(int xc=0; xc<(total*2); xc++)
        {
         if(OpenedCurrentSymbols[xc,0]==position_symbol)
           {
            if(type==ORDER_TYPE_SELL_LIMIT || type==ORDER_TYPE_SELL_STOP)
              {
               OpenedCurrentSymbols[xc,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,1]))+volume),2);
              }
            if(type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP)
              {
               OpenedCurrentSymbols[xc,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xc,2]))+volume),2);
              }

            IsVritenPos=true;
           }
        }
      if(IsVritenPos==false)
        {
         for(int xcv=0; xcv<(total*2); xcv++)
           {
            if(OpenedCurrentSymbols[xcv,0]==NULL)
              {
               OpenedCurrentSymbols[xcv,0]=position_symbol;

               if(type==ORDER_TYPE_SELL_LIMIT || type==ORDER_TYPE_SELL_STOP)
                 {
                  OpenedCurrentSymbols[xcv,1]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,1]))+volume),2);
                 }
               if(type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP)
                 {
                  OpenedCurrentSymbols[xcv,2]=DoubleToString(((StringToDouble(OpenedCurrentSymbols[xcv,2]))+volume),2);
                 }

               break;
              }
           }
        }
     }



   double totalbuyvolume;
   double totalsellvolume;
   double symbolbuyvolume;
   double symbolsellvolume;

   for(int xcv=0; xcv<(total*2); xcv++)
     {

      if(OpenedCurrentSymbols[xcv,0]!=NULL && OpenedCurrentSymbols[xcv,0]!="")
        {
         double V1 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,1]),2); // Sell
         double V2 = NormalizeDouble(StringToDouble(OpenedCurrentSymbols[xcv,2]),2); // Buy

         totalbuyvolume=totalbuyvolume+V2;
         totalsellvolume=totalsellvolume+V1;

         if(OpenedCurrentSymbols[xcv,0]==Symbol())
           {
            symbolbuyvolume=symbolbuyvolume+V2;
            symbolsellvolume=symbolsellvolume+V1;

           }

        }


     }




   labels[8].Text("Pendings    Buy: "+DoubleToString(totalbuyvolume,2)+" | Sell: "+DoubleToString(totalsellvolume,2));

  }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   SetCoordinates();
   SetNames();
   if(!ExtDialog.Create(0, N[Dialog], 0, XY[Dialog][X1], XY[Dialog][Y1], XY[Dialog][X2], XY[Dialog][Y2]))
      return(INIT_FAILED);
//ExtDialog.Create(0, N[Dialog], 0, XY[Dialog][X1], XY[Dialog][Y1], XY[Dialog][X2], XY[Dialog][Y2]);
   ExtDialog.Run();
   ExtDialog.runx();
   ExtDialog.InfoPosCounterRes();
   ExtDialog.InfoOrderCounterRes();
   if(PanelScreenController==1)
     {
      ExtDialog.GetTrades();
      ExtDialog.RefreshTrades("OnnnTrade");
      ExtDialog.RefreshTrades("OnnnTick");
     }

//ExtDialog.GetTrades();
//ExtDialog.ListTrades();
//labels[4].Text("● Current SELL Volume = "+DoubleToString(lotsell,2));


//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   if(traillingonoff==true)
     {
      TraillingRunner();
     }
   if(Coverageonoff==true)
     {
      AutoCloseRunner();
     }
   if(AutoTPBot==true)
     {
      ExtDialog.AutoTPBotRunner();
     }
   ExtDialog.InfoLabelsRunner();


   if(PanelScreenController==1)
     {
      ExtDialog.RefreshTrades("OnnnTick");
     }




  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ExtDialog.ClearLines();
   ExtDialog.Destroy(reason);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
  {
   if(PanelScreenController==1)
     {
      ExtDialog.RefreshTrades("OnnnTrade");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtDialog.TicketEditRes();
   ExtDialog.InfoPosCounterRes();
   ExtDialog.InfoOrderCounterRes();
   ExtDialog.InfoLabelsRunner();

//PanelScreenController=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   ExtDialog.ChartEvent(id, lparam, dparam, sparam);

//ExtDialog.EditRestarts();
   if(id==CHARTEVENT_OBJECT_DRAG && sparam=="SL LEVEL")
     {
      ExtDialog.GetLineSL();
      Alert("DRAGED SL");
     }
   if(id==CHARTEVENT_OBJECT_DRAG && sparam=="TP LEVEL")
     {
      ExtDialog.GetLineTP();
      Alert("DRAGED TP");
     }
   if(sparam=="List Orders1VScroll")
     {
      ExtDialog.ListRowScroller();
      ExtDialog.RefreshTrades("OnnnTick");
     }
   if(sparam=="List Orders8" ||sparam=="List Orders7" || sparam=="List Orders6" || sparam=="List Orders5" || sparam=="List Orders4" || sparam=="List Orders3" || sparam=="List Orders2" || sparam=="List Orders1")
     {
      ExtDialog.ListRowSelector(sparam);
     }


//if(id==CHART && sparam=="List Orders7VScrollBack"){Alert("DRAGED IST1");}
//if(id==CHARTEVENT_OBJECT_CHANGE && sparam=="List Orders7VScrollInc"){Alert("DRAGED IST2");}
//if(id==CHARTEVENT_OBJECT_CHANGE && sparam=="List Orders7VScrollDec"){Alert("DRAGED IST3");}
//if(id==CHARTEVENT_OBJECT_CHANGE && sparam=="List Orders7VScrollThumb"){Alert("DRAGED IST4");}
//if(id==CHARTEVENT_OBJECT_CHANGE && sparam=="List Orders7Back"){Alert("DRAGED IST5");}
   ExtDialog.GetLinePendings();
  }


















//----------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
void Sell(double _volume=0.01,double SL=0.00,double TP=0.00,int ordertype=0,double pricependinga=0.0,string xsymbol="")
  {
   double volume=_volume;
   string symbol=xsymbol;
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   SL=NormalizeDouble(SL,digits);
   TP=NormalizeDouble(TP,digits);
   double open_price=SymbolInfoDouble(symbol,SYMBOL_BID);
   string comment=StringFormat("SELL %s %G lots at %s, SL=%s TP=%s",
                               symbol,volume,
                               DoubleToString(open_price,digits),
                               DoubleToString(SL,digits),
                               DoubleToString(TP,digits));


   if(traillingonoff==false)
     {
      objTrade.SetExpertMagicNumber(magicNumber);
      comment = "M" + magicNumber + " " + comment;
     }
   if(traillingonoff==true)
     {
      objTrade.SetExpertMagicNumber(magicNumberTrailling);
      comment = "M" + magicNumberTrailling + " " + comment;
     }

   if(ordertype==0)
     {
      //Print(xsymbol);
      if(groupopenrun=="OFF" || (groupopenrun=="ON" && comboboxstringVALUE=="SELECT"))
        {
         bool canSell=objTrade.Sell(volume,symbol,open_price,SL,TP,comment);
         if(!canSell)
           {
            //--- mensaje de error
            Print("Fail Sell() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
        }


      if(groupopenrun=="ON" && comboboxstringVALUE=="USD GROUP")
        {
         //eurusd-
         //gbpusd-
         //usdchf+
         //usdjpy+
         //usdcad+
         //audusd-
         //nzdusd-
         //(comboboxstring=="USD GROUP")

         bool canBuy1=objTrade.Buy(volume,"EURUSD",open_price,SL,TP,comment);
         if(!canBuy1)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy2=objTrade.Buy(volume,"GBPUSD",open_price,SL,TP,comment);
         if(!canBuy2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell1=objTrade.Sell(volume,"USDCHF",open_price,SL,TP,comment);
         if(!canSell1)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell2=objTrade.Sell(volume,"USDJPY",open_price,SL,TP,comment);
         if(!canSell2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell3=objTrade.Sell(volume,"USDCAD",open_price,SL,TP,comment);
         if(!canSell3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy3=objTrade.Buy(volume,"AUDUSD",open_price,SL,TP,comment);
         if(!canBuy3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy4=objTrade.Buy(volume,"NZDUSD",open_price,SL,TP,comment);
         if(!canBuy4)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }



        }

      if(groupopenrun=="ON" && comboboxstringVALUE=="EUR GROUP")
        {
         //eurusd+
         //eurchf+
         //eurjpy+
         //eurgbp+
         //eurcad+
         //euraud-
         //eurnzd-
         //(comboboxstring=="USD GROUP")

         bool canSell=objTrade.Sell(volume,"EURUSD",open_price,SL,TP,comment);
         if(!canSell)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell1=objTrade.Sell(volume,"EURCHF",open_price,SL,TP,comment);
         if(!canSell1)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell2=objTrade.Sell(volume,"EURJPY",open_price,SL,TP,comment);
         if(!canSell2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell3=objTrade.Sell(volume,"EURGBP",open_price,SL,TP,comment);
         if(!canSell3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell4=objTrade.Sell(volume,"EURCAD",open_price,SL,TP,comment);
         if(!canSell4)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell5=objTrade.Sell(volume,"EURAUD",open_price,SL,TP,comment);
         if(!canSell5)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell6=objTrade.Sell(volume,"EURNZD",open_price,SL,TP,comment);
         if(!canSell6)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }



        }
      if(groupopenrun=="ON" && comboboxstringVALUE=="GBP GROUP")
        {
         //GBPUSD+
         //EURGBP-
         //GBPCHF+
         //GBPJPY+
         //GBPNZD+
         //GBPCAD+
         //GBPAUD+
         //(comboboxstring=="USD GROUP")

         bool canSell=objTrade.Sell(volume,"GBPUSD",open_price,SL,TP,comment);
         if(!canSell)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy11=objTrade.Buy(volume,"EURGBP",open_price,SL,TP,comment);
         if(!canBuy11)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell2=objTrade.Sell(volume,"GBPCHF",open_price,SL,TP,comment);
         if(!canSell2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell3=objTrade.Sell(volume,"GBPJPY",open_price,SL,TP,comment);
         if(!canSell3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell4=objTrade.Sell(volume,"GBPNZD",open_price,SL,TP,comment);
         if(!canSell4)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell5=objTrade.Sell(volume,"GBPCAD",open_price,SL,TP,comment);
         if(!canSell5)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell6=objTrade.Sell(volume,"GBPAUD",open_price,SL,TP,comment);
         if(!canSell6)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }



        }

     }
   if(ordertype==1)
     {
      bool canSell=objTrade.SellLimit(volume,pricependinga,symbol,SL,TP,0,0,comment);
      if(!canSell)
        {
         //--- mensaje de error
         Print("Fail Sell() method. Return code=",objTrade.ResultRetcode(),
               ". error message: ",objTrade.ResultRetcodeDescription());
        }
     }
   if(ordertype==2)
     {
      bool canSell=objTrade.SellStop(volume,pricependinga,symbol,SL,TP,0,0,comment);
      if(!canSell)
        {
         //--- mensaje de error
         Print("Fail Sell() method. Return code=",objTrade.ResultRetcode(),
               ". error message: ",objTrade.ResultRetcodeDescription());
        }
     }



   TraillingLogger();

  }
//+------------------------------------------------------------------+
void Buy(double _volume=0.01,double SL=0.00,double TP=0.00,int ordertype=0,double pricependinga=0.0,string xsymbol="")
  {

   double volume=_volume;
   string symbol=xsymbol;
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   SL=NormalizeDouble(SL,digits);
   TP=NormalizeDouble(TP,digits);
   double open_price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   string comment=StringFormat("BUY %s %G lots at %s, SL=%s TP=%s",
                               symbol,volume,
                               DoubleToString(open_price,digits),
                               DoubleToString(SL,digits),
                               DoubleToString(TP,digits));

   if(traillingonoff==false)
     {
      objTrade.SetExpertMagicNumber(magicNumber);
      comment = "M" + magicNumber + " " + comment;
     }
   if(traillingonoff==true)
     {
      objTrade.SetExpertMagicNumber(magicNumberTrailling);
      comment = "M" + magicNumberTrailling + " " + comment;
     }

   if(ordertype==0)
     {
      if(groupopenrun=="OFF" || (groupopenrun=="ON" && comboboxstringVALUE=="SELECT"))
        {
         //Print(xsymbol);
         bool canBuy=objTrade.Buy(volume,xsymbol,open_price,SL,TP,comment);
         if(!canBuy)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
        }

      if(groupopenrun=="ON" && comboboxstringVALUE=="USD GROUP")
        {
         //eurusd-
         //gbpusd-
         //usdchf+
         //usdjpy+
         //usdcad+
         //audusd-
         //nzdusd-
         //(comboboxstring=="USD GROUP")

         bool canSell1=objTrade.Sell(volume,"EURUSD",open_price,SL,TP,comment);
         if(!canSell1)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell2=objTrade.Sell(volume,"GBPUSD",open_price,SL,TP,comment);
         if(!canSell2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy1=objTrade.Buy(volume,"USDCHF",open_price,SL,TP,comment);
         if(!canBuy1)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy2=objTrade.Buy(volume,"USDJPY",open_price,SL,TP,comment);
         if(!canBuy2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy3=objTrade.Buy(volume,"USDCAD",open_price,SL,TP,comment);
         if(!canBuy3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell3=objTrade.Sell(volume,"AUDUSD",open_price,SL,TP,comment);
         if(!canSell3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell4=objTrade.Sell(volume,"NZDUSD",open_price,SL,TP,comment);
         if(!canSell4)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }



        }

      if(groupopenrun=="ON" && comboboxstringVALUE=="EUR GROUP")
        {
         //eurusd+
         //eurchf+
         //eurjpy+
         //eurgbp+
         //eurcad+
         //euraud-
         //eurnzd-
         //(comboboxstring=="USD GROUP")

         bool canBuy=objTrade.Buy(volume,"EURUSD",open_price,SL,TP,comment);
         if(!canBuy)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy1=objTrade.Buy(volume,"EURCHF",open_price,SL,TP,comment);
         if(!canBuy1)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy2=objTrade.Buy(volume,"EURJPY",open_price,SL,TP,comment);
         if(!canBuy2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy3=objTrade.Buy(volume,"EURGBP",open_price,SL,TP,comment);
         if(!canBuy3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy4=objTrade.Buy(volume,"EURCAD",open_price,SL,TP,comment);
         if(!canBuy4)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy5=objTrade.Buy(volume,"EURAUD",open_price,SL,TP,comment);
         if(!canBuy5)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy6=objTrade.Buy(volume,"EURNZD",open_price,SL,TP,comment);
         if(!canBuy6)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }



        }
      if(groupopenrun=="ON" && comboboxstringVALUE=="GBP GROUP")
        {
         //GBPUSD+
         //EURGBP-
         //GBPCHF+
         //GBPJPY+
         //GBPNZD+
         //GBPCAD+
         //GBPAUD+
         //(comboboxstring=="USD GROUP")

         bool canBuy=objTrade.Buy(volume,"GBPUSD",open_price,SL,TP,comment);
         if(!canBuy)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canSell11=objTrade.Sell(volume,"EURGBP",open_price,SL,TP,comment);
         if(!canSell11)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy2=objTrade.Buy(volume,"GBPCHF",open_price,SL,TP,comment);
         if(!canBuy2)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy3=objTrade.Buy(volume,"GBPJPY",open_price,SL,TP,comment);
         if(!canBuy3)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy4=objTrade.Buy(volume,"GBPNZD",open_price,SL,TP,comment);
         if(!canBuy4)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy5=objTrade.Buy(volume,"GBPCAD",open_price,SL,TP,comment);
         if(!canBuy5)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }
         bool canBuy6=objTrade.Buy(volume,"GBPAUD",open_price,SL,TP,comment);
         if(!canBuy6)
           {
            Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
                  ". error message: ",objTrade.ResultRetcodeDescription());
           }



        }

     }
   if(ordertype==1)
     {
      bool canBuy=objTrade.BuyLimit(volume,pricependinga,symbol,SL,TP,0,0,comment);
      if(!canBuy)
        {
         Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
               ". error message: ",objTrade.ResultRetcodeDescription());
        }
     }

   if(ordertype==2)
     {
      bool canBuy=objTrade.BuyStop(volume,pricependinga,symbol,SL,TP,0,0,comment);
      if(!canBuy)
        {
         Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
               ". error message: ",objTrade.ResultRetcodeDescription());
        }
     }
   TraillingLogger();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoCloseRunner()
  {
   if(AccountInfoDouble(ACCOUNT_PROFIT)>coveragelevelplus)
     {
      CloseAllPositions(0,0,"noticket",1);
     }
   if(AccountInfoDouble(ACCOUNT_PROFIT)<coveragelevel)
     {
      CloseAllPositions(0,0,"noticket",1);
     }
  }


//+------------------------------------------------------------------+
void TraillingRunner()
  {


   if(traillingonoff==true && traillinglog==false)
     {
      for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of open positions
        {
         if(objPosition.SelectByIndex(i))
           {
            //Alert(objPosition.Symbol()+"SYM");

            int digits_adjust=1;
            double m_adjusted_point;
            double ExtTrailingStop;
            double ExtTrailingStep;
            int xdigits=SymbolInfoInteger(objPosition.Symbol(),SYMBOL_DIGITS);
            double xpoints=SymbolInfoDouble(objPosition.Symbol(),SYMBOL_POINT);

            if(xdigits==3 || xdigits==5)
              {
               digits_adjust=10;
              }
            m_adjusted_point=xpoints*digits_adjust;
            // double testt;
            // testt=NormalizeDouble(traillingDistance*xpoints,xdigits);
            ExtTrailingStop=traillingDistancex2*m_adjusted_point;
            ExtTrailingStep=traillingStepx2*m_adjusted_point;

            if(ExtTrailingStop==0)
              {
               return;
               Alert("Stop Distance Band Error,Check Distance Level On NOVA Trade Panel");
              }

            if(objPosition.Magic()==magicNumberTrailling)
              {
               if(objPosition.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(objPosition.PriceCurrent()-objPosition.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                    {
                     if((objPosition.StopLoss()<objPosition.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep)) && (objPosition.StopLoss()!=0.0))
                       {
                        if(!objTrade.PositionModify(objPosition.Ticket(),NormalizeDouble(objPosition.PriceCurrent()-ExtTrailingStop,xdigits),objPosition.TakeProfit()))
                          {
                           //Print("Modify ",objPosition.Ticket()," Position -> false. Result Retcode: ",objTrade.ResultRetcode(),", description of result: ",objTrade.ResultRetcodeDescription());
                           Alert("Position Modify Error On Trailling Stop, Check Settings or Contact Us Developer");
                           Alert("Contact : Youtube&Instagram : ForexNovaProject || forexnovaproject@gmail.com");
                           continue;
                          }
                       }
                    }
                 }
               else
                 {
                  if(objPosition.PriceOpen()-objPosition.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                    {
                     if((objPosition.StopLoss()>(objPosition.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) && (objPosition.StopLoss()!=0.0))
                       {
                        if(!objTrade.PositionModify(objPosition.Ticket(),NormalizeDouble(objPosition.PriceCurrent()+ExtTrailingStop,xdigits),objPosition.TakeProfit()))
                          {
                           Alert("Position Modify Error On Trailling Stop, Check Settings or Contact Us Developer");
                           Alert("Contact : Youtube&Instagram : ForexNovaProject || forexnovaproject@gmail.com");
                          }
                       }
                    }
                 }
              }
           }
        }

     }












   if(traillingonoff==true && traillinglog==true)
     {
      for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of open positions
        {
         if(objPosition.SelectByIndex(i))
           {

            int loggid;
            for(int i=0; i<99; i++)
              {
               if(traillingloggs[i,0]==objPosition.Ticket())
                 {
                  loggid=i;
                  break;
                  Alert(loggid);
                 }
              }
            //Alert(traillingloggs[loggid,1]+" : "+traillingloggs[loggid,2]+" : "+"logid: "+loggid);

            //Alert(objPosition.Symbol()+"SYM");

            int digits_adjust=1;
            double m_adjusted_point;
            double ExtTrailingStop;
            double ExtTrailingStep;
            int xdigits=SymbolInfoInteger(objPosition.Symbol(),SYMBOL_DIGITS);
            double xpoints=SymbolInfoDouble(objPosition.Symbol(),SYMBOL_POINT);

            if(xdigits==3 || xdigits==5)
              {
               digits_adjust=10;
              }
            m_adjusted_point=xpoints*digits_adjust;
            // double testt;
            // testt=NormalizeDouble(traillingDistance*xpoints,xdigits);
            ExtTrailingStop=traillingloggs[loggid,1]*m_adjusted_point;
            ExtTrailingStep=traillingloggs[loggid,2]*m_adjusted_point;

            if(ExtTrailingStop==0)
              {
               return;
               Alert("Stop Distance Band Error,Check Distance Level On NOVA Trade Panel");
              }

            if(objPosition.Magic()==magicNumberTrailling)
              {
               if(objPosition.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(objPosition.PriceCurrent()-objPosition.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                    {
                     if((objPosition.StopLoss()<objPosition.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep)) && (objPosition.StopLoss()!=0.0))
                       {
                        if(!objTrade.PositionModify(objPosition.Ticket(),NormalizeDouble(objPosition.PriceCurrent()-ExtTrailingStop,xdigits),objPosition.TakeProfit()))
                          {
                           //Print("Modify ",objPosition.Ticket()," Position -> false. Result Retcode: ",objTrade.ResultRetcode(),", description of result: ",objTrade.ResultRetcodeDescription());
                           Alert("Position Modify Error On Trailling Stop, Check Settings or Contact Us Developer");
                           Alert("Contact : Youtube&Instagram : ForexNovaProject || forexnovaproject@gmail.com");
                           continue;
                          }
                       }
                    }
                 }
               else
                 {
                  if(objPosition.PriceOpen()-objPosition.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                    {
                     if((objPosition.StopLoss()>(objPosition.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) && (objPosition.StopLoss()!=0.0))
                       {
                        if(!objTrade.PositionModify(objPosition.Ticket(),NormalizeDouble(objPosition.PriceCurrent()+ExtTrailingStop,xdigits),objPosition.TakeProfit()))
                          {
                           Alert("Position Modify Error On Trailling Stop, Check Settings or Contact Us Developer");
                           Alert("Contact : Youtube&Instagram : ForexNovaProject || forexnovaproject@gmail.com");
                          }
                       }
                    }
                 }
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void TraillingLogger()
  {

   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of open positions
     {
      bool xwritedpos=false;
      if(objPosition.SelectByIndex(i))
        {
         for(int i=0; i<99; i++)
           {
            if(traillingloggs[i,0]==objPosition.Ticket())
              {
               xwritedpos=true;
              }
           }
         if(xwritedpos==false)
           {
            for(int x=0; x<99; x++)
              {
               if(traillingloggs[x,0]==NULL)
                 {
                  traillingloggs[x,0]=objPosition.Ticket();
                  traillingloggs[x,1]=traillingDistancex2;
                  traillingloggs[x,2]=traillingStepx2;
                  break;
                 }
              }
           }
        }
     }



   for(int i=0; i<99; i++)
     {
      bool xeraser=true;

      for(int x=PositionsTotal()-1; x>=0; x--) // returns the number of open positions
        {
         if(objPosition.SelectByIndex(x))
           {
            if(traillingloggs[i,0]==objPosition.Ticket())
              {
               xeraser=false;
              }
           }
        }

      if(xeraser==true)
        {
         traillingloggs[i,0]=NULL;
         traillingloggs[i,1]=NULL;
         traillingloggs[i,2]=NULL;
        }
     }
   /*
            for(int i=0; i<99; i++)
            {
                  for(int x=PositionsTotal()-1;x>=0;x--) // returns the number of open positions
                  {
                     if(objPosition.SelectByIndex(x))
                     {
                        if(traillingloggs[i,0]==objPosition.Ticket())

                     }

                  }
            }
   */
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool ClosePosition(ulong ticket=0)
  {
   return objTrade.PositionClose(ticket);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/*
//+------------------------------------------------------------------+
void VolumeChecker()
  {
   TotalSellVolume=0.0;
   TotalBuyVolume=0.0;
   CurrentSellVolume=0.0;
   CurrentBuyVolume=0.0;

   MqlTradeRequest request;
   MqlTradeResult  result;

   int total=PositionsTotal();
   for(int i=0; i<total; i++)
     {
      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(type==POSITION_TYPE_SELL )
        {
         TotalSellVolume = TotalSellVolume + volume;

         if(position_symbol==Symbol())
         {
            CurrentSellVolume = CurrentSellVolume + volume;
         }
        }

      if(type==POSITION_TYPE_BUY )
        {
         TotalBuyVolume = TotalBuyVolume + volume;

         if(position_symbol==Symbol())
         {
            CurrentBuyVolume = CurrentBuyVolume + volume;
         }
        }
      }
  }
//+------------------------------------------------------------------+
*/








/*

//+------------------HEDGE AREA------------------------------------------------+
void AutoHedgeCreator()
  {
   double HedgeVolume;
   TradeInfoHedge();
   for(int h=0; h<HowManyWorkingPairs; h++)
     {
      if(MTBuyVolume[h]>MTSellVolume[h])
        {
         HedgeVolume = (MTBuyVolume[h]-MTSellVolume[h]);

         if(ControlHedgeAll&&MTOrderMin[h]!=myMinute()){Sell(HedgeVolume,AllPairs[h],"buy hedge");MTOrderMin[h]=myMinute();}
        }

      if(MTSellVolume[h]>MTBuyVolume[h])
        {
         HedgeVolume = (MTSellVolume[h]-MTBuyVolume[h]);

         if(ControlHedgeAll&&MTOrderMin[h]!=myMinute()){Buy(HedgeVolume,AllPairs[h],"sell hedge");MTOrderMin[h]=myMinute();}
        }
     }


  }


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeInfoHedge()
  {
   int total=PositionsTotal();
   string OpenedCurrentSymbols[];
   ArrayResize(OpenedCurrentSymbols,100);
   for(int kxl=0; kxl<total; kxl++)
     {
      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);

       for(int kxlc=0; kxlc<total; kxlc++)
         {
            if(OpenedCurrentSymbols[kxlc]!=position_symbol)
            {
               for(int kxlcv=0; kxlcv<total; kxlcv++)
               {
                  if(OpenedCurrentSymbols[kxlcv]==NULL){OpenedCurrentSymbols[kxlv]=position_symbol;}

               }
            }
            if(OpenedCurrentSymbols[kxlc]==position_symbol){break;}
         }

     }
     ArrayRange(OpenedCurrentSymbols,0);

     Comment(ArrayRange(OpenedCurrentSymbols,0));

   for(int kl=0; kl<HowManyWorkingPairs; kl++)
     {
      MTSellCounts[kl]=0.00;
      MTSellProfit[kl]=0.00;
      MTSellVolume[kl]=0.00;
      MTBuyCounts[kl]=0.00;
      MTBuyProfit[kl]=0.00;
      MTBuyVolume[kl]=0.00;
      MTTotalBuyProfit=0.00;
      MTTotalSellProfit=0.00;
     }
   for(int i=0; i<total; i++)
     {
      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      double position_profit=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      double position_size=PositionGetDouble(POSITION_VOLUME);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      TradeOrderTickets[i] = position_ticket;
      for(int j=0; j<=HowManyWorkingPairs; j++)

        {
         if(position_symbol==AllPairs[j]&&POSITION_TYPE_BUY==type)
           {
            MTBuyCounts[j]=MTBuyCounts[j]+1.00;
            MTBuyProfit[j]=MTBuyProfit[j]+position_profit;
            MTBuyVolume[j]=MTBuyVolume[j]+position_size;
            MTTotalBuyProfit=MTTotalBuyProfit+position_profit;
           }
         if(position_symbol==AllPairs[j]&&POSITION_TYPE_SELL==type)
           {
            MTSellCounts[j]=MTSellCounts[j]+1.00;
            MTSellProfit[j]=MTSellProfit[j]+position_profit;
            MTSellVolume[j]=MTSellVolume[j]+position_size;
            MTTotalSellProfit=MTTotalSellProfit+position_profit;
           }
        }


     }
  }

//+------------------------------------------------------------------+





class CDRRAG : public CWndClient
{
   public:
      CDRRAG(void);
      ~CDRRAG(void);

         //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //virtual bool      OnScrollLineUp(void);
   //bool OnScrollLineUpXX(void);
protected:

};
EVENT_MAP_BEGIN(CDRRAG)
   //ON_EVENT(ON_SCROLL_DEC,m_scroll_v,OnScrollLineUp)

EVENT_MAP_END(CWndClient)
CDRRAG::CDRRAG(void)
{
Print("ONLINE");
    OnScrollLineUp();
}
CDRRAG::~CDRRAG(void){}

*/


//+------------------------------------------------------------------+
