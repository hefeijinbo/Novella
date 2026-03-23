import 'package:logging/logging.dart';
import 'package:novella/core/network/request_queue.dart';
import 'package:novella/core/network/signalr_service.dart';

class UserProfile {
  final int id;
  final String userName;
  final String avatar;
  final String email;
  final String inviteCode;
  final String groupName;
  final int point;
  final DateTime? registerAt;

  const UserProfile({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.email,
    required this.inviteCode,
    required this.groupName,
    required this.point,
    required this.registerAt,
  });

  factory UserProfile.fromJson(Map<dynamic, dynamic> json) {
    final role = json['Role'] as Map<dynamic, dynamic>?;

    return UserProfile(
      id: _toInt(json['Id']),
      userName: json['UserName'] as String? ?? '',
      avatar: json['Avatar'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      inviteCode: json['InviteCode'] as String? ?? '',
      groupName: role?['Name'] as String? ?? '',
      point: _toInt(json['Point']),
      registerAt: DateTime.tryParse(json['RegisterAt']?.toString() ?? ''),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class UserProfileService {
  static final Logger _logger = Logger('UserProfileService');

  final SignalRService _signalRService = SignalRService();

  Future<UserProfile> getMyInfo({
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      return UserProfile.fromJson(
        await _invokeMyInfo(
          requestScope: requestScope,
          priority: priority,
          args: [
            <String, dynamic>{},
            {'UseGzip': true},
          ],
        ),
      );
    } catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.warning(
        'GetMyInfo with Web-style args failed, retrying without options: $e',
      );
    }

    try {
      return UserProfile.fromJson(
        await _invokeMyInfo(requestScope: requestScope, priority: priority),
      );
    } catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.severe('Failed to get my info: $e');
      rethrow;
    }
  }

  Future<void> setAvatar(
    String url, {
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      await _invokeSetAvatar(
        url,
        requestScope: requestScope,
        priority: priority,
        args: [
          {'Url': url},
          {'UseGzip': true},
        ],
      );
    } catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.severe('Failed to set avatar: $e');
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> _invokeMyInfo({
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
    List<Object>? args,
  }) {
    return _signalRService.invoke<Map<dynamic, dynamic>>(
      'GetMyInfo',
      requestScope: requestScope,
      priority: priority,
      args: args,
    );
  }

  Future<void> _invokeSetAvatar(
    String url, {
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
    List<Object>? args,
  }) {
    return _signalRService.invoke<void>(
      'SetAvatar',
      requestScope: requestScope,
      priority: priority,
      args:
          args ??
          [
            {'Url': url},
          ],
    );
  }
}
