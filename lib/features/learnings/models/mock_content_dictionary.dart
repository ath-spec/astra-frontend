const Map<String, List<String>> topicRealContent = {
  // --- MODULE 1 ---
  'Corporate Actions (Dividends, Splits, Bonus)': [
    'Corporate actions are events initiated by a public company that bring material change to its equity. They are typically agreed upon by a company\'s board of directors and authorized by its shareholders.',
    'Common corporate actions include dividends (distributing profits to shareholders), stock splits (dividing existing shares into multiple ones), and bonus issues (free additional shares given to current shareholders).',
  ],
  'Understanding Trading Terminals': [
    'A trading terminal is a specialized software provided by stockbrokers that allows investors to buy, sell, and analyze financial instruments in real time. It is the bridge between the investor and the stock exchange.',
    'Modern terminals provide advanced charting tools, order book depth, market news, and rapid execution capabilities, which are essential for active traders.',
  ],
  'Clearing and Settlement Process': [
    'Once a trade is executed, it must be cleared and settled. Clearing is the process of updating the accounts of the trading parties, and settlement is the actual exchange of money and securities.',
    'In India, the stock markets follow a T+1 settlement cycle, meaning that if you buy a stock on Monday, the shares will be credited to your Demat account, and funds deducted from your bank, by Tuesday.',
  ],
  'Market Indices Deep Dive (Nifty, Sensex)': [
    'A stock market index is a statistical measure that shows changes taking place in the stock market. It represents a basket of stocks that reflects the broader market sentiment.',
    'The Nifty 50 comprises the top 50 companies listed on the NSE, while the Sensex represents the top 30 companies on the BSE. These indices are used as benchmarks to evaluate portfolio performance.',
  ],
  'Impact of Macroeconomics on Markets': [
    'Macroeconomic factors such as inflation, interest rates, GDP growth, and employment data have a profound impact on stock markets. For instance, high inflation usually leads to higher interest rates, which increases borrowing costs for companies.',
    'When the central bank (like the RBI) raises interest rates, equity markets often face downward pressure as fixed-income assets become more attractive compared to stocks.',
  ],
  'Trading Psychology and Discipline': [
    'Trading psychology refers to the emotional and mental state that dictates success or failure in trading securities. Greed and fear are the two most prominent emotions that drive market cycles.',
    'Maintaining discipline—such as strictly adhering to stop-losses and not over-leveraging—is often cited by professional traders as being more important than the actual trading strategy itself.',
  ],

  // --- MODULE 2 ---
  'Introduction to Charting': [
    'Technical analysis is built on the premise that all market information is reflected in price, and charting is the visual representation of this price action over time.',
    'By studying past price movements on a chart, traders attempt to identify patterns and trends that can help predict future price movements with a higher degree of probability.',
  ],
  'Line vs Bar vs Candlestick Charts': [
    'A line chart connects the closing prices over a timeframe, providing a clean view of the overall trend. A bar chart expands on this by showing the Open, High, Low, and Close (OHLC) for each period.',
    'Candlestick charts, originating from Japan, represent the same OHLC data but use color-coded "bodies" and "wicks", making it significantly easier to instantly visually interpret market psychology and momentum.',
  ],
  'Understanding Trendlines': [
    'Trendlines are straight lines drawn on a chart connecting a series of price peaks (highs) or troughs (lows). An upward trendline is drawn across ascending lows, acting as support.',
    'A break of a major trendline often signals a change in market sentiment and a potential reversal in the overarching trend.',
  ],
  'Single Candlestick Patterns': [
    'Single candlestick patterns provide insights into market sentiment within a single trading session. For example, a "Doji" indicates indecision, as the opening and closing prices are virtually identical.',
    'A "Hammer" forms when a stock moves significantly lower after the open, but rallies to close well above the intraday low, indicating strong buying pressure and a potential bullish reversal.',
  ],
  'Multiple Candlestick Patterns': [
    'Patterns involving two or more candlesticks can provide stronger reversal or continuation signals. An "Engulfing" pattern occurs when a smaller candle is completely swallowed by the body of the following larger candle.',
    'The "Morning Star" is a three-candle bullish reversal pattern found at the bottom of a downtrend, consisting of a large red candle, a small-bodied middle candle, and a large green candle.',
  ],
  'Support & Resistance Principles': [
    'Support is a price level where a downtrend tends to pause due to a concentration of demand (buying interest). Resistance is the opposite—a price level where an uptrend pauses due to selling interest.',
    'Once a significant resistance level is broken, it often flips and acts as a new support level. This phenomenon is known as the principle of polarity.',
  ],
  'Volume Analysis': [
    'Volume refers to the number of shares traded during a given timeframe. It is a crucial secondary indicator that confirms the strength of a price movement.',
    'A price breakout accompanied by high volume is considered much more reliable than a breakout on low volume, which might indicate a "fakeout" or lack of conviction.',
  ],
  'Moving Averages (SMA & EMA)': [
    'A Simple Moving Average (SMA) calculates the average price over a specific number of periods. An Exponential Moving Average (EMA) does the same but places a greater weight on recent prices.',
    'Because EMAs react faster to price changes, they are heavily favored by short-term traders, while SMAs are often used to identify long-term structural trends.',
  ],
  'Oscillators (RSI & MACD)': [
    'The Relative Strength Index (RSI) measures the speed and change of price movements on a scale from 0 to 100, traditionally identifying "overbought" conditions above 70 and "oversold" below 30.',
    'The Moving Average Convergence Divergence (MACD) is a trend-following momentum oscillator that shows the relationship between two moving averages of a security\'s price.',
  ],
  'Dow Theory in Practice': [
    'Developed by Charles Dow, this theory asserts that the market moves in three trends: the primary trend (lasting years), secondary reactions (weeks to months), and minor trends (daily fluctuations).',
    'A core tenet of Dow Theory is that market indices must confirm each other—meaning a bull market in industrial stocks must be confirmed by a corresponding rally in transportation stocks.',
  ],
  'Fibonacci Retracements': [
    'Fibonacci retracements use horizontal lines to indicate where possible support and resistance levels occur based on the mathematical sequence discovered by Leonardo Fibonacci.',
    'The most common retracement levels are 38.2%, 50%, and 61.8%. Traders look for prices to pull back to these levels during a trend before resuming their original direction.',
  ],

  // --- MODULE 3 ---
  'What are Forwards and Futures?': [
    'Forward and futures contracts are derivatives that obligate the parties to buy or sell an asset at a predetermined future date and price.',
    'While forwards are customized, over-the-counter contracts carrying counterparty risk, futures are standardized contracts traded on an exchange with the clearinghouse acting as the guarantor.',
  ],
  'Understanding the Futures Contract': [
    'Every futures contract specifies the underlying asset, the lot size (minimum quantity), the expiry date, and the tick size. In equity futures, physical delivery is often replaced by cash settlement.',
    'Futures derive their value from the spot (current) price of the underlying asset, plus the cost of holding that asset until expiry (Cost of Carry).',
  ],
  'Margin Mechanisms': [
    'To trade futures, you don\'t need to pay the full contract value. Instead, you deposit a fraction called the "Initial Margin".',
    'Exchanges also calculate a "Mark-to-Market" (MTM) margin daily. If the contract moves against you, funds are deducted directly from your account, ensuring no defaults occur.',
  ],
  'Leverage and Payoff profiles': [
    'Because futures require only a small margin, they provide high leverage. A 10% move in the underlying asset could result in a 100% gain—or total loss—of the margin capital.',
    'The payoff profile of a futures contract is linear and symmetrical. For every point the underlying moves, the futures contract gains or loses proportionally.',
  ],
  'Futures Pricing (Cost of Carry)': [
    'The Fair Value of a futures contract is usually higher than the spot price. This difference is called the "Cost of Carry", which accounts for the interest cost of holding the position minus dividends.',
    'When futures trade higher than the spot price, it is called "Contango". If they trade lower, it is called "Backwardation", often seen when dividends are expected.',
  ],
  'Hedging with Futures': [
    'Hedging involves taking a futures position opposite to your cash market position to mitigate risk. For example, a portfolio manager fearing a market crash might short Nifty futures.',
    'If the market crashes, the losses in the stock portfolio are offset by the profits from the short futures position, protecting the overall capital.',
  ],
  'Arbitrage Opportunities': [
    'Arbitrage is the simultaneous purchase and sale of an asset to profit from an imbalance in the price. Cash-and-carry arbitrage involves buying the stock in the spot market and selling the overpriced futures contract.',
    'These opportunities are usually risk-free but offer low yields, and are typically executed instantly by High-Frequency Trading (HFT) algorithms.',
  ],

  // --- MODULE 4 ---
  'Introduction to Call & Put Options': [
    'An option gives the buyer the right, but not the obligation, to buy or sell an underlying asset at a specified strike price on or before expiration.',
    'A Call option gives you the right to BUY (benefiting when prices rise), while a Put option gives you the right to SELL (benefiting when prices fall).',
  ],
  'Moneyness (ITM, ATM, OTM)': [
    'Moneyness describes the intrinsic value of an option in relation to the current underlying price. An option is In-The-Money (ITM) if it has intrinsic value (e.g., a Call strike below the current price).',
    'At-The-Money (ATM) means the strike price equals the current price, and Out-Of-The-Money (OTM) options consist purely of time value with zero intrinsic value.',
  ],
  'Option Buyer vs Seller': [
    'An option buyer pays a premium and has limited risk (the premium paid) but theoretically unlimited profit potential if the market moves significantly in their favor.',
    'An option seller (writer) collects the premium upfront but takes on theoretically unlimited risk. However, sellers have the mathematical probability of time decay working in their favor.',
  ],
  'The Option Premium (Intrinsic vs Time Value)': [
    'An option\'s premium is composed of two parts: Intrinsic Value and Time Value (Extrinsic Value). Intrinsic value is how much the option is currently "in the money".',
    'Time value is the premium investors are willing to pay for the possibility that the option will move further into the money before expiration. Time value decays to zero at expiration.',
  ],
  'Understanding Implied Volatility (IV)': [
    'Implied Volatility (IV) is the market\'s forecast of a likely movement in a security\'s price. Higher IV means the market expects large price swings, making options more expensive.',
    'Traders often prefer to buy options when IV is historically low (options are cheap) and sell options when IV is high (options are expensive), anticipating a volatility crush.',
  ],
  'The Option Greeks (Delta, Gamma, Theta, Vega)': [
    'The Greeks measure the sensitivity of an option\'s price to various factors. Delta measures the change in option price for a \$1 move in the underlying asset.',
    'Theta measures time decay (losing value every day), Vega measures sensitivity to volatility changes, and Gamma measures the rate of change of Delta.',
  ],

  // --- MODULE 5 ---
  'What is Fundamental Analysis?': [
    'Fundamental analysis is the method of evaluating a security to measure its intrinsic value by examining related economic, financial, and other qualitative and quantitative factors.',
    'The goal is to determine whether a stock is overvalued or undervalued by the current market, guiding long-term investment decisions.',
  ],
  'The Balance Sheet Basics': [
    'A balance sheet provides a snapshot of a company\'s financial health at a specific moment in time. It follows the core equation: Assets = Liabilities + Shareholders\' Equity.',
    'By analyzing the balance sheet, investors can determine how much debt the company is utilizing (leverage) and how efficiently it is deploying its capital.',
  ],
  'The Profit and Loss Statement (P&L)': [
    'The P&L statement summarizes the revenues, costs, and expenses incurred during a specific period. It is also known as the income statement.',
    'It highlights the company\'s ability to generate profit by increasing revenue, reducing costs, or both. The bottom line of this statement is the Net Income.',
  ],
  'Cash Flow Statements': [
    'While the P&L shows accounting profit, the cash flow statement tracks the actual cash moving in and out of the business across operations, investing, and financing.',
    'A company can be profitable on paper but still go bankrupt if it does not generate positive free cash flow. "Cash is King" in fundamental analysis.',
  ],
  'Financial Ratio Analysis (PE, PB, ROE)': [
    'The Price-to-Earnings (P/E) ratio compares a company\'s share price to its earnings per share, helping determine if it is expensive relative to its peers.',
    'Return on Equity (ROE) measures how efficiently a company generates profits using the shareholders\' capital. Consistently high ROE is a hallmark of strong businesses.',
  ],
  'Economic Moats & Competitive Advantage': [
    'Coined by Warren Buffett, an economic moat is a distinct advantage a company has over its competitors which allows it to protect its market share and profitability.',
    'Moats can be built through powerful brand identity, high switching costs, network effects, or unique cost advantages that cannot be easily replicated.',
  ],
};
