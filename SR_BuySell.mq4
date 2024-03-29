//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots  0

#include <Zmq/Zmq.mqh>

long time_maping;
string Copyright = "SR BuySell Trading | Appsportal.in";
string Notice = "Developed By Sandip R. Pawar @ Mobile no. 9423950322 ";
///////////////////////////////////////////////////////HTTP-START////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//////////////////////////////////////////////////////////////HTTP-END/////////////////////////////////////////////////////////////////////

string ObjName="SANDIP";

#property indicator_buffers 6

double Tt;



bool CROSS_ENTRY=false;
int CR=0;
int SR=0;

input string Logic_PROPERTIES="------------------Logic PROPERTIES--------------------------";//--
input bool Intraday=false;//Intraday ON/OFF (Intraday/Positional)
input string TradeStartTime="08:45";//Intraday Trade Start Time
input string TradeEndTime="14:45";//Intraday Trade End Time





enum _TradeMethod
  {
   ONLY_BUY,//ONLY BUY
   ONLY_SELL,//ONLY SELL
   METRO//METRO
  };
_TradeMethod TradeMethod =METRO;//TRADE METHOD

input bool STOPLOSS_ON=false;//Stoploss ON/OFF
enum Stoploss_Types
  {
   Normal,//NORMAL
   Trailing_Step,//TRAILING STEPS
   Breakeven //BREAKEVEN
  };
input Stoploss_Types Stoploss_Type = Breakeven;//Stoploss Type

extern int BreakEvenCandle = 1;

extern double STOPLOSS = 40;
extern double TRAILING_STEP = 10;
extern double TRAILING_STOP = 5;
input bool TARGET_ON=false;//Target ON/OFF
extern double TARGET = 500;
extern double Qty=1;


extern double BullLevel=0;
extern double BearLevel=0;

extern bool RE_ENTRY=false;

extern bool PrevDayHL_ENTRY=false;

extern bool PrevDayHL_LineVisible=false;

input string EMA_PROPERTIES="------------------EMA PROPERTIES--------------------------";//--
input bool EMA_Confirmation=false;//EMA BASED ON RSI Confirmation ON/OFF
input int EMA_Confirmation_Period=50;//EMA Period
input int EMA_Independent_Confirmation_Period=200;//EMA Period




/////////////Global Variables
string LastSignal="WAITING";
bool LastTradeOpen=false;
double entry=0;
double stop=0;
double target=0;

double trailingEntry=0;

double breakeven_candle_high=0;
double breakeven_candle_low=0;
datetime breakeven_candle_time=0;

bool FirstTick=true;
bool FirstTrade=false;

datetime          market_start=0;
datetime          market_close=0;
datetime          new_day=0;


double BuyArrow[];
double SellArrow[];

double TPArrow[];
double SLArrow[];

// double STPArrow[];
// double SSLArrow[];

double ENDArrow[];

datetime LastEntryTime=0;

int RemainingQty=0;

int TotalTrades=0;
int ProfitTrades=0;
int LossTrades=0;
double TotalPnl=0;

/////Strategy Variables
// Global variables:
double RsiMa[];
double TrendFast[];
double TrendSlow[];
double trend[];
string indicatorFileName;
bool   returnBars;

double cross_signal[];


int PossitiveTrades=0;
int NegativeTrades=0;


int PossitiveT=0;
int NegativeT=0;

double CPNL=0;


double Buy[];


//+------------------------------------------------------------------+

//--- input parameters of the script
string           InpName="Button";            // Button name
ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER; // Chart corner for anchoring
string           InpFont="Arial";             // Font
int              InpFontSize=14;              // Font size
color            InpColor=clrBlack;           // Text color
color            InpBackColor=C'236,233,216'; // Background color
color            InpBorderColor=clrNONE;      // Border color
bool             InpState=false;              // Pressed/Released
bool             InpBack=false;               // Background object
bool             InpSelection=false;          // Highlight to move
bool             InpHidden=true;              // Hidden in the object list
long             InpZOrder=0;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_RIGHT_LOWER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER, CORNER_RIGHT_LOWER);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

datetime Now_Time;
int OneTime = 0;


int BOneTime=0;
int SOneTime=0;




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   Now_Time = Time[0];
   ButtonTextChange(0,"Button_B", "BUY");
   ButtonTextChange(0,"Button_S", "SELL");

   ObjectsDeleteAll();
//ObjectDelete("SellArrow");
//ObjectDelete("TargetArchived");
//ObjectDelete("SLAchived");

//--- indicator buffers mapping
   if(IsDllsAllowed()==false)
     {
      Alert("DLL IMPORT NOT ENABLED !!!");
      return(INIT_FAILED);
     }

   IndicatorBuffers(5);

   SetIndexBuffer(0,BuyArrow);
   SetIndexArrow(0,233);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,3,clrLime);

   SetIndexBuffer(1,SellArrow);
   SetIndexArrow(1,234);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,3,clrRed);

   SetIndexBuffer(2,TPArrow);
   SetIndexArrow(2,252);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,clrYellow);

   SetIndexBuffer(3,SLArrow);
   SetIndexArrow(3,251);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,clrPink);


   SetIndexBuffer(4,ENDArrow);
   SetIndexArrow(4,172);
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,1,clrAqua);


   setLabel(Copyright,Copyright,RoyalBlue,2,5,10,false,9,"Arel");

   Dashboard();

// CreateButton("SQUARE_BUTTON",100,50,80,30,"SQUARE OFF",8,clrWhite,clrBlue,"Calibri",CORNER_RIGHT_LOWER);

// CreateButton("SELL_BUTTON",200,50,80,30,"SELL",8,clrWhite,clrRed,"Calibri",CORNER_RIGHT_LOWER);

