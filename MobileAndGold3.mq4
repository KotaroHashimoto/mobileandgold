//+------------------------------------------------------------------+
//|                                               MobileAndGold3.mq4 |
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
input int Stop_Loss = 20;
input int Take_Profit = 20;

double sl;
double tp;
string thisSymbol;

int iregPos;

int getSupportSignal() {

  if(0 < iCustom(NULL, PERIOD_CURRENT, "SupportResistance", 6, 1)) {
    return OP_BUY;
  }
  else if(0 < iCustom(NULL, PERIOD_CURRENT, "SupportResistance", 7, 1)) {
    return OP_SELL;
  }

  return -1;
}

int getiRegrPos() {

  double upper = iCustom(NULL, PERIOD_CURRENT, "i-Regr", 1, 0);
  double buttom = iCustom(NULL, PERIOD_CURRENT, "i-Regr", 2, 0);
  double price = (Ask + Bid) / 2.0;

  if(upper < price) {
    return 1;
  }
  else if(buttom < price) {
    return 0;
  }
  else {
    return -1;
  }
}

int getExitSignal() {

  int currentPos = getiRegrPos();
  
  if(currentPos == -1 && iregPos == 0) {
    iregPos = currentPos;
    return OP_BUY;
  }
  if(currentPos == 1 && iregPos == 0) {
    iregPos = currentPos;
    return OP_SELL;
  }
  
  iregPos = currentPos;
  return -1;
}

int getiRegrSignal() {

  int currentPos = getiRegrPos();
  
  if(currentPos == 0) {
    if(iregPos == 1) {
      iregPos = currentPos;
      return OP_SELL;
    }
    else if(iregPos == -1) {
      iregPos = currentPos;
      return OP_BUY;
    }
  }

  iregPos = currentPos;  
  return -1;
}

int getDragonSignal() {

  if(0 < iCustom(NULL, PERIOD_CURRENT, "DragonArrows", 2, 1)) {
    return OP_BUY;
  }
  else if(0 < iCustom(NULL, PERIOD_CURRENT, "DragonArrows", 3, 1)) {
    return OP_SELL;
  }

  return -1;
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

  iregPos = getiRegrPos();
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

  if(0 < OrdersTotal()) {
  
    int irg = getExitSignal();
  
    if(OrderSelect(0, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol) && OrderMagicNumber() == Magic_Number) {
        if(((dragon == OP_SELL && support == OP_SELL) || irg == OP_SELL) && OrderType() == OP_BUY) {
          bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0);
        }
        else if(((dragon == OP_BUY && support == OP_BUY) || irg == OP_BUY) && OrderType() == OP_SELL) {
          bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0);
        }
      }
    }  
  }
  else {
  
    int irg = getiRegrSignal();
  
    if((dragon == OP_BUY && support == OP_BUY) || irg == OP_BUY) {
      int ticket = OrderSend(Symbol(), OP_BUY, Entry_Lot, NormalizeDouble(Ask, Digits), 0, NormalizeDouble(Ask - sl, Digits), NormalizeDouble(Ask + tp, Digits), NULL, Magic_Number);
    }
    else if((dragon == OP_SELL && support == OP_SELL) || irg == OP_SELL) {
      int ticket = OrderSend(Symbol(), OP_SELL, Entry_Lot, NormalizeDouble(Bid, Digits), 0, NormalizeDouble(Bid + sl, Digits), NormalizeDouble(Bid - tp, Digits), NULL, Magic_Number);
    }
  }
}
//+------------------------------------------------------------------+
