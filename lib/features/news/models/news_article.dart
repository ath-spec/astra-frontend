
class NewsArticle {
  final String image;
  final List<String> tags;
  final String title;
  final String description;
  final String source;
  final String body;
  final String readTime;
  final String publishedDate;

  const NewsArticle({
    required this.image,
    required this.tags,
    required this.title,
    required this.description,
    required this.source,
    required this.body,
    required this.readTime,
    required this.publishedDate,
  });
}

const Map<String, String> newsArticleBodies = {
  'Income Tax Department\'s NUDGE drive leads to 1.25 crore updated ITRs':
      '''The Central Board of Direct Taxes (CBDT) recently revealed that its technology-driven NUDGE (Non-intrusive Usage of Data to Grow and Enhance) campaign has prompted an astonishing 1.25 crore taxpayers across India to revise or update their Income Tax Returns (ITRs) during the financial year 2024–25.

The campaign was designed around the principle of proactive, non-coercive engagement. Instead of sending notices or initiating audits, the tax department used sophisticated data analytics to identify discrepancies between data reported in ITRs and information available from third parties — such as banks, stock brokers, and property registrars.

Taxpayers were sent gentle nudges through SMS, email, and the e-filing portal, alerting them to specific income fields that appeared inconsistent with available data. The approach was received positively by a large section of taxpayers who were either unaware of the gaps or had genuinely made clerical errors.

The initiative is part of a broader strategy to widen the tax base without burdening honest taxpayers with adversarial proceedings. The department successfully recovered an estimated ₹8,400 crore in additional tax through voluntary compliance, demonstrating the power of behavioral economics in public administration.

Officials at CBDT noted that the initiative was significantly more cost-effective than traditional enforcement mechanisms. The technology stack powering the NUDGE system now integrates data from over 60 different government and financial reporting sources, making it one of the most sophisticated compliance tools deployed by any tax authority globally.

For individual taxpayers, the message is clear: the department now has deep visibility into financial transactions. Any undisclosed income — from capital gains, rental income, or freelance earnings — is increasingly likely to be flagged automatically.''',

  'A 3 year investment break turned ₹17 crore into ₹12.1 crore':
      '''Consider two investors who both start with ₹1 crore. Both invest in instruments compounding at 12% per year for 25 years. The first investor, let's call him Raj, stays disciplined and never touches his corpus. The second investor, Priya, is forced to pause her investments for 3 years due to a personal emergency.

At the end of 25 years, Raj has ₹17 crore. Priya has ₹12.1 crore.

The gap? ₹4.9 crore. And the cause? Three years of missed compounding.

This thought experiment illustrates what mathematicians call the "compound interest cliff" — the phenomenon where the later years of compounding produce exponentially larger returns than the early years. The last 5 years of a 25-year compounding journey can account for nearly half the total wealth created.

The implication for investors is profound. The cost of a break is not simply the returns you miss during the break itself — it is the cascading loss of all the future compounding that would have built on those returns.

Financial planners strongly recommend maintaining SIPs even during market downturns for exactly this reason. An investment paused during a market crash misses not just the recovery, but all the years of compounding that follow.

The rule of 72 offers a simple way to visualize this: at 12% returns, money doubles every 6 years. A 3-year pause doesn't just cost you the returns of those 3 years — it pushes your doubling cycle back by half, with exponential consequences.''',

  'AI Stocks Rally: Are we in a bubble or a new era?':
      '''Global technology funds are seeing inflows at levels not witnessed since the dot-com era. Semiconductor giants, AI infrastructure providers, and software companies building on large language models are collectively adding hundreds of billions in market capitalization each quarter.

NVIDIA, the undisputed bellwether of the AI trade, has seen its stock rise over 400% in the past two years. Microsoft, Alphabet, Amazon, and Meta have all pivoted significant R&D budgets toward AI products that are already generating measurable revenue.

The question every rational investor is asking: is this a bubble, or a genuine structural shift in the global economy?

The bull case is compelling. Unlike the dot-com era where companies were valued on "eyeballs" and "clicks" with no corresponding revenue, today's AI leaders are generating billions in profits. Microsoft's Azure AI revenue, Google's AI-powered ad improvements, and Meta's recommendation algorithms are all directly contributing to earnings.

The bear case is equally thoughtful. Valuations for the Magnificent 7 stocks are stretched by historical standards. The P/E ratios for several of these companies price in flawless execution for the next decade. Any stumble — a disappointing product launch, a regulatory clampdown, or an energy constraint on data centers — could trigger significant corrections.

The most likely reality, as with most technological revolutions, is that both camps are partially right. AI will be transformative, but the timeline, winners, and losers will look very different from today's consensus view.''',

  'RBI holds repo rate steady at 6.5%':
      '''The Reserve Bank of India's Monetary Policy Committee (MPC) voted to keep the benchmark repo rate unchanged at 6.5% in its latest review, marking the sixth consecutive meeting without a rate adjustment. The decision was unanimous, with all six members of the committee agreeing to maintain the current stance.

Governor Shaktikanta Das cited persistent food inflation as the primary reason for continued caution. While core inflation — which strips out food and fuel — has been trending downward, vegetable prices have remained elevated due to erratic monsoon patterns in key growing regions.

For equity investors, a stable rate environment is broadly positive. Companies benefit from predictable borrowing costs, and the absence of rate hikes removes a key headwind for valuations. The Indian benchmark indices responded positively to the announcement.

For debt investors, the news signals that the rate cycle may be at or near its peak. Long-duration bond investors have been positioning for rate cuts, betting that the RBI will begin easing policy in the second half of the fiscal year as inflation comes under control.

The MPC reiterated its "withdrawal of accommodation" stance but signaled greater flexibility. Analysts widely expect the first rate cut to come in the February or April MPC meeting, provided food inflation shows a sustained moderation.

The rate decision has direct implications for EMI payments on home loans, personal loans, and auto loans. Any reduction in the repo rate will eventually translate into lower borrowing costs for millions of Indian households.''',

  'Magnificent 7 stocks drive 80% of S&P 500 returns':
      '''The first half of this year has seen one of the most concentrated market rallies in the history of the S&P 500. Just seven technology companies — Apple, Microsoft, NVIDIA, Alphabet, Amazon, Meta, and Tesla — have collectively accounted for approximately 80% of the index's total gains.

This phenomenon, while remarkable, is not entirely unprecedented. In the years following any major technological disruption, the companies closest to the new paradigm tend to attract disproportionate capital before the effects diffuse across the broader economy.

What is unusual, however, is the scale of the concentration. The S&P 500 is meant to be a diversified bet on American corporate success. When 7 out of 500 companies drive 80% of returns, passive investors — who hold all 500 — end up with 93% of their portfolio doing very little of the work.

This has sparked a debate among portfolio managers. Active managers who overweighted these seven stocks have had an exceptional year. Those who followed traditional diversification principles — avoiding concentration, rebalancing into underperformers — have significantly lagged.

The practical implication for retail investors is nuanced. While the concentration is real, broad market indices still offer a better risk-adjusted return than most active managers over 10-year periods. The question is whether the current environment represents a durable shift in how markets reward concentration risk.''',

  'Commercial real estate sees 15% bump in tier 2 cities':
      '''India's commercial real estate sector is witnessing a remarkable geographic shift. While Mumbai, Delhi-NCR, and Bengaluru continue to dominate office absorption, cities like Pune, Hyderabad, Ahmedabad, and Chandigarh are emerging as the new growth frontiers, with commercial space absorption jumping 15% year-on-year.

The driving force behind this shift is the hybrid work model. As companies recalibrate their real estate strategies, many are finding that maintaining large, expensive flagship offices in tier-1 cities while establishing satellite offices in tier-2 cities offers the best of both worlds: access to talent markets, lower real estate costs, and employee satisfaction.

The ripple effects on residential real estate in these cities have been equally pronounced. As professionals move to or stay in tier-2 cities instead of migrating to metros, demand for quality housing has surged. Several residential projects in these markets have reported over 90% pre-sale within weeks of launch.

For real estate investors, the thesis is straightforward: tier-2 cities offer higher rental yield potential, lower entry prices, and a longer runway for capital appreciation. REITs focused on these markets are attracting significant institutional interest.

The infrastructure angle is critical. Tier-2 cities that have seen the most commercial interest are those with improving road connectivity, airport capacity, and digital infrastructure. Cities that invested in urban planning over the past decade are now reaping the rewards.''',

  'Gold hits new all-time high amid geopolitical tensions':
      '''Gold has surged to a new all-time high, breaching the \$2,500 per troy ounce mark for the first time in history, driven by a confluence of geopolitical uncertainty, central bank buying, and dollar weakness.

The catalyst was a deterioration in several global flashpoints simultaneously. Ongoing conflicts in Eastern Europe and the Middle East, combined with renewed tensions in the South China Sea, triggered a flight-to-safety that saw billions of dollars flow into gold ETFs, futures contracts, and physical gold within days.

Central banks have been significant contributors to the rally. For the third consecutive year, global central bank gold purchases are on track to exceed 1,000 tonnes. Countries seeking to reduce their dependence on US dollar reserves — including China, India, Turkey, and several Middle Eastern nations — have been consistent buyers.

The Indian domestic gold price, which also factors in currency fluctuations, import duties, and local demand, has crossed ₹75,000 per 10 grams, making Sovereign Gold Bonds (SGBs) and Gold ETFs increasingly attractive as cost-efficient alternatives to physical gold.

For retail investors, the current rally raises a crucial question about allocation. Most financial planners recommend a 5–10% allocation to gold as a portfolio hedge. Those who were underweight may consider gradually increasing their exposure through systematic investment plans in gold funds.''',

  'Silver follows gold\'s rally, breaks key resistance':
      '''Silver, often nicknamed "gold's little brother," has finally broken out of a years-long consolidation range, surging past the key \$30 per troy ounce resistance level on the back of gold's rally and its own unique industrial demand drivers.

Unlike gold, which derives most of its value from monetary and investment demand, silver has a substantial industrial component. Approximately 60% of annual silver demand comes from industrial applications — and the fastest-growing use case is solar panel manufacturing. Each solar panel contains roughly 20 grams of silver, and with global solar installations accelerating, the structural demand outlook for silver is exceptionally bullish.

The supply side paints an equally interesting picture. Primary silver mines have been facing production challenges, with ore grades declining at several major operations. Recycling supply, while growing, is unlikely to fully compensate for the gap.

The gold-to-silver ratio — which measures how many ounces of silver it takes to buy one ounce of gold — has historically averaged around 60:1. At current prices, the ratio stands above 80:1, suggesting silver is statistically undervalued relative to gold on a historical basis.

For investors, silver offers a higher-volatility, higher-potential-return alternative to gold. It amplifies gold's moves on the way up (and the way down), making position sizing and risk management critical for any meaningful allocation.''',
};

String getArticleBody(String title) {
  return newsArticleBodies[title] ??
      'This is a curated summary of a recent market development. Our editorial team has gathered insights from leading financial analysts to bring you the most relevant context for your investment decisions.\n\nMarkets continue to evolve rapidly, and staying informed is one of the most powerful edges an investor can have. Check back for the full analysis.';
}