// CreateButton("BUY_BUTTON",300,50,80,30,"BUY",8,clrWhite,clrGreen,"Calibri",CORNER_RIGHT_LOWER);


   ButtonCreate(0,"Button_E",0,100,50,80,30,InpCorner,"EXIT","Calibri",InpFontSize, clrWhite,clrBlue,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);

   ButtonCreate(0,"Button_S",0,200,50,80,30,InpCorner,"SELL","Calibri",InpFontSize, clrWhite,clrRed,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);

   ButtonCreate(0,"Button_B",0,300,50,80,30,InpCorner,"BUY","Calibri",InpFontSize, clrWhite,clrGreen,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);

   ChartRedraw();

//---
   return(INIT_SUCCEEDED);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const string text="Text")   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id,// Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      string objectname=sparam;
      if(StringFind(objectname,"Button_E",0)>-1)
        {


         // ManualClose(0,"ALL");
         Squareoff(0,Close[0]);
         ButtonTextChange(0,"Button_B", "BUY");
         ButtonTextChange(0,"Button_S", "SELL");


        }


      if(StringFind(objectname,"Button_B",0)>-1)
        {
         if(LastSignal=="BUY" && LastTradeOpen)
           {

           }
         else
           {


            if(LastSignal=="SELL" && LastTradeOpen)
              {
               Exitoff(0,Close[0]);

              }
            else
              {


               // DrawArrowUp("BuyArrow"+ 0,Low[0]-iATR(NULL,0,15,0)*0.5,clrLime);

               FreshBuy(0);
               ButtonTextChange(0,"Button_B", "--");

              }
           }
        }


      if(StringFind(objectname,"Button_S",0)>-1)
        {

         if(LastSignal=="SELL" && LastTradeOpen)
           {

           }
         else
           {

            if(LastSignal=="BUY" && LastTradeOpen)
              {
               Exitoff(0,Close[0]);

              }
            else
              {


               FreshSell(0);
               ButtonTextChange(0,"Button_S", "--");
              }
           }
        }

      WindowRedraw();
     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawArrowUp(string ArrowName,double LinePrice,color LineColor)
  {
   ObjectCreate(ArrowName, OBJ_ARROW, 0, Time[0], LinePrice); //draw an up arrow
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, 233);
   ObjectSet(ArrowName, OBJPROP_COLOR,LineColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawArrowDown(string ArrowName,double LinePrice,color LineColor)
  {
   ObjectCreate(ArrowName, OBJ_ARROW, 0, Time[0], LinePrice); //draw an up arrow
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, 234);
   ObjectSet(ArrowName, OBJPROP_COLOR,LineColor);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTargetArchived(string TargetAchived,double LinePrice,color LineColor)
  {
   ObjectCreate(TargetAchived, OBJ_ARROW_CHECK, 0, Time[0], LinePrice); //draw an up arrow
   ObjectSet(TargetAchived, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(TargetAchived, OBJPROP_ARROWCODE, 252);
   ObjectSet(TargetAchived, OBJPROP_COLOR,LineColor);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSL(string SLAchived,double LinePrice,color LineColor)
  {
   ObjectCreate(SLAchived, OBJ_ARROW_STOP, 0, Time[0], LinePrice); //draw an up arrow
   ObjectSet(SLAchived, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(SLAchived, OBJPROP_ARROWCODE, 251);
   ObjectSet(SLAchived, OBJPROP_COLOR,LineColor);
  }

//+------------------------------------------------------------------+
void CreateButton(string name,int x,int y,int width,int height,string text,int fontsize,color clr,color back_clr,string font,int corner)
  {
   name=ObjName+"_OBJ_BUTTON_"+name;

   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
//--- set label coordinates
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);

   ObjectSetInteger(0,name,OBJPROP_STATE,false);
//--- set the text
   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_CENTER);
//--- set text font
   ObjectSetString(0,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
//--- set color
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);

   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,back_clr);
//--- display in the foreground (false) or background (true)
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
//--- set the priority for receiving the event of a mouse click in the cha
  }




//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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



   int limit=0;
   if(FirstTick)
     {
      limit=Bars-5;
      ResetVariables();
      FirstTick=false;
     }
   else
     {
      limit=0;
     }

// QQEProcess();

   for(int i=limit; i>=0; i--)
     {


      if(LastTradeOpen)
        {
         double pnl = (LastSignal=="BUY")?(Close[i]-entry):(entry-Close[i]);
         CPNL = pnl;
        }
      else
        {
         CPNL = 0;
        }




      bool BuyValid=false;
      bool SellValid=false;



      int CYY=TimeYear(iTime(_Symbol,PERIOD_CURRENT,0));     // Year
      int CMN=TimeMonth(iTime(_Symbol,PERIOD_CURRENT,0));   // Month
      int CDD=TimeDay(iTime(_Symbol,PERIOD_CURRENT,0));    // Day


      int YY=TimeYear(Time[i]);     // Year
      int MN=TimeMonth(Time[i]);    // Month
      int DD=TimeDay(Time[i]);      // Day


      double AOpen, AClose, AHigh, ALow, BOpen, BClose, BHigh, BLow, COpen, CClose, CHigh, CLow;

      if(CYY == YY && CMN==MN && CDD==DD && BullLevel > 0 && BearLevel > 0)
        {

         // Print (Open[0]);

         double TH = iHigh(NULL, PERIOD_D1, 0);    // today's high
         double TL = iLow(NULL, PERIOD_D1, 0);    // today's high

         if(Close[0] > BullLevel && LastTradeOpen==false && BOneTime > 0)
           {
            BullLevel = TH;
            Print("Please Check Bullish Level Again ! Auto Level is" + TH);
           }

         if(Close[0] < BearLevel && LastTradeOpen==false && SOneTime > 0)
           {
            BearLevel = TL;
            Print("Please Check Bearish Level Again ! Auto Level is" + TL);
           }

 
         if(Open[0] > BullLevel && BOneTime == 0 && Open[1] < Close[1] && LastTradeOpen==false )
           {
            BuyValid=true;
            SellValid=false;

// Print("B" + BuyValid + "and " + "S" + SellValid);            
            
            // BOneTime += 1;
           }

         if(Open[0] < BearLevel && SOneTime == 0 && Open[1] > Close[1] && LastTradeOpen==false)
           {
            SellValid=true;
            BuyValid=false;
            // SOneTime += 1;
           }


         if(BullLevel < iHigh(Symbol(),1440,1))
           {

            if(Open[0] > iHigh(Symbol(),1440,1) && BOneTime == 1 &&  PrevDayHL_ENTRY)
              {
               BuyValid=true;
               SellValid=false;
               
              }

           }

         if(BearLevel > iLow(Symbol(),1440,1))
           {

            if(Open[0] < iLow(Symbol(),1440,1) && SOneTime == 1 &&  PrevDayHL_ENTRY)
              {
               SellValid=true;
               BuyValid=false;
               
              }

           }

         if(Open[0] < BullLevel && RE_ENTRY)
           {
            BOneTime = 0;
           }

         if(Open[0] > BearLevel && RE_ENTRY)
           {
            SOneTime = 0;
           }
        }


      //-------------- EMA Confirmation

      if(EMA_Confirmation && BuyValid || EMA_Confirmation && SellValid)
        {
         double EMAFifty = iMA(_Symbol,PERIOD_CURRENT,EMA_Confirmation_Period,0,MODE_EMA,PRICE_CLOSE,i);
         double EMATwoHundred = iMA(_Symbol,PERIOD_CURRENT,EMA_Independent_Confirmation_Period,0,MODE_EMA,PRICE_CLOSE,i);

      if(Open[0] < EMAFifty || Open[0] > EMATwoHundred )
        {
         BuyValid=false;
         SellValid=false;
        }


         if(Open[0] > EMAFifty && EMAFifty > EMATwoHundred && BuyValid==true)
           {
            BuyValid=true;
            SellValid=false;
           } else
               {
                
                if(Open[0] > EMAFifty && Open[0] < EMATwoHundred)
                  {
                   BullLevel = EMATwoHundred;
                  }
                
               }
 
         if(Open[0] < EMAFifty && EMAFifty < EMATwoHundred && SellValid==true)
           {
            SellValid=true;
            BuyValid=false;
           } else
               {
                if(Open[0]< EMAFifty && Open[0] > EMATwoHundred)
                  {
                   BearLevel = EMATwoHundred;
                  }
               }
           
           
  
        }









      if(BuyValid)
        {
        
        
         if(LastSignal=="BUY" && LastTradeOpen)
           {
           }
         else
           {
            if(LastSignal=="SELL" && LastTradeOpen)
              {
               Exitoff(0,Close[0]);
              }
            else
              {
               // DrawArrowUp("BuyArrow"+ 0,Low[0]-iATR(NULL,0,15,0)*0.5,clrLime);
               BOneTime += 1;
               FreshBuy(0);
               ButtonTextChange(0,"Button_B", "--");
               
              }
           }
        }

      if(SellValid)
        {
        
         if(LastSignal=="SELL" && LastTradeOpen)
           {

           }
         else
           {
            if(LastSignal=="BUY" && LastTradeOpen)
              {
               Exitoff(0,Close[0]);
              }
            else
              {
               SOneTime += 1;
               FreshSell(0);
               ButtonTextChange(0,"Button_S", "--");
               
              }
           }
        }





      datetime current_date=StrToTime(TimeToString(iTime(_Symbol,PERIOD_CURRENT,i),TIME_DATE));

      if(current_date>new_day)
        {
         new_day=current_date;

         market_start=0;
         market_start+=new_day;
         market_start+=TimeHour(StrToTime(TradeStartTime))*PeriodSeconds(PERIOD_H1)+ TimeMinute(StrToTime(TradeStartTime))*PeriodSeconds(PERIOD_M1);

         market_close=0;
         market_close+=new_day;
         market_close+=TimeHour(StrToTime(TradeEndTime))*PeriodSeconds(PERIOD_H1)+ TimeMinute(StrToTime(TradeEndTime))*PeriodSeconds(PERIOD_M1);

         if(Intraday)
           {
            if(LastTradeOpen)
              {
               // ENDArrow[i]=High[i]+iATR(NULL,0,15,i)*0.5;
               Squareoff(i,Close[i]);
              }
            //TotalTrades=0;
            //TotalPnl=0;
            LastSignal="WAITING";
           }
        }

      bool valid = false;


      if(Intraday)
        {
         if(Times(i,limit)>=market_start && Times(i,limit)<market_close)
           {
            valid=true;
           }
         else
           {
            valid = false;

            if(LastTradeOpen)
              {
               // ENDArrow[i]=High[i]+iATR(NULL,0,15,i)*0.5;
               Squareoff(i,Close[i]);
              }
           }
        }
      else
        {
         valid=true;
        }


      if(valid)
        {

         CheckTPSL(i);

        }

     }

   Dashboard();
//--- return value of prev_calculated for next call
   return(rates_total);
  }


