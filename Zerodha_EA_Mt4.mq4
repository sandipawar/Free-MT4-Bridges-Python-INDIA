 //+------------------------------------------------------------------+
//|                           Ohenba Narkwa EA Final Version  B1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+

//+Copyright = "SR BuySell Trading | Appsportal.in";
//+Notice = "Developed By Sandip R. Pawar @ Mobile no. 9423950322 ";

//| Expert initialization function                                   |
//+------------------------------------------------------------------+ 
#include <Zmq/Zmq.mqh>


#define within(num) (int) ((float) num * MathRand() / (32767 + 1.0))
string  start_toDay  =   "00:00";
input  string  SYMBOL_NAME_ONE    =  "BANKNIFTY";
extern   int  Server_Connect_MS   =  600;
string capture_recent_time  =  0;
 
extern  string quantity    = 1;
extern    string   priceType    =   "MARKET" ;

extern    string   exchange   =  "NFO"  ;

extern    string   expiry   =  "23APR"  ;

input bool Trading=false;//API Trading On/Off

string   signal_mapping     =   "NONE";

  int OnInit()
  {
 
   string output1[];
   string  default_spliter1    =  "BANKNIFTY";
   StringSplit(SYMBOL_NAME_ONE, StringGetCharacter(default_spliter1, 0),output1);
 
   string   output2[  ]   ;
   string  default_spliter2    =  "NIFTY";
   StringSplit(SYMBOL_NAME_ONE, StringGetCharacter(default_spliter2, 0),output2);
  
   capture_recent_time   =   Time[1];
 
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   return(INIT_SUCCEEDED);
  }
  void OnDeinit(const int reason)
  {
 
  }
 
void OnTick()
  {
 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
// For the first situation I know a new arrow is created for a signal
// Only react on new arrow

// Only on object_create
   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      
      NewObject(sparam);
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  NewObject(string name)
  {
 

 
   if(StringSubstr(name, 0, StringLen("BuyArrow"))=="BuyArrow")
     {
      // Alert("BuyArrow Pressed");
    
      signal_mapping = "BUY";
      fx_signal_type("BUY");
      
      //Alert ("BUY" + signal_mapping);
      
     }


if(StringSubstr(name, 0, StringLen("SellArrow"))=="SellArrow")
     {
      //Alert("SellArrow Pressed");
      signal_mapping = "SELL";
      fx_signal_type("SELL");
      
     }

if(StringSubstr(name, 0, StringLen("TargetArchived"))=="TargetArchived")
     {
      // Alert("Target Archived");
      // Alert(signal_mapping );
      
      if(signal_mapping=="BUY")
        {
          fx_signal_type("SELL");
        } else
            {
              fx_signal_type("BUY");
            }
        
        
      
     }
     

if(StringSubstr(name, 0, StringLen("SLAchived"))=="SLAchived")
     {
      // Alert("SL Hits");
      // Alert(signal_mapping );
      
      if(signal_mapping=="BUY")
        {
          fx_signal_type("SELL");
        } else
            {
              fx_signal_type("BUY");
            }
     }
      

  }
//+------------------------------------------------------------------+

string   fx_signal_type(string signal_type)
  {
  
  if(Trading)
    {
       
   Context context;
   Socket publisher(context,ZMQ_PUB);
   publisher.bind("tcp://*:5556");
   int counter  =   0;
   long messages_sent=0;
//--- Initialize random number generator
   MathSrand(GetTickCount());
   Sleep(Server_Connect_MS);
   int zipcode;
   zipcode=within(30000);
   string sendData =   fx_hour_mapping(SYMBOL_NAME_ONE,     signal_type)+"ENDOF"  ;

///---
//  + fx_hour_mapping(SYMBOL_NAME_SIXTEEN)+ "__" + fx_hour_mapping(SYMBOL_NAME_SEVENTEEN)+ "__" + fx_hour_mapping(SYMBOL_NAME_EIHTEEN)+ "__"  + fx_hour_mapping(SYMBOL_NAME_NINETEEN)+ "__" + fx_hour_mapping(SYMBOL_NAME_TWENTY)+ "__" + fx_hour_mapping(SYMBOL_NAME_TWENTYONE)+ "__" + fx_hour_mapping(SYMBOL_NAME_TWENTYTWO)+ "__" + fx_hour_mapping(SYMBOL_NAME_TWENTTHREE)+ "__" + fx_hour_mapping(SYMBOL_NAME_TWENTFOUR)+ "__" + fx_hour_mapping(SYMBOL_NAME_TWENTFIVE)+ "__"

   ZmqMsg message(StringFormat("%5d %s",zipcode,sendData));
   publisher.send(message);
   // Alert(fx_ltp_mapping(SYMBOL_NAME_ONE));
   
   }
   
   
   return   "" ;
   
 
   
  }
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  fx_hour_mapping(string SYMBOL_MAPPING,   string   signal_type)
  {
   long   time_maping    =    Time[0];
   
   return      time_maping   +  "@" +   fx_ltp_mapping(SYMBOL_NAME_ONE)  + "@"  + signal_type  +   "@"  +  quantity   +   "@"  +  exchange     + "@"  +    priceType ;
   
  }
 
string fx_ltp_mapping(string SYMBOL_NAME_ONE)
  {
  
   if(exchange == "NFO")
     {

      string output1[];
      string  default_spliter1    =  "BANKNIFTY";
      StringSplit(SYMBOL_NAME_ONE, StringGetCharacter(default_spliter1, 0),output1);
      // Alert   (   ArraySize(output)  );


      string   output2[  ]   ;
      string  default_spliter2    =  "NIFTY";
      StringSplit(SYMBOL_NAME_ONE, StringGetCharacter(default_spliter2, 0),output2);
      // Alert   (   ArraySize(output)  );

     
      if(signal_mapping =="BUY")
        {
        if(ArraySize(output1)   ==     2)
          {
          return SYMBOL_NAME_ONE + expiry + closestMultiple(Ask, 100) + "CE";
           
          }else
             {
              return SYMBOL_NAME_ONE + expiry +  closestMultiple(Ask, 50) + "CE";
             }
        }
      
      if(signal_mapping =="SELL")
        {
        if(ArraySize(output1)   ==     2)
          {
          return SYMBOL_NAME_ONE + expiry  +  closestMultiple(Ask, 100) + "PE";
           
          }else
             {
              return SYMBOL_NAME_ONE + expiry  +  closestMultiple(Ask, 50) + "PE" ;
             }

        }
         
     }

   else
     {

      return    SYMBOL_NAME_ONE   ;
     }
 
   return   "";
  }
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int closestMultiple(int n, int x)
  {
   if(x>n)
      return x;

   n = n + x/2;
   n = n - (n%x);
   return n;
  }
