// Web stub — home widgets don't exist on web; all methods are no-ops.
class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  static const String playQueueItemAction =
      'com.example.bettertune.PLAY_QUEUE_ITEM';

  Future<void> initialize() async {}
  static Future<void> backgroundCallback(Uri? uri) async {}
  Future<void> updateWidget() async {}
  Future<void> handleWidgetAction(String? action, {String? songId}) async {}
}
