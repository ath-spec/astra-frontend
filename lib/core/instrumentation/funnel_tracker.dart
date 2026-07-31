class FunnelTracker {
  static final FunnelTracker instance = FunnelTracker();
  void startFunnel(String name) {}
  void advanceFunnel(String name, String step) {}
  void cancelFunnel(String name) {}
  void completeFunnel(String name) {}
  void logStep(String name, {required int stepNumber, required String stepName}) {}
  void endFunnel(String name, {bool success = true}) {}
}
