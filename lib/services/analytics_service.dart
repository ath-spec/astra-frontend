class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService();
  void logScreenView(String screenName) {}
  void logEvent(String eventName, {Map<String, dynamic>? properties}) {}
  void logBudgetApproval(dynamic data) {}
}
