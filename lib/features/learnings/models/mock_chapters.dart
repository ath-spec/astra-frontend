import 'package:flutter/material.dart';
import 'chapter_models.dart';

final List<Chapter> mockBeginnerChapters = [
  const Chapter(
    id: 'c1',
    title: '1. Need to invest',
    description: 'This chapter deals with the basic understanding of the need to invest. You will also learn about different investment options available.',
    readTime: '11 min read',
    cardsCount: 11,
    icon: Icons.insights_rounded,
    pages: [
      ChapterPage(
        id: 'p1_1',
        title: 'Why should I invest?',
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
            '\"Don\'t put all your eggs in one basket.\" By diversifying across asset classes, you reduce the impact of a poor performing asset on your overall portfolio.',
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
      // Mocking remaining 7 pages for length
      ChapterPage(id: 'p2_3', title: 'Depositories (NSDL & CDSL)', contents: [ChapterTextContent('Details about depositories...')]),
      ChapterPage(id: 'p2_4', title: 'Depository Participants', contents: [ChapterTextContent('Details about DPs...')]),
      ChapterPage(id: 'p2_5', title: 'Stock Brokers', contents: [ChapterTextContent('Details about stock brokers...')]),
      ChapterPage(id: 'p2_6', title: 'Clearing Corporations', contents: [ChapterTextContent('Details about clearing corporations...')]),
      ChapterPage(id: 'p2_7', title: 'Banks in the Ecosystem', contents: [ChapterTextContent('Details about banks...')]),
      ChapterPage(id: 'p2_8', title: 'KYC Agencies', contents: [ChapterTextContent('Details about KYC...')]),
      ChapterPage(id: 'p2_9', title: 'Summary', contents: [ChapterTextContent('Summary of the market ecosystem.')]),
    ],
  ),
  const Chapter(
    id: 'c3',
    title: '3. The IPO Market',
    description: 'Learn how companies raise capital from the public for the first time, what an IPO is, and how you can invest in it.',
    readTime: '15 min read',
    cardsCount: 8,
    icon: Icons.rocket_launch_rounded,
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
      // Mocking remaining 7 pages
      ChapterPage(id: 'p3_2', title: 'Why companies go public?', contents: [ChapterTextContent('Capital raising, exit strategy, etc.')]),
      ChapterPage(id: 'p3_3', title: 'The IPO Process', contents: [ChapterTextContent('Filing DRHP, roadshows, pricing.')]),
      ChapterPage(id: 'p3_4', title: 'Fixed Price vs Book Building', contents: [ChapterTextContent('Pricing mechanisms for IPOs.')]),
      ChapterPage(id: 'p3_5', title: 'Understanding the DRHP', contents: [ChapterTextContent('How to read the prospectus.')]),
      ChapterPage(id: 'p3_6', title: 'Allotment Process', contents: [ChapterTextContent('How shares are allotted.')]),
      ChapterPage(id: 'p3_7', title: 'Listing Day', contents: [ChapterTextContent('What happens on listing day.')]),
      ChapterPage(id: 'p3_8', title: 'Summary', contents: [ChapterTextContent('Summary of the IPO market.')]),
    ],
  ),
];

List<Chapter> getMockChapters(int moduleId, String level) {
  if (moduleId == 1 && level == 'Beginner') {
    return mockBeginnerChapters;
  }

  // Generate generic mock chapters for other modules/levels
  return List.generate(
    4,
    (index) => Chapter(
      id: 'm${moduleId}_${level.toLowerCase()}_c$index',
      title: 'Chapter ${index + 1}: $level Concepts',
      description: 'This is a mock chapter for Module $moduleId at the $level level. It covers essential topics and strategies.',
      readTime: '${10 + index * 2} min read',
      cardsCount: 5 + index,
      icon: _getIconForIndex(index),
      pages: List.generate(
        5 + index,
        (pageIndex) => ChapterPage(
          id: 'm${moduleId}_${level.toLowerCase()}_c${index}_p$pageIndex',
          title: 'Topic ${pageIndex + 1}',
          contents: [
            ChapterTextContent(
              'This is the detailed content for Topic ${pageIndex + 1} in Chapter ${index + 1} of the $level level for Module $moduleId.',
            ),
            if (pageIndex % 2 == 1) // Add a dummy table to alternating pages
              ChapterTableContent(
                headers: ['Concept', 'Detail', 'Impact'],
                rows: [
                  ['Alpha', 'Value 1', 'High'],
                  ['Beta', 'Value 2', 'Medium'],
                  ['Gamma', 'Value 3', 'Low'],
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

IconData _getIconForIndex(int index) {
  const icons = [
    Icons.auto_graph_rounded,
    Icons.candlestick_chart_rounded,
    Icons.pie_chart_rounded,
    Icons.timeline_rounded,
    Icons.show_chart_rounded,
  ];
  return icons[index % icons.length];
}
