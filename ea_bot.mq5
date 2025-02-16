//+------------------------------------------------------------------+
//| Expert Advisor untuk XAUUSD M15 - MA53 & MA82 dengan Konsolidasi |
//+------------------------------------------------------------------+
#property strict

input int maFastPeriod = 53;
input int maSlowPeriod = 82;
input int maConfirmPeriod = 35;
input ENUM_MA_METHOD maMethod = MODE_SMA;
input ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE;
input double adxThreshold = 25.0;
input double rsiOverbought = 70.0;
input double rsiOversold = 30.0;
input int rsiPeriod = 14;
input int adxPeriod = 14;
input double riskPercent = 2.0;
input double atrMultiplier = 2.0;
input int consolidationBars = 3;
input int timeFilterStart = 9;
input int timeFilterEnd = 21;
input bool useMultiTimeframe = true;
input ENUM_TIMEFRAMES higherTimeframe = PERIOD_H1;
input bool useTrailingStop = true;
input double trailingStopPips = 50;
input bool useNewsFilter = true;
input bool usePartialClose = true;
input double partialClosePercentage = 50.0;

//+------------------------------------------------------------------+
//| Fungsi untuk mendapatkan lot berdasarkan equity                 |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double riskAmount = AccountBalance() * (riskPercent / 100);
    double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
    double stopLoss = iATR(Symbol(), PERIOD_M15, 14, 0) * atrMultiplier;
    return NormalizeDouble(riskAmount / stopLoss / tickValue, 2);
}

//+------------------------------------------------------------------+
//| Fungsi untuk cek breakout & konsolidasi                         |
//+------------------------------------------------------------------+
bool CheckBreakoutAndConsolidation(bool isBuy)
{
    double maFastPrev = iMA(Symbol(), PERIOD_M15, maFastPeriod, 0, maMethod, appliedPrice, 1);
    double maSlowPrev = iMA(Symbol(), PERIOD_M15, maSlowPeriod, 0, maMethod, appliedPrice, 1);
    double maConfirmPrev = iMA(Symbol(), PERIOD_M15, maConfirmPeriod, 0, maMethod, appliedPrice, 1);
    double pricePrev = iClose(Symbol(), PERIOD_M15, 1);
    
    bool breakout = (isBuy && pricePrev > maFastPrev && pricePrev > maSlowPrev && pricePrev > maConfirmPrev) ||
                    (!isBuy && pricePrev < maFastPrev && pricePrev < maSlowPrev && pricePrev < maConfirmPrev);
    
    if (!breakout) return false;
    
    double highMax = -1, lowMin = 999999;
    for (int i = 1; i <= consolidationBars; i++) {
        double high = iHigh(Symbol(), PERIOD_M15, i);
        double low = iLow(Symbol(), PERIOD_M15, i);
        if (high > highMax) highMax = high;
        if (low < lowMin) lowMin = low;
    }
    
    double range = highMax - lowMin;
    double atr = iATR(Symbol(), PERIOD_M15, 14, 0);
    
    return range < (atr * 0.5);
}

//+------------------------------------------------------------------+
//| Fungsi untuk eksekusi trading                                   |
//+------------------------------------------------------------------+
void ExecuteTrade()
{
    bool isBuy = CheckBreakoutAndConsolidation(true);
    bool isSell = CheckBreakoutAndConsolidation(false);
    if (!isBuy && !isSell) return;
    if (!CheckIndicators(isBuy)) return;
    if (useMultiTimeframe && CheckBreakoutAndConsolidation(isBuy) != CheckBreakoutAndConsolidation(isBuy, higherTimeframe)) return;
    if (Hour() < timeFilterStart || Hour() > timeFilterEnd) return;
    if (useNewsFilter && NewsEventDetected()) return;

    double lotSize = CalculateLotSize();
    double atrStopLoss = iATR(Symbol(), PERIOD_M15, 14, 0) * atrMultiplier;
    double price = isBuy ? Ask : Bid;
    double stopLoss = isBuy ? price - atrStopLoss : price + atrStopLoss;
    double takeProfit = isBuy ? price + (atrStopLoss * 2) : price - (atrStopLoss * 2);

    int orderType = isBuy ? OP_BUY : OP_SELL;
    int ticket = OrderSend(Symbol(), orderType, lotSize, price, 10, stopLoss, takeProfit, "EA XAUUSD M15", 0, 0, clrNONE);
    
    if (ticket > 0 && useTrailingStop)
    {
        OrderModify(ticket, price, stopLoss, takeProfit, 0, clrNONE);
    }
}

//+------------------------------------------------------------------+
//| Fungsi untuk trailing stop                                      |
//+------------------------------------------------------------------+
void ApplyTrailingStop()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            double newStop = OrderType() == OP_BUY ? Bid - trailingStopPips * Point : Ask + trailingStopPips * Point;
            if ((OrderType() == OP_BUY && newStop > OrderStopLoss()) ||
                (OrderType() == OP_SELL && newStop < OrderStopLoss()))
            {
                OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, clrNONE);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Fungsi untuk mengecek berita ekonomi                            |
//+------------------------------------------------------------------+
bool NewsEventDetected()
{
    return false; // Placeholder, perlu integrasi dengan API berita ekonomi
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
    ExecuteTrade();
    if (useTrailingStop) ApplyTrailingStop();
}
