import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novella/core/network/request_queue.dart';
import 'package:novella/core/network/signalr_service.dart';
import 'package:novella/data/services/user_profile_service.dart';

final notificationUnreadCountProvider =
    AsyncNotifierProvider<NotificationUnreadCountNotifier, int>(
      NotificationUnreadCountNotifier.new,
    );

class NotificationUnreadCountNotifier extends AsyncNotifier<int> {
  final UserProfileService _profileService = UserProfileService();
  final SignalRService _signalRService = SignalRService();
  SignalREventSubscription? _refreshSubscription;

  @override
  Future<int> build() async {
    _bindNotificationRefresh();
    ref.onDispose(() {
      _refreshSubscription?.cancel();
      _refreshSubscription = null;
    });
    return _fetchUnreadCount();
  }

  Future<void> refreshCount({bool silent = false}) async {
    final previousValue = state.asData?.value;
    if (!silent && previousValue == null) {
      state = const AsyncLoading<int>();
    }

    try {
      final unreadCount = await _fetchUnreadCount();
      state = AsyncData(unreadCount);
    } catch (error, stackTrace) {
      if (previousValue != null) {
        state = AsyncData(previousValue);
        return;
      }
      state = AsyncError(error, stackTrace);
    }
  }

  void _bindNotificationRefresh() {
    if (_refreshSubscription != null) {
      return;
    }

    _refreshSubscription = _signalRService.subscribe('OnNotificationRefresh', (
      _,
    ) {
      unawaited(refreshCount(silent: true));
    });
  }

  Future<int> _fetchUnreadCount() async {
    final profile = await _profileService.getMyInfo(
      requestScope: RequestScopes.notification,
      priority: RequestPriority.high,
    );
    return profile.unreadNotificationCount;
  }
}
