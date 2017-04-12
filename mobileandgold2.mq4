//+------------------------------------------------------------------+
//|                                               mobileandgold2.mq4 |
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
input int Signal_Margin = 8;
input int ATR_Period = 14;

const string arrowIndName = "0033_ArrowReal2";
const string markIndName = "0011_High&BottomMark2";

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

int getArrow() {

  double direction = 0;
  for(int i = 0; i < 2; i++) {
    direction += iCustom(NULL, PERIOD_CURRENT, arrowIndName, 3, i);
  }
  
  if(0 < direction) {
    return OP_BUY;
  }
  else if(direction < 0){
    return OP_SELL;
  }
  else {
    return -1;
  }
}

int getMark() {

  double buy = 0.0;
  for(int i = 0; i < Signal_Margin; i++) {
    buy += iCustom(NULL, PERIOD_CURRENT, markIndName, 0, i + 1);
  }

  double sell = 0.0;
  for(int i = 0; i < Signal_Margin; i++) {
    sell += iCustom(NULL, PERIOD_CURRENT, markIndName, 1, i + 1);
  }

  if(0.0 < buy && 0.0 < sell) {
    return -1;
  }
  else if(0.0 < buy) {
    return OP_BUY;
  }
  else if(0.0 < sell) {
    return OP_SELL;
  }
  else {
    return -1;
  }
}



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  int mark = getMark();
  int arrow = getArrow();
  
  int signal = -1;
  if(mark == OP_BUY && arrow == OP_BUY) {
    signal = OP_BUY;
  }
  else if(mark == OP_SELL && arrow == OP_SELL) {
    signal = OP_SELL;
  }
  
  for(int i = 0; i < OrdersTotal(); i++) {
    if(OrderSelect(i, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol) && Magic_Number == OrderMagicNumber()) {
        if(OrderType() == OP_BUY && signal == OP_SELL) {
          if(OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 3)) {
            i = -1;
          }
        }
        else if(OrderType() == OP_SELL && signal == OP_BUY) {
          if(OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 3)) {
            i = -1;
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
  
  if(signal == OP_BUY) {
    int ordered = OrderSend(thisSymbol, OP_BUY, Entry_Lot, NormalizeDouble(Ask, Digits), 3, NormalizeDouble(Ask - atr, Digits), NormalizeDouble(Ask + atr, Digits), NULL, Magic_Number);
  }
  else if(signal == OP_SELL) {
    int ordered = OrderSend(thisSymbol, OP_SELL, Entry_Lot, NormalizeDouble(Bid, Digits), 3, NormalizeDouble(Bid + atr, Digits), NormalizeDouble(Bid - atr, Digits), NULL, Magic_Number);
  }
}
//+------------------------------------------------------------------+