//+------------------------------------------------------------------+
void FreshBuy(int i)
  {
   if(LastTradeOpen)
     {
      Squareoff(i,Close[i]);
     }

   if(i==0)
     {
      FirstTrade=true;
     }


   LastSignal="BUY";
   LastTradeOpen=true;

   entry=0;
   stop=0;
   target=0;
   trailingEntry=0;

   breakeven_candle_high=0;
   breakeven_candle_low=0;
   breakeven_candle_time=0;

   entry=Close[i];

   trailingEntry=entry;

   breakeven_candle_high=High[i+1];
   breakeven_candle_low=Low[i+1];
   breakeven_candle_time=Time[i+1];

   LastEntryTime=Time[i];

   if(STOPLOSS_ON)
     {
      if(STOPLOSS>0)
        {
         stop=entry - STOPLOSS;
        }
     }
   if(TARGET_ON)
     {
      if(TARGET>0)
        {
         target=entry + TARGET;
        }
     }

   int qty = Qty;

   if(FirstTrade)
      Send(entry,"BUY",qty,"false");

   TotalTrades++;



// BuyArrow[i]=Low[i]-iATR(NULL,0,15,i)*0.5;

   DrawArrowUp("BuyArrow"+ Bars,Low[i]-iATR(NULL,0,15,i)*0.5,clrLime);

   Print("BUY AT "+Time[i]+",qty="+qty+",entry="+entry+",stop="+stop+",target="+target+",i="+i);

   RemainingQty=Qty;



  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FreshSell(int i)
  {
   if(LastTradeOpen)
     {
      Squareoff(i,Close[i]);
     }

   if(i==0)
     {
      FirstTrade=true;
     }


   LastSignal="SELL";
   LastTradeOpen=true;

   entry=0;
   stop=0;
   target=0;
   trailingEntry=0;

   entry=Close[i];

   trailingEntry=entry;

   breakeven_candle_high=High[i+1];
   breakeven_candle_low=Low[i+1];
   breakeven_candle_time=Time[i+1];

   LastEntryTime=Time[i];

   if(STOPLOSS_ON)
     {
      if(STOPLOSS>0)
        {
         stop=entry + STOPLOSS;
        }
     }
   if(TARGET_ON)
     {
      if(TARGET>0)
        {
         target=entry - TARGET;
        }
     }

   int qty = Qty;

   if(FirstTrade)
      Send(entry,"SELL",qty,"false");

   TotalTrades++;

// SellArrow[i]=High[i]+iATR(NULL,0,15,i)*0.5;
   DrawArrowDown("SellArrow"+ Bars,High[i]+iATR(NULL,0,15,i)*0.5,clrRed);

   Print("SELL AT "+Time[i]+",qty="+qty+",entry="+entry+",stop="+stop+",target="+target+",i="+i);

   RemainingQty=Qty;

// ShowAlert("SELL_ENTRY");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Squareoff(int i,const double exit=0)
  {
   if(LastTradeOpen)
     {

      LastTradeOpen=false;

      int qty = RemainingQty;

      string signal = (LastSignal=="BUY")?"SELL":"BUY";

      if(FirstTrade)
         Send(entry,signal,qty,"true");


      double pnl = (LastSignal=="BUY")?(exit-entry):(entry-exit);
      TotalPnl+=pnl;

      CPNL = pnl;

      if(pnl>=0)
         ProfitTrades++;
      else
         LossTrades++;

      Print(LastSignal+" SQUAREOFF AT "+Time[i]+",qty="+qty+",pnl="+pnl+",exit="+exit);



      if(pnl>0)
        {
         // TPArrow[i]=Open[i]+iATR(NULL,0,15,i)*0.5;
         DrawTargetArchived("TargetArchived"+ Bars,Open[i]+iATR(NULL,0,15,i)*0.5,clrYellow);

        }
      else
        {
         // SLArrow[i]=Open[i]+iATR(NULL,0,15,i)*0.5;
         DrawSL("SLAchived"+ Bars,Open[i]+iATR(NULL,0,15,i)*0.5,clrPink);

        }

      ButtonTextChange(0,"Button_B", "BUY");
      ButtonTextChange(0,"Button_S", "SELL");


      RemainingQty=0;

      string event = (LastSignal=="BUY")?"BUY_EXIT":"SELL_EXIT";
      // ShowAlert(event,exit);

      if(pnl>=0)
        {
         PossitiveTrades++;
         PossitiveT = PossitiveT + pnl;
        }
      else
        {
         NegativeTrades++;
         NegativeT = NegativeT + pnl;
        }
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Exitoff(int i,const double exit=0)
  {
   if(LastTradeOpen)
     {

      LastTradeOpen=false;

      int qty = RemainingQty;

      string signal = (LastSignal=="BUY")?"SELL":"BUY";

      double pnl = (LastSignal=="BUY")?(exit-entry):(entry-exit);
      TotalPnl+=pnl;
      CPNL = pnl;
      if(pnl>=0)
         ProfitTrades++;
      else
         LossTrades++;

      Print(LastSignal+" Exit AT "+Time[i]+",qty="+qty+",pnl="+pnl+",exit="+exit);





      if(pnl>0)
        {
         // TPArrow[i]=Open[i]+iATR(NULL,0,15,i)*0.5;
         DrawTargetArchived("TargetArchived"+ Bars,Open[i]+iATR(NULL,0,15,i)*0.5,clrYellow);

        }
      else
        {
         // SLArrow[i]=Open[i]+iATR(NULL,0,15,i)*0.5;
         DrawSL("SLAchived"+ Bars,Open[i]+iATR(NULL,0,15,i)*0.5,clrPink);

        }



      ButtonTextChange(0,"Button_B", "BUY");
      ButtonTextChange(0,"Button_S", "SELL");



      RemainingQty=0;

      string event = (LastSignal=="BUY")?"BUY_EXIT":"SELL_EXIT";
      // ShowAlert(event,exit);

      if(pnl>=0)
        {
         PossitiveTrades++;
         PossitiveT = PossitiveT + pnl;
        }
      else
        {
         NegativeTrades++;
         NegativeT = NegativeT + pnl;
        }
     }
  }

//+------------------------------------------------------------------+
void CheckTPSL(int i)
  {
   if(LastTradeOpen)
     {
      if(STOPLOSS_ON && Stoploss_Type==Breakeven)
       {
        
        int bcgap=0;
        if(BreakEvenCandle == 0)
          {
           bcgap= 1;
          } else
              {
           bcgap= BreakEvenCandle;    
              }
        
         if(LastSignal=="BUY" &&  Open[i+BreakEvenCandle] > Close[i+bcgap-1])
           {
            if(Time[i]>=breakeven_candle_time && High[i]>breakeven_candle_high)
              {
               //Print("breakeven_candle_high="+breakeven_candle_high);
               breakeven_candle_time=Time[i];
               breakeven_candle_high=High[i];

               double old_stop=stop;
               stop =breakeven_candle_high - STOPLOSS ;
               double new_stop=stop;
               // Print("BUY TRADE STOPLOSS MODIFIED AT "+Time[i]+",old_stop="+old_stop+",new_stop="+new_stop+",breakeven_candle_high="+breakeven_candle_high);
              }
           }
         else
           {
            if(Open[i+BreakEvenCandle] < Close[i+bcgap-1])
              {

               if(Time[i]>=breakeven_candle_time && Low[i]<breakeven_candle_low)
                 {
                  //Print("breakeven_candle_low="+breakeven_candle_low);
                  breakeven_candle_time=Time[i];
                  breakeven_candle_low=Low[i];

                  double old_stop=stop;
                  stop =breakeven_candle_low + STOPLOSS ;
                  double new_stop=stop;
                  // Print("SELL TRADE STOPLOSS MODIFIED AT "+Time[i]+",old_stop="+old_stop+",new_stop="+new_stop+",breakeven_candle_low="+breakeven_candle_low);
                 }
              }
           }

        }
      else
         if(STOPLOSS_ON && Stoploss_Type==Trailing_Step)
           {
            if(LastSignal=="BUY")
              {
               double current_price = Close[i];
               double current_different = current_price-trailingEntry;
               if(current_different>=(TRAILING_STEP))
                 {
                  trailingEntry=current_price;
                  double old_stop=stop;
                  stop =old_stop + TRAILING_STOP;
                  double new_stop=stop;
                  // Print("BUY TRADE STOPLOSS MODIFIED AT "+Time[i]+",old_stop="+old_stop+",new_stop="+new_stop+",current level="+trailingEntry);
                 }
              }
            else
              {
               double current_price = Close[i];
               double current_different = trailingEntry-current_price;
               if(current_different>=(TRAILING_STEP))
                 {
                  trailingEntry=current_price;
                  double old_stop=stop;
                  stop =old_stop - TRAILING_STOP;
                  double new_stop=stop;
                  // Print("SELL TRADE STOPLOSS MODIFIED AT "+Time[i]+",old_stop="+old_stop+",new_stop="+new_stop+",current level="+trailingEntry);
                 }
              }
           }


         else

           {
            if(LastSignal=="BUY")
              {

               double PvOpen=Open[i+2];
               double old_stop=stop;
               double new_stop;

               //----------------------------
               if(old_stop < Low[i+1])
                 {
                  PvOpen=stop;
                 }

               //----------------------------


               if(old_stop>PvOpen)
                 {
                  stop = old_stop;
                  new_stop=stop;
                 }
               else
                 {
                  stop = PvOpen;
                  new_stop=stop;
                 }

               Print("Modify Old SL "+old_stop +"| New SL " +new_stop);

               if(Open[i] < stop && STOPLOSS_ON ==true)
                 {

                  LastTradeOpen=false;
                  stop=Open[i];
                  int qty = RemainingQty;

                  if(FirstTrade)
                     Send(entry,"SELL",qty,"true");

                  double pnl = (LastSignal=="BUY")?(stop-entry):(entry-stop);
                  TotalPnl+=pnl;
                  CPNL = pnl;
                  if(pnl>=0)
                     ProfitTrades++;
                  else
                     LossTrades++;

                  RemainingQty=0;

                  Print("BUY SL AT "+Time[i]+",qty="+qty+",exit="+stop+",pnl="+pnl);
                  LastSignal="Closed by SL";

                  if(pnl>=5)
                    {
                     TPArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                     if(Now_Time < Time[i])
                       {
                        OneTime += 1;
                        DrawTargetArchived("TargetArchived"+ OneTime,0,clrYellow);
                       }
                     ButtonTextChange(0,"Button_B", "BUY");
                     ButtonTextChange(0,"Button_S", "SELL");
                    }
                  else
                    {
                     SLArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                     if(Now_Time < Time[i])
                       {
                        OneTime += 1;
                        DrawSL("SLAchived"+ OneTime,0,clrPink);
                       }
                     ButtonTextChange(0,"Button_B", "BUY");
                     ButtonTextChange(0,"Button_S", "SELL");

                    }


                  // ShowAlert("BUY_SL");



                  if(pnl>=0)
                    {
                     PossitiveTrades++;
                     PossitiveT = PossitiveT + pnl;
                    }
                  else
                    {
                     NegativeTrades++;
                     NegativeT = NegativeT + pnl;
                    }


                  if(CROSS_ENTRY && CR==1)
                    {
                     if(Close[i+1] < Open[i+1])
                       {

                        FreshSell(i);
                        CR=0;

                       }
                    }

                 }
              }
            else
              {

               double PvOpen=Open[i+1];
               double old_stop=stop;
               double new_stop=PvOpen;

               if(Open[i]<Close[i+1])
                 {
                  stop = Open[i+1];
                  new_stop=stop;
                  SR=SR+1;
                 }

               if(old_stop < new_stop && old_stop != new_stop)
                 {

                  stop = old_stop;
                  new_stop=stop;

                 }




               if(old_stop == new_stop && SR!=1)
                 {
                  if(Open[i+1]<Close[i+1] && STOPLOSS_ON ==true)
                    {
                     LastTradeOpen=false;
                     stop=Open[i];
                     int qty = RemainingQty;

                     if(FirstTrade)
                        Send(entry,"BUY",qty,"true");

                     double pnl = (LastSignal=="BUY")?(stop-entry):(entry-stop);
                     TotalPnl+=pnl;
                     CPNL = pnl;
                     if(pnl>=0)
                        ProfitTrades++;
                     else
                        LossTrades++;

                     RemainingQty=0;

                     Print("SELL SL AT "+Time[i]+",qty="+qty+",exit="+stop+",pnl="+pnl);
                     LastSignal="Closed by SL";

                     if(pnl>=5)
                       {
                        TPArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                        if(Now_Time < Time[i])
                          {
                           OneTime += 1;
                           DrawTargetArchived("TargetArchived"+ OneTime,0,clrYellow);
                          }
                        ButtonTextChange(0,"Button_B", "BUY");
                        ButtonTextChange(0,"Button_S", "SELL");

                       }
                     else
                       {
                        SLArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                        if(Now_Time < Time[i])
                          {
                           OneTime += 1;
                           DrawSL("SLAchived"+ OneTime,0,clrPink);
                          }
                        ButtonTextChange(0,"Button_B", "BUY");
                        ButtonTextChange(0,"Button_S", "SELL");


                       }


                     // ShowAlert("SELL_SL");


                     if(pnl>=0)
                       {
                        PossitiveTrades++;
                        PossitiveT = PossitiveT + pnl;
                       }
                     else
                       {
                        NegativeTrades++;
                        NegativeT = NegativeT + pnl;
                       }

                     if(CROSS_ENTRY && CR==1)
                       {
                        if(Close[i+1] > Open[i+1])
                          {
                           FreshBuy(i);
                           CR=0;
                          }

                       }
                    }
                 }


               // Print("Modify Old SL "+old_stop +"| New SL " +new_stop ); //+"SR "+SR


              }

           }



      if(LastSignal=="BUY")
        {


         if(Close[i]>=target && target>0 && TARGET_ON ==true)
           {

            // Print("Profit Book LTP "+Close[i]);
            if(Close[i]>Open[i+2])
              {

               target = target + 50;

              }
            else
              {


               LastTradeOpen=false;

               int qty = RemainingQty;

               if(FirstTrade)
                  Send(entry,"SELL",qty,"true");

               double pnl = (LastSignal=="BUY")?(target-entry):(entry-target);
               TotalPnl+=pnl;
               CPNL = pnl;

               if(pnl>=0)
                  ProfitTrades++;
               else
                  LossTrades++;


               RemainingQty=0;

               Print("BUY TP AT "+Time[i+1]+",qty="+qty+",exit="+target+",pnl="+pnl);

               TPArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
               if(Now_Time < Time[i])
                 {
                  OneTime += 1;
                  DrawTargetArchived("TargetArchived"+ OneTime,0,clrYellow);
                 }
               ButtonTextChange(0,"Button_B", "BUY");
               ButtonTextChange(0,"Button_S", "SELL");

               // ShowAlert("BUY_TP");


               if(pnl>=0)
                 {
                  PossitiveTrades++;
                  PossitiveT = PossitiveT + pnl;
                 }
               else
                 {
                  NegativeTrades++;
                  NegativeT = NegativeT + pnl;
                 }

              }


           }
         else
            if(Close[i] < Open[i] && High[i]<=stop && stop>0 && STOPLOSS_ON ==true)
              {
               LastTradeOpen=false;
               stop=Close[i];
               int qty = RemainingQty;

               if(FirstTrade)
                  Send(entry,"SELL",qty,"true");

               double pnl = (LastSignal=="BUY")?(stop-entry):(entry-stop);
               TotalPnl+=pnl;
               CPNL = pnl;
               if(pnl>=0)
                  ProfitTrades++;
               else
                  LossTrades++;

               RemainingQty=0;

               Print("BUY SL AT "+Time[i]+",qty="+qty+",exit="+stop+",pnl="+pnl);

               if(pnl>=5)
                 {
                  TPArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                  if(Now_Time < Time[i])
                    {
                     OneTime += 1;
                     DrawTargetArchived("TargetArchived"+ OneTime,0,clrYellow);
                    }
                  ButtonTextChange(0,"Button_B", "BUY");
                  ButtonTextChange(0,"Button_S", "SELL");

                 }
               else
                 {
                  SLArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                  if(Now_Time < Time[i])
                    {
                     OneTime += 1;
                     DrawSL("SLAchived"+ OneTime,0,clrPink);
                    }
                  ButtonTextChange(0,"Button_B", "BUY");
                  ButtonTextChange(0,"Button_S", "SELL");

                 }


               // ShowAlert("BUY_SL");



               if(pnl>=0)
                 {
                  PossitiveTrades++;
                  PossitiveT = PossitiveT + pnl;
                 }
               else
                 {
                  NegativeTrades++;
                  NegativeT = NegativeT + pnl;
                 }


               if(CROSS_ENTRY && CR==1)
                 {
                  if(Close[i+1] < Open[i+1])
                    {

                     FreshSell(i);
                     CR=0;

                    }
                 }


              }



        }
      else
         if(LastSignal=="SELL" && TARGET_ON ==true)
           {

            // Print("Profit Book LTP "+Close[i]);
            if(Close[i]<Open[i+2])
              {

               target = target - 40;

              }
            else
              {

               if(Close[i]<=target && target>0)
                 {
                  LastTradeOpen=false;

                  int qty = RemainingQty;

                  if(FirstTrade)
                     Send(entry,"BUY",qty,"true");

                  double pnl = (LastSignal=="BUY")?(target-entry):(entry-target);
                  TotalPnl+=pnl;
                  CPNL = pnl;
                  if(pnl>=0)
                     ProfitTrades++;
                  else
                     LossTrades++;

                  RemainingQty=0;

                  Print("SELL TP AT "+Time[i+1]+",qty="+qty+",exit="+target+",pnl="+pnl);

                  TPArrow[i]=Close[i]-iATR(NULL,0,15,i)*0.5;
                  if(Now_Time < Time[i])
                    {
                     OneTime += 1;
                     DrawTargetArchived("TargetArchived"+ OneTime,0,clrYellow);
                    }

                  ButtonTextChange(0,"Button_B", "BUY");
                  ButtonTextChange(0,"Button_S", "SELL");

                  // ShowAlert("SELL_TP");



                  if(pnl>=0)
                    {
                     PossitiveTrades++;
                     PossitiveT = PossitiveT + pnl;
                    }
                  else
                    {
                     NegativeTrades++;
                     NegativeT = NegativeT + pnl;
                    }

                 }
               else
                  if(Close[i] > Open[i] && Low[i]>=stop && stop>0 && STOPLOSS_ON ==true)
                    {
                     LastTradeOpen=false;
                     stop=Close[i];
                     int qty = RemainingQty;

                     if(FirstTrade)
                        Send(entry,"BUY",qty,"true");

                     double pnl = (LastSignal=="BUY")?(stop-entry):(entry-stop);
                     TotalPnl+=pnl;
                     CPNL = pnl;
                     if(pnl>=0)
                        ProfitTrades++;
                     else
                        LossTrades++;

                     RemainingQty=0;

                     Print("SELL SL AT "+Time[i]+",qty="+qty+",exit="+stop+",pnl="+pnl);


                     if(pnl>=5)
                       {
                        TPArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                        if(Now_Time < Time[i])
                          {
                           OneTime += 1;
                           DrawTargetArchived("TargetArchived"+ OneTime,0,clrYellow);
                          }

                        ButtonTextChange(0,"Button_B", "BUY");
                        ButtonTextChange(0,"Button_S", "SELL");
                       }
                     else
                       {
                        SLArrow[i]=Close[i]+iATR(NULL,0,15,i)*0.5;
                        if(Now_Time < Time[i])
                          {
                           OneTime += 1;
                           DrawSL("SLAchived"+ OneTime,0,clrPink);
                          }
                        ButtonTextChange(0,"Button_B", "BUY");
                        ButtonTextChange(0,"Button_S", "SELL");

                       }


                     // ShowAlert("SELL_SL");


                     if(pnl>=0)
                       {
                        PossitiveTrades++;
                        PossitiveT = PossitiveT + pnl;
                       }
                     else
                       {
                        NegativeTrades++;
                        NegativeT = NegativeT + pnl;
                       }

                     if(CROSS_ENTRY && CR==1)
                       {
                        if(Close[i+1] > Open[i+1])
                          {
                           FreshBuy(i);
                           CR=0;
                          }
                       }
                    }
              }
           }
     }
  }


//+------------------------------------------------------------------+
datetime Times(int i,int limit)
  {
   datetime result;

   if(limit>0)
     {
      result = Time[i];
     }
   else
     {
      result=TimeCurrent();
     }

   return result;
  }
//+------------------------------------------------------------------+
void Dashboard()
  {
   CreateText("SignalKey",15,30,"SIGNAL",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("SignalValue",100,30," :     "+LastSignal,8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("EntryKey",15,45,"ENTRY",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("EntryValue",100,45," :     "+DoubleToString(entry,_Digits),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("StopKey",15,60,"STOP",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("StopValue",100,60," :     "+DoubleToString(stop,_Digits),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("TargetKey",15,75,"TARGET",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("TargetValue",100,75," :     "+DoubleToString(target,_Digits),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("StatusKey",15,90,"STATUS",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("StatusValue",100,90," :     "+((LastTradeOpen)?"OPEN":"CLOSE"),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("QtyKey",15,105,"REMAIN QTY",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("QtyValue",100,105," :     "+RemainingQty,8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("TotalTradesKey",15,120,"TOTAL TRADES",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("TotalTradesValue",100,120," :     "+TotalTrades,8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("TotalPnlKey",15,135,"TOTAL PNL",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("TotalPnlValue",100,135," :     "+DoubleToString(TotalPnl,2),8,(TotalPnl>=0)?clrLime:clrRed,"Arial Bold",CORNER_LEFT_UPPER);

   double  Accuracy=0;

   if(ProfitTrades>0 && TotalTrades>0)
      Accuracy = TotalPnl/TotalTrades;

//CreateText("AccuracyKey",15,270,"ACCURACY",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
//CreateText("AccuracyValue",100,270," :     "+DoubleToString(Accuracy,2)+" %",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("PossitiveKey",15,150,"+Ve",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("PossitiveValue",100,150," :     "+PossitiveTrades +" | "+ PossitiveT,8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);


   CreateText("NegativeKey",15,165,"-Ve",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("NegativeValue",100,165," :     "+NegativeTrades +" | "+ NegativeT,8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);


   double  Percent=0;

   if(PossitiveT>0 && (NegativeT*-1)>0)
      Percent = PossitiveT * 100 / ((NegativeT * -1)+ PossitiveT);

   CreateText("PercentKey",15,180,"PROFIT",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("PercentValue",100,180," :   "+DoubleToString(Accuracy,0) + "P | " + DoubleToString(Percent,2)+ " %",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("PNLKey",15,205,"C PNL",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("PnlValue",100,205," :   "+DoubleToString(CPNL,0) + "P",8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);


   CreateText("BullishLevel",15,230,"Bullish Level",8,clrLime,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("BlEntryValue",100,230," :     "+DoubleToString(BullLevel,_Digits),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);

   CreateText("BearishLevel",15,255,"Bearish Level",8,clrRed,"Arial Bold",CORNER_LEFT_UPPER);
   CreateText("BrEntryValue",100,255," :     "+DoubleToString(BearLevel,_Digits),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);


// CreateText("B1EntryValue",100,270," :     "+DoubleToString(BOneTime,_Digits),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);
// CreateText("B2EntryValue",100,290," :     "+DoubleToString(SOneTime,_Digits),8,clrWhite,"Arial Bold",CORNER_LEFT_UPPER);



   ObjectCreate(0,"BlLevel",OBJ_HLINE,0,TimeCurrent(), BullLevel);
   ObjectSet("BlLevel",OBJPROP_COLOR,Blue);
   ObjectSet("BlLevel",OBJPROP_WIDTH,1);
   ObjectSet("BlLevel",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("BlLevel",OBJPROP_SELECTABLE,false);
   ObjectSet("BlLevel",OBJPROP_HIDDEN,true);
   ObjectSet("BlLevel",OBJPROP_BACK,true);

   ObjectCreate(0,"BrLevel",OBJ_HLINE,0,TimeCurrent(),BearLevel);
   ObjectSet("BrLevel",OBJPROP_COLOR,Red);
   ObjectSet("BrLevel",OBJPROP_WIDTH,1);
   ObjectSet("BrLevel",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("BrLevel",OBJPROP_SELECTABLE,false);
   ObjectSet("BrLevel",OBJPROP_HIDDEN,true);
   ObjectSet("BrLevel",OBJPROP_BACK,true);

//   string test="TotalTrades="+TotalTrades;
//   test+="\n ProfitTrades="+ProfitTrades;
//   test+="\n LossTrades="+LossTrades;
//   Comment(test);

if(PrevDayHL_LineVisible)
  {
   ObjectCreate(0,"PrevDayHigh",OBJ_HLINE,0,TimeCurrent(),iHigh(Symbol(),1440,1));
   ObjectSet("PrevDayHigh",OBJPROP_COLOR,Blue);
   ObjectSet("PrevDayHigh",OBJPROP_WIDTH,1);
   ObjectSet("PrevDayHigh",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("PrevDayHigh",OBJPROP_SELECTABLE,false);
   ObjectSet("PrevDayHigh",OBJPROP_HIDDEN,true);
   ObjectSet("PrevDayHigh",OBJPROP_BACK,true);

   ObjectCreate(0,"PrevDayLow",OBJ_HLINE,0,TimeCurrent(),iLow(Symbol(),1440,1));
   ObjectSet("PrevDayLow",OBJPROP_COLOR,Red);
   ObjectSet("PrevDayLow",OBJPROP_WIDTH,1);
   ObjectSet("PrevDayLow",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("PrevDayLow",OBJPROP_SELECTABLE,false);
   ObjectSet("PrevDayLow",OBJPROP_HIDDEN,true);
   ObjectSet("PrevDayLow",OBJPROP_BACK,true);
  }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateText(string name,int x,int y,string text,int fontsize,color clr,string font,int corner)
  {
   name=ObjName+"OBJ_LABEL"+name;

   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
//--- set label coordinates
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(0,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(0,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
//--- set color
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void delObj(string name)
  {
   int i;
   int totalObj=ObjectsTotal();
   for(i=totalObj-1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),name,0)>=0)
         ObjectDelete(ObjectName(i));
     }
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
   delObj(ObjName);
   ResetVariables();
   FirstTick=true;
  }
//+------------------------------------------------------------------+
void ResetVariables()
  {
   ArrayInitialize(BuyArrow,EMPTY_VALUE);
   ArrayInitialize(SellArrow,EMPTY_VALUE);
   ArrayInitialize(TPArrow,EMPTY_VALUE);
   ArrayInitialize(SLArrow,EMPTY_VALUE);
   ArrayInitialize(ENDArrow,EMPTY_VALUE);

   ArrayInitialize(RsiMa,EMPTY_VALUE);
   ArrayInitialize(TrendSlow,EMPTY_VALUE);
   ArrayInitialize(TrendFast,EMPTY_VALUE);
   ArrayInitialize(trend,EMPTY_VALUE);

   ArrayInitialize(cross_signal,EMPTY_VALUE);

   LastSignal="WAITING";
   LastTradeOpen=false;
   entry=0;
   stop=0;
   target=0;
   RemainingQty=0;
   LastEntryTime=0;
   trailingEntry=0;

   breakeven_candle_high=0;
   breakeven_candle_low=0;
   breakeven_candle_time=0;

   FirstTrade=false;

   market_start=0;
   market_close=0;
   new_day=0;

   TotalTrades=0;
   ProfitTrades=0;
   LossTrades=0;
   TotalPnl=0;

  }
//+------------------------------------------------------------------+
void Send(double Price,string transactionType,int qty,string square)
  {


  }
//+------------------------------------------------------------------+
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tf==iTfTable[i])
         return(sTfTable[i]);
   return("");
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setLabel(string name, string text, color col, int corner,
              int x, int y, bool back = false, int fontsize = 9,
              string fontname = "MS Sans Serif")
  {
   if(ObjectFind(name)==-1)
     {

      ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(name, text, fontsize, fontname, col);
      ObjectSet(name, OBJPROP_CORNER, corner);
      ObjectSet(name, OBJPROP_BACK,back);
      ObjectSet(name, OBJPROP_XDISTANCE, x);
      ObjectSet(name, OBJPROP_YDISTANCE, y);
     }
   else
     {
      ObjectSetText(name, text, fontsize, fontname, col);
      ObjectSet(name, OBJPROP_CORNER, corner);
      ObjectSet(name, OBJPROP_BACK,back);
      ObjectSet(name, OBJPROP_XDISTANCE, x);
      ObjectSet(name, OBJPROP_YDISTANCE, y);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
