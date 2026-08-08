import 'package:flutter/material.dart';
import 'chapter_models.dart';
import 'mock_content_dictionary.dart';

// --- Hardcoded Module 1 Beginner Content (Requested by User) ---
final List<Chapter> mockBeginnerChapters = [
  const Chapter(
    id: 'c1',
    title: '1. Need to invest',
    description: 'This chapter deals with the basic understanding of the need to invest. You will also learn about different investment options available.',
    readTime: '11 min read',
    cardsCount: 11,
    icon: Icons.insights_rounded,
    imagePath: 'lib/core/images/need_to_invest.webp',
    pages: [
      ChapterPage(
        id: 'p1_1',
        title: 'Why should I invest?',
        imagePath: 'lib/core/images/why_invist.webp',
        contents: [
          ChapterTextContent(
            'Before we address the above question, let us understand what would happen if one chooses not to invest. Assume you earn Rs.50,000/- per month, and you spend Rs.30,000/- towards your day-to-day living; this can include expenses like housing, food, transport, shopping, medical, etc. The balance of Rs.20,000/- is your monthly surplus.',
          ),
          ChapterTextContent(
            'For the sake of simplicity, let us ignore the tax effect in this discussion.',
          ),
          ChapterTextContent(
            'To drive the point across, let us make a few simple assumptions –\n\n1. The employer is kind enough to give you a 10% salary hike every year.\n2. The cost of living is likely to go up by 8% yearly.\n3. You are 30 years old and plan to retire at 50, this translates to 20 working years.\n4. You don\'t intend to work after you retire.\n5. Your expenses are fixed, and you don\'t foresee any other expenses.\n6. The balance cash of Rs.20,000/- per month is retained as hard cash.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_2',
        title: 'The Math',
        imagePath: 'lib/core/images/the_math.webp',
        contents: [
          ChapterTextContent(
            'Going by the assumptions in the previous card, here is what the cash balance will look like in 20 years.',
          ),
          ChapterTableContent(
            headers: ['Years', 'Yearly Income', 'Yearly Expense', 'Cash Retained'],
            rows: [
              ['1', '600,000', '360,000', '240,000'],
              ['2', '660,000', '388,800', '271,200'],
              ['3', '726,000', '419,904', '306,096'],
              ['4', '798,600', '453,496', '345,104'],
              ['5', '878,460', '489,776', '388,684'],
              ['10', '1,414,769', '719,642', '695,127'],
              ['20', '3,669,301', '1,553,584', '2,115,717'],
            ],
          ),
          ChapterTextContent(
            'If one were to analyze these numbers, one would soon realize this is a scary situation. A few things are quite obvious –\n\n1.  After 20 years of hard work, you have accumulated Rs.1.7Crs.\n\n2.  Since your expenses are fixed, your lifestyle has not changed over the years, and you probably even suppressed your lifelong aspirations – a better home, car, vacations, etc.\n\n3.  After you retire, assuming the expenses will continue to grow at 8%, the retirement corpus of Rs.1.7Crs is good enough to sail you through roughly 8 years of post-retirement life. 8th year onwards, you will be in a tight spot with literally no savings left to back you up.',
          ),
          ChapterTextContent(
            'What would you do after you run out of money in 8 years? How do you fund your life? Is there a way to ensure that you collect a more considerable sum at the end of 20 years?',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_3',
        title: 'Investments',
        contents: [
          ChapterTextContent(
            'At this point, you may think that the assumptions are simple and that real life does not work like this. I agree, and I won\'t dispute that fact. However, the point to note in the above calculation is that no investments are made, hence the cash retained has a flat or zero growth.',
          ),
          ChapterTextContent(
            'Let\'s consider another scenario where instead of keeping the cash idle, you choose to invest the cash in an investment option that grows at, let\'s say, 12% per annum.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_4',
        title: 'Fixed Income Instruments',
        contents: [
          ChapterTextContent(
            'Fixed income instruments are investment options where the borrower or issuer is obliged to make payments of a fixed amount on a fixed schedule. Examples include fixed deposits (FDs), government bonds, and corporate bonds.',
          ),
          ChapterTextContent(
            'They are generally considered safer than equities, making them a crucial part of a balanced portfolio to protect your capital.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_5',
        title: 'Equity',
        contents: [
          ChapterTextContent(
            'When you buy a share of equity, you are buying a piece of ownership in a company. This means you have a claim on part of the corporation\'s assets and earnings.',
          ),
          ChapterTextContent(
            'Equities have historically provided higher returns than other asset classes over the long term, but they also come with higher volatility and risk.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_6',
        title: 'Real Estate',
        contents: [
          ChapterTextContent(
            'Real estate involves purchasing physical land or property. It can provide a steady stream of rental income and potential capital appreciation.',
          ),
          ChapterTextContent(
            'However, physical real estate is highly illiquid and requires significant capital upfront. Alternatively, investors can look at Real Estate Investment Trusts (REITs) which allow you to invest in real estate like buying a stock.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_7',
        title: 'Commodity - Bullion',
        contents: [
          ChapterTextContent(
            'Bullion refers to physical gold and silver of high purity that is often kept in the form of bars, ingots, or coins. Bullion is traditionally considered a safe-haven asset.',
          ),
          ChapterTextContent(
            'During times of economic uncertainty or high inflation, investors often flock to commodities like gold to preserve their wealth, as these assets tend to retain their value better than paper currencies.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_8',
        title: 'Asset Allocation',
        contents: [
          ChapterTextContent(
            'Asset allocation is an investment strategy that aims to balance risk and reward by apportioning a portfolio\'s assets according to an individual\'s goals, risk tolerance, and investment horizon.',
          ),
          ChapterTextContent(
            '"Don\'t put all your eggs in one basket." By diversifying across asset classes, you reduce the impact of a poor performing asset on your overall portfolio.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_9',
        title: 'Things to note before investing',
        contents: [
          ChapterTextContent(
            '1. Clear your high-interest debt first (like credit cards).\n2. Build an emergency fund (3-6 months of living expenses).\n3. Understand your risk tolerance.\n4. Do your own research; avoid blindly following stock tips.\n5. Think long-term and avoid emotional decisions during market crashes.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_10',
        title: 'Gold',
        contents: [
          ChapterTextContent(
            'Investment in gold and silver (bullion) is perceived as the safest investment option ever. This perception is widespread across the world.',
          ),
          ChapterTextContent(
            'Gold and silver over a long-term period have appreciated in value. Investments in these metals have generally resulted in a return of approximately 7 to 8% over the last 20 years.',
          ),
          ChapterTextContent(
            'There are several ways to invest in gold and silver. One can choose to invest in the form of jewellery or Exchange Traded Funds (ETF), or the Govt issued gold bonds.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p1_11',
        title: 'Conclusion',
        contents: [
          ChapterTextContent(
            'Investing is not a choice, it is a necessity. By investing your savings wisely, you allow your money to work for you over time, ensuring a financially secure future.',
          ),
          ChapterTextContent(
            'Now that you understand the basic need to invest and the various asset classes available, we will delve deeper into the market structure in the next chapter.',
          ),
        ],
      ),
    ],
  ),
  const Chapter(
    id: 'c2',
    title: '2. Financial Regulators & Intermediaries',
    description: 'Read this chapter to understand the basics of the stock markets, the market ecosystem, financial intermediaries, and the role of the regulator.',
    readTime: '12 min read',
    cardsCount: 9,
    icon: Icons.account_balance_rounded,
    imagePath: 'lib/core/images/regulators_chapter.webp',
    pages: [
      ChapterPage(
        id: 'p2_1',
        title: 'The Regulator: SEBI',
        contents: [
          ChapterTextContent(
            'The Securities and Exchange Board of India (SEBI) is the regulatory body for the securities market in India. Its primary objective is to protect the interests of investors in securities and to promote the development of, and to regulate, the securities market.',
          ),
        ],
      ),
      ChapterPage(
        id: 'p2_2',
        title: 'Stock Exchanges',
        contents: [
          ChapterTextContent(
            'A stock exchange is a centralized platform where buyers and sellers come together to trade publicly listed securities. In India, the two primary stock exchanges are the Bombay Stock Exchange (BSE) and the National Stock Exchange (NSE).',
          ),
        ],
      ),
      ChapterPage(id: 'p2_3', title: 'Depositories (NSDL & CDSL)', contents: [ChapterTextContent('Depositories hold your financial securities in a dematerialized (electronic) form, eliminating the risk of physical share certificates.')]),
      ChapterPage(id: 'p2_4', title: 'Depository Participants', contents: [ChapterTextContent('A Depository Participant (DP) acts as an agent between the depository and the investor. You open your Demat account through a DP.')]),
      ChapterPage(id: 'p2_5', title: 'Stock Brokers', contents: [ChapterTextContent('A stock broker acts as an intermediary who executes your buy and sell orders on the stock exchange. They provide the trading platform.')]),
      ChapterPage(id: 'p2_6', title: 'Clearing Corporations', contents: [ChapterTextContent('Clearing corporations ensure that trades are settled properly. They guarantee that buyers receive their shares and sellers receive their money.')]),
      ChapterPage(id: 'p2_7', title: 'Banks in the Ecosystem', contents: [ChapterTextContent('Banks facilitate the transfer of funds. A trading account must be linked to a bank account to allow seamless inflow and outflow of capital.')]),
      ChapterPage(id: 'p2_8', title: 'KYC Agencies', contents: [ChapterTextContent('Know Your Customer (KYC) agencies verify the identity and address of investors before they can open Demat or trading accounts.')]),
      ChapterPage(id: 'p2_9', title: 'Summary', contents: [ChapterTextContent('The stock market is a highly regulated ecosystem comprising multiple entities that ensure your investments are safe, transparent, and efficiently executed.')]),
    ],
  ),
  const Chapter(
    id: 'c3',
    title: '3. The IPO Market',
    description: 'Learn how companies raise capital from the public for the first time, what an IPO is, and how you can invest in it.',
    readTime: '15 min read',
    cardsCount: 8,
    icon: Icons.rocket_launch_rounded,
    imagePath: 'lib/core/images/ipo_market_chapter.webp',
    pages: [
      ChapterPage(
        id: 'p3_1',
        title: 'What is an IPO?',
        contents: [
          ChapterTextContent(
            'An Initial Public Offering (IPO) is the process by which a private company offers shares to the public in a new stock issuance. Public share issuance allows a company to raise capital from public investors.',
          ),
        ],
      ),
      ChapterPage(id: 'p3_2', title: 'Why companies go public?', contents: [ChapterTextContent('Companies issue IPOs to raise massive capital for expansion, pay off existing debts, or provide an exit strategy for early-stage investors like venture capitalists.')]),
      ChapterPage(id: 'p3_3', title: 'The IPO Process', contents: [ChapterTextContent('The process begins with hiring an investment bank, filing a Draft Red Herring Prospectus (DRHP) with SEBI, marketing the IPO (roadshows), and finalizing the price band.')]),
      ChapterPage(id: 'p3_4', title: 'Fixed Price vs Book Building', contents: [ChapterTextContent('In a Fixed Price issue, the company sets a specific price for its shares. In a Book Building issue, a price band is offered, and investors bid within that band. The final cut-off price is determined by demand.')]),
      ChapterPage(id: 'p3_5', title: 'Understanding the DRHP', contents: [ChapterTextContent('The DRHP is the most critical document for an investor. It contains details about the company\'s business operations, financials, promoters, objective of the issue, and potential risks.')]),
      ChapterPage(id: 'p3_6', title: 'Allotment Process', contents: [ChapterTextContent('Once the bidding closes, shares are allotted based on the oversubscription rate. If heavily oversubscribed, allotment may happen via a lottery system.')]),
      ChapterPage(id: 'p3_7', title: 'Listing Day', contents: [ChapterTextContent('On listing day, the shares officially begin trading on the stock exchange. If the demand is high, the stock might list at a "premium" to the issue price.')]),
      ChapterPage(id: 'p3_8', title: 'Summary', contents: [ChapterTextContent('IPOs offer a chance to invest in companies early in their public journey, but they require careful analysis of the DRHP and an understanding of market sentiment.')]),
    ],
  ),
];

// --- Dynamic Content Generator for all other Modules and Levels ---

const Map<int, Map<String, List<String>>> moduleTopics = {
  1: { // Stock Market Basics
    'Beginner': ['Need to invest', 'Financial Regulators & Intermediaries', 'The IPO Market'],
    'Intermediate': ['Corporate Actions (Dividends, Splits, Bonus)', 'Understanding Trading Terminals', 'Clearing and Settlement Process'],
    'Advance': ['Market Indices Deep Dive (Nifty, Sensex)', 'Impact of Macroeconomics on Markets', 'Trading Psychology and Discipline'],
  },
  2: { // Technical Analysis
    'Beginner': ['Introduction to Charting', 'Line vs Bar vs Candlestick Charts', 'Understanding Trendlines'],
    'Intermediate': ['Single Candlestick Patterns', 'Multiple Candlestick Patterns', 'Support & Resistance Principles', 'Volume Analysis'],
    'Advance': ['Moving Averages (SMA & EMA)', 'Oscillators (RSI & MACD)', 'Dow Theory in Practice', 'Fibonacci Retracements'],
  },
  3: { // Futures Trading
    'Beginner': ['What are Forwards and Futures?', 'Understanding the Futures Contract', 'Margin Mechanisms'],
    'Intermediate': ['Leverage and Payoff profiles', 'Futures Pricing (Cost of Carry)', 'Hedging with Futures'],
    'Advance': ['Arbitrage Opportunities', 'Rolling over Futures', 'Short Squeezes & Open Interest Analysis'],
  },
  4: { // Options Trading
    'Beginner': ['Introduction to Call & Put Options', 'Moneyness (ITM, ATM, OTM)', 'Option Buyer vs Seller'],
    'Intermediate': ['The Option Premium (Intrinsic vs Time Value)', 'Understanding Implied Volatility (IV)', 'Basic Option Payoffs'],
    'Advance': ['The Option Greeks (Delta, Gamma, Theta, Vega)', 'Option Pricing Models', 'Put-Call Parity'],
  },
  5: { // Fundamental Analysis
    'Beginner': ['What is Fundamental Analysis?', 'Understanding the Annual Report', 'The Balance Sheet Basics'],
    'Intermediate': ['The Profit and Loss Statement (P&L)', 'Cash Flow Statements', 'Financial Ratio Analysis (PE, PB, ROE)'],
    'Advance': ['Discounted Cash Flow (DCF) Valuation', 'Analyzing Management Quality', 'Economic Moats & Competitive Advantage'],
  },
  6: { // Option Strategies
    'Beginner': ['Covered Call Strategy', 'Cash Secured Put', 'Bull Call Spread'],
    'Intermediate': ['Bear Put Spread', 'Straddles and Strangles', 'Iron Condor Strategy'],
    'Advance': ['Butterfly Spreads', 'Calendar Spreads', 'Ratio Spreads and Adjustments'],
  },
  7: { // Currency, Commodity, Govt Sec
    'Beginner': ['Introduction to Forex Trading', 'Commodities Market (MCX)', 'What are Government Bonds?'],
    'Intermediate': ['Currency Pairs and Pips', 'Trading Gold, Silver, and Crude Oil', 'Yield Curves'],
    'Advance': ['Macro Factors affecting Currencies', 'Contango and Backwardation in Commodities', 'Interest Rate Futures'],
  }
};

List<Chapter> getMockChapters(int moduleId, String level) {
  // Return the detailed hardcoded data for Module 1 Beginner
  if (moduleId == 1 && level == 'Beginner') {
    return mockBeginnerChapters;
  }

  // Look up actual topics for the given module and level
  final moduleData = moduleTopics[moduleId] ?? {
    'Beginner': ['Introduction to Module $moduleId', 'Basic Concepts of Module $moduleId', 'Core Principles'],
    'Intermediate': ['Intermediate Strategies', 'Practical Application', 'Risk Management'],
    'Advance': ['Advanced Frameworks', 'Algorithmic Execution', 'Masterclass Summary'],
  };

  final topicList = moduleData[level] ?? moduleData['Beginner']!;

  // Generate a Chapter for each topic
  return List.generate(
    topicList.length,
    (index) {
      final topicName = topicList[index];
      
      return Chapter(
        id: 'm${moduleId}_${level.toLowerCase()}_c$index',
        title: '${index + 1}. $topicName',
        description: 'Dive deep into $topicName. This chapter explores the critical aspects, strategies, and nuances required to master this topic at the $level level.',
        readTime: '${8 + (index * 2)} min read',
        cardsCount: topicRealContent.containsKey(topicName) ? topicRealContent[topicName]!.length + 1 : 4 + index,
        icon: _getIconForIndex(moduleId + index),
        pages: List.generate(
          topicRealContent.containsKey(topicName) ? topicRealContent[topicName]!.length + 1 : 4 + index,
          (pageIndex) {
            
            // Check if we have real written content for this topic
            final realContent = topicRealContent[topicName];
            
            if (realContent != null) {
              if (pageIndex < realContent.length) {
                // Use the real paragraphs
                return ChapterPage(
                  id: 'm${moduleId}_${level.toLowerCase()}_c${index}_p$pageIndex',
                  title: pageIndex == 0 ? 'Introduction' : 'Deep Dive',
                  contents: [
                    ChapterTextContent(realContent[pageIndex]),
                  ],
                );
              } else {
                // Final summary page
                return ChapterPage(
                  id: 'm${moduleId}_${level.toLowerCase()}_c${index}_p$pageIndex',
                  title: 'Summary',
                  contents: [
                    ChapterTextContent('This concludes the lesson on $topicName. Ensure you understand these core principles before advancing.'),
                    if (topicName.contains('Math') || topicName.contains('Analysis') || topicName.contains('Valuation'))
                      ChapterTableContent(
                        headers: ['Metric', 'Baseline', 'Target'],
                        rows: [
                          ['Volatility', '12%', '8%'],
                          ['Expected Return', '10%', '15%'],
                        ],
                      ),
                  ],
                );
              }
            }

            // Fallback to generic contextual section titles
            final sectionTitles = [
              'Introduction to $topicName',
              'Key Components',
              'The Math & Framework',
              'Real-world Examples',
              'Common Pitfalls',
              'Advanced Strategies',
              'Conclusion'
            ];
            
            final sectionTitle = pageIndex < sectionTitles.length 
                ? sectionTitles[pageIndex] 
                : 'Section ${pageIndex + 1}';

            return ChapterPage(
              id: 'm${moduleId}_${level.toLowerCase()}_c${index}_p$pageIndex',
              title: sectionTitle,
              contents: [
                ChapterTextContent(
                  'In this section, we analyze $sectionTitle within the context of $topicName. Understanding this concept is pivotal for investors operating at the $level level.',
                ),
                ChapterTextContent(
                  'Financial markets are dynamic, and applying the principles of $topicName requires discipline, proper risk management, and continuous learning.',
                ),
                if (pageIndex == 2) // Add a realistic-looking table to the "Math & Framework" section
                  ChapterTableContent(
                    headers: ['Metric', 'Baseline', 'Target'],
                    rows: [
                      ['Volatility', '12%', '8%'],
                      ['Expected Return', '10%', '15%'],
                      ['Drawdown Limit', '20%', '10%'],
                      ['Win Rate', '45%', '60%'],
                    ],
                  ),
              ],
            );
          },
        ),
      );
    },
  );
}

IconData _getIconForIndex(int index) {
  const icons = [
    Icons.auto_graph_rounded,
    Icons.candlestick_chart_rounded,
    Icons.pie_chart_rounded,
    Icons.timeline_rounded,
    Icons.show_chart_rounded,
    Icons.query_stats_rounded,
    Icons.waterfall_chart_rounded,
    Icons.analytics_rounded,
  ];
  return icons[index % icons.length];
}
