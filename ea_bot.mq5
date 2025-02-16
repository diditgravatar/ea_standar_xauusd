//+------------------------------------------------------------------+
//| Expert Advisor untuk XAUUSD M15 - MA35 & MA82 dengan Optimalisasi |
//+------------------------------------------------------------------+
#property strict

input int maFastPeriod = 35;
input int maSlowPeriod = 82;
input ENUM_MA_METHOD maMethod = MODE_SMA;
input ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE;
input double adxThreshold = 25.0;
input double rsiOverbought = 70.0;
input double rsiOversold = 30.0;
input int rsiPeriod = 14;
input int adxPeriod = 14;
input double riskPercent = 2.0;
input double atrMultiplier = 2.0;
input int consolidationBars = 3; // Jumlah candle konsolidasi
input int timeFilterStart = 9;
input int timeFilterEnd = 21;
input bool useMultiTimeframe = true;
input ENUM_TIMEFRAMES higherTimeframe = PERIOD_H1;

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
//| Fungsi untuk cek breakout, pullback & konsolidasi               |
//+------------------------------------------------------------------+
bool CheckBreakoutPullback(bool isBuy)
{
    double maFastPrev = iMA(Symbol(), PERIOD_M15, maFastPeriod, 0, maMethod, appliedPrice, 1);
    double maSlowPrev = iMA(Symbol(), PERIOD_M15, maSlowPeriod, 0, maMethod, appliedPrice, 1);
    double pricePrev = iClose(Symbol(), PERIOD_M15, 1);
    
    bool breakout = (isBuy && pricePrev > maFastPrev && pricePrev > maSlowPrev) ||
                    (!isBuy && pricePrev < maFastPrev && pricePrev < maSlowPrev);
    
    if (!breakout) return false;
    
    // Cek pullback atau konsolidasi
    double highMax = -1, lowMin = 999999;
    for (int i = 1; i <= consolidationBars; i++) {
        double high = iHigh(Symbol(), PERIOD_M15, i);
        double low = iLow(Symbol(), PERIOD_M15, i);
        if (high > highMax) highMax = high;
        if (low < lowMin) lowMin = low;
    }
    
    double range = highMax - lowMin;
    double atr = iATR(Symbol(), PERIOD_M15, 14, 0);
    
    return range < (atr * 0.5); // Konsolidasi jika range kecil
}

//+------------------------------------------------------------------+
//| Fungsi untuk validasi ADX dan RSI                               |
//+------------------------------------------------------------------+
bool CheckIndicators(bool isBuy)
{
    double adx = iADX(Symbol(), PERIOD_M15, adxPeriod, PRICE_CLOSE, MODE_MAIN, 0);
    double rsi = iRSI(Symbol(), PERIOD_M15, rsiPeriod, PRICE_CLOSE, 0);
    
    if (adx < adxThreshold) return false;
    if (isBuy && rsi > rsiOverbought) return false;
    if (!isBuy && rsi < rsiOversold) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Fungsi untuk eksekusi trading                                   |
//+------------------------------------------------------------------+
void ExecuteTrade()
{
    bool isBuy = CheckBreakoutPullback(true);
    bool isSell = CheckBreakoutPullback(false);
    if (!isBuy && !isSell) return;
    if (!CheckIndicators(isBuy)) return;
    if (useMultiTimeframe && CheckBreakoutPullback(isBuy) != CheckBreakoutPullback(isBuy, higherTimeframe)) return;
    if (Hour() < timeFilterStart || Hour() > timeFilterEnd) return;

    double lotSize = CalculateLotSize();
    double atrStopLoss = iATR(Symbol(), PERIOD_M15, 14, 0) * atrMultiplier;
    double price = isBuy ? Ask : Bid;
    double stopLoss = isBuy ? price - atrStopLoss : price + atrStopLoss;
    double takeProfit = isBuy ? price + (atrStopLoss * 2) : price - (atrStopLoss * 2);

    int orderType = isBuy ? OP_BUY : OP_SELL;
    OrderSend(Symbol(), orderType, lotSize, price, 10, stopLoss, takeProfit, "EA XAUUSD M15", 0, 0, clrNONE);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int OnInit()
{
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
    ExecuteTrade();
}
