import 'package:logging/logging.dart';
import 'package:novella/core/network/request_queue.dart';
import 'package:novella/core/network/signalr_service.dart';
import 'package:novella/data/models/app_notification.dart';

class NotificationService {
  static final Logger _logger = Logger('NotificationService');
  final SignalRService _signalRService = SignalRService();

  Future<AppNotificationPage> getNotifications({
    int page = 1,
    int size = 20,
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'GetNotifications',
        requestScope: requestScope ?? RequestScopes.notification,
        priority: priority,
        args: [
          {'Page': page < 1 ? 1 : page, 'Size': size < 1 ? 1 : size},
          const {'UseGzip': true},
        ],
      );
      return AppNotificationPage.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to get notifications: $error');
      rethrow;
    }
  }

  Future<void> markNotifications(
    List<int> ids, {
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    if (ids.isEmpty) {
      return;
    }

    try {
      await _signalRService.invoke<void>(
        'MarkNotifications',
        requestScope: requestScope ?? RequestScopes.notification,
        priority: priority,
        args: [
          {'Ids': ids},
          const {'UseGzip': true},
        ],
      );
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to mark notifications: $error');
      rethrow;
    }
  }
}
