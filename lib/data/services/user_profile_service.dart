import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:novella/core/network/api_client.dart';
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
  final int unreadNotificationCount;
  final DateTime? registerAt;

  const UserProfile({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.email,
    required this.inviteCode,
    required this.groupName,
    required this.point,
    required this.unreadNotificationCount,
    required this.registerAt,
  });

  factory UserProfile.fromJson(Map<dynamic, dynamic> json) {
    return UserProfile(
      id: _toInt(json['id']),
      userName: json['username'] as String? ?? '',
      avatar: json['userPhoto'] as String? ?? '',
      email: '',
      inviteCode: '',
      groupName: '',
      point: _toInt(json['accountBalance']),
      unreadNotificationCount: 0,
      registerAt: DateTime.tryParse(json['createTime']?.toString() ?? ''),
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

  final ApiClient _apiClient = ApiClient();
  final SignalRService _signalRService = SignalRService();

  Future<UserProfile> getMyInfo({
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      final response = await _apiClient.dio.get('/user/userInfo');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          final code = data['code'];
          if (code == 200) {
            final userInfo = data['data'];
            if (userInfo != null) {
              return UserProfile.fromJson(userInfo);
            }
          }
        }
      }
      throw Exception('获取用户信息失败');
    } on DioException catch (e) {
      _logger.severe('Failed to get user info: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.severe('Failed to get user info: $e');
      rethrow;
    }
  }

  Future<void> setAvatar(
    String url, {
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    _logger.warning('setAvatar not implemented for novel-front');
    throw UnimplementedError('当前版本不支持设置头像功能');
  }
}
