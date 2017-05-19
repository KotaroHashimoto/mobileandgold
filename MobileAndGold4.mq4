//+------------------------------------------------------------------+
//|                                               MobileAndGold4.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict

input int Magic_Number = 1;
input double Entry_Lot = 0.1;
input double Stop_Loss = 20;
input double Take_Profit = 20;
input int Dragon_Range = 3;

double sl;
double tp;
string thisSymbol;


int getOrdersTotal() {

  int count = 0;
  if(0 < OrdersTotal()) {  
    if(OrderSelect(0, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol) && OrderMagicNumber() == Magic_Number) {
        count ++;
      }
    }
  }

  return count;
}


int getSupportSignal() {

  if(0 < iCustom(NULL, PERIOD_CURRENT, "SupportResistance", 6, 1)) {
    return OP_BUY;
  }
  else if(0 < iCustom(NULL, PERIOD_CURRENT, "SupportResistance", 7, 1)) {
    return OP_SELL;
  }

  return -1;
}


int getDragonSignal() {

  for(int i = 1; i < Dragon_Range + 1; i++) {
    if(0 < iCustom(NULL, PERIOD_CURRENT, "DragonArrows", 2, i)) {
      return OP_BUY;
    }
    else if(0 < iCustom(NULL, PERIOD_CURRENT, "DragonArrows", 3, i)) {
      return OP_SELL;
    }
  }

  return -1;
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

  sl = Stop_Loss * 10.0 * Point;
  tp = Take_Profit * 10.0 * Point;
  thisSymbol = Symbol();
   
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
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  int dragon = getDragonSignal();
  int support = getSupportSignal();

  if(0 < getOrdersTotal()) {  
    if(OrderSelect(0, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol) && OrderMagicNumber() == Magic_Number) {
        if((dragon == OP_SELL && support == OP_SELL) && OrderType() == OP_BUY) {
          bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0);
        }
        else if((dragon == OP_BUY && support == OP_BUY) && OrderType() == OP_SELL) {
          bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0);
        }
      }
    }  
  }
  else {
    if(dragon == OP_BUY && support == OP_BUY) {
      int ticket = OrderSend(Symbol(), OP_BUY, Entry_Lot, NormalizeDouble(Ask, Digits), 0, NormalizeDouble(Ask - sl, Digits), NormalizeDouble(Ask + tp, Digits), NULL, Magic_Number);
    }
    else if(dragon == OP_SELL && support == OP_SELL) {
      int ticket = OrderSend(Symbol(), OP_SELL, Entry_Lot, NormalizeDouble(Bid, Digits), 0, NormalizeDouble(Bid + sl, Digits), NormalizeDouble(Bid - tp, Digits), NULL, Magic_Number);
    }
  }
}
//+------------------------------------------------------------------+
