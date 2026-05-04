class AppStrings {
  AppStrings._();

  static const String appName = 'Sleep Calculator';
  static const String appTagline = 'Wake up feeling refreshed';

  // Modes
  static const String modeWakeUp = 'Wake up at';
  static const String modeSleepAt = 'Sleep at';

  // Actions
  static const String calculate = 'Calculate';
  static const String setAlarm = 'Set Alarm';
  static const String viewHistory = 'History';

  // Results
  static const String resultsTitle = 'Recommended times';
  static const String sleepDuration = 'sleep';
  static const String cycles = 'cycles';
  static const String fallAsleepNote = 'Includes ~15 min to fall asleep';

  // Insights
  static const String insightBestPerformance = 'Best performance sleep';
  static const String insightIdeal = 'Ideal sleep duration';
  static const String insightMinimum = 'Minimum recommended';
  static const String insightGood = 'Good sleep';
  static const String insightShort = 'Short sleep – not ideal';
  static const String insightVeryShort = 'Very short – avoid if possible';

  // History
  static const String historyTitle = 'Recent Calculations';
  static const String historyEmpty = 'No calculations yet';
  static const String historyEmptySub = 'Your recent sleep calculations\nwill appear here';

  // Notifications
  static const String notifChannelId = 'sleep_alarm_channel';
  static const String notifChannelName = 'Sleep Reminders';
  static const String notifTitle = 'Time to sleep!';
  static const String notifBody = 'Head to bed now to hit your target wake-up time.';

  // Errors
  static const String alarmError = 'Could not open alarm app. Please set the alarm manually.';
  static const String storageError = 'Could not save history.';

  // Misc
  static const String cycleExplainer =
      'Each sleep cycle lasts ~90 minutes. '
      'Waking mid-cycle leaves you groggy. '
      'These times align with cycle end-points.';
}
