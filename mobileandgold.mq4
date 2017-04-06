//+------------------------------------------------------------------+
//|                                                mobileandgold.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict

input double Entry_Lot = 0.1;
input int Magic_Number = 1;
input int ATR_Period = 14;

const string indName = "SSS_Signal";

string thisSymbol;
double minLot;
double maxLot;
double minSL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  thisSymbol = Symbol();

  minLot = MarketInfo(Symbol(), MODE_MINLOT);
  maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
  minSL = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }


double getSignalValue() {
  
  double s0 = iCustom(NULL, PERIOD_CURRENT, indName, 0, 1);
  double s1 = iCustom(NULL, PERIOD_CURRENT, indName, 1, 1);
  double s2 = iCustom(NULL, PERIOD_CURRENT, indName, 2, 1);
  double s3 = iCustom(NULL, PERIOD_CURRENT, indName, 3, 1);
  
  return s0 + s1 + s2 + s3;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  double signalValue = getSignalValue();
    
  for(int i = 0; i < OrdersTotal(); i++) {
    if(OrderSelect(i, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol) && Magic_Number == OrderMagicNumber()) {
        if(OrderType() == OP_BUY) {
          if(40.0 < signalValue) {
            if(OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 3)) {
              i = -1;
            }
          }
        }
        else if(OrderType() == OP_SELL) {
          if(signalValue < -40.0) {
            if(OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 3)) {
              i = -1;
            }
          }
        }

        return;
      }
    }
  }


  if(Entry_Lot < minLot || maxLot < Entry_Lot) {
    Print("lot size invalid, min = ", minLot, ", max = ", maxLot);
    return;
  }
  
  double atr = iATR(Symbol(), PERIOD_CURRENT, ATR_Period, 1);
  
  if(atr < minSL) {
    Print("SL/TP is too close to entry price. Increase timeframe.");
    return;
  }

  if(signalValue == -360.0) {
    int ordered = OrderSend(thisSymbol, OP_BUY, Entry_Lot, NormalizeDouble(Ask, Digits), 3, NormalizeDouble(Ask - atr, Digits), NormalizeDouble(Ask + atr, Digits), NULL, Magic_Number);
  }
  else if(signalValue == 360.0) {
    int ordered = OrderSend(thisSymbol, OP_SELL, Entry_Lot, NormalizeDouble(Bid, Digits), 3, NormalizeDouble(Bid + atr, Digits), NormalizeDouble(Bid - atr, Digits), NULL, Magic_Number);
  }
}
//+------------------------------------------------------------------+
