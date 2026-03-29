import 'package:logging/logging.dart';
import 'package:novella/core/network/request_queue.dart';
import 'package:novella/core/network/signalr_service.dart';
import 'package:novella/data/models/community.dart';

class CommunityService {
  static final Logger _logger = Logger('CommunityService');
  final SignalRService _signalRService = SignalRService();

  Future<CommunityHomePayload> getCommunityHome({
    CommunityListQuery query = const CommunityListQuery(),
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'GetCommunityHome',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          query.toJson(),
          const {'UseGzip': true},
        ],
      );
      return CommunityHomePayload.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to get community home: $error');
      rethrow;
    }
  }

  Future<CommunityFeedPayload> getCommunityFeed({
    CommunityListQuery query = const CommunityListQuery(),
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'GetCommunityFeed',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          query.toJson(),
          const {'UseGzip': true},
        ],
      );
      return CommunityFeedPayload.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to get community feed: $error');
      rethrow;
    }
  }

  Future<CommunityThreadDetail?> getCommunityThread({
    required int threadId,
    int replyPage = 1,
    int replySize = 5,
    bool? trackView,
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    try {
      final result = await _signalRService.invoke<dynamic>(
        'GetCommunityThread',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          {
            'ThreadId': threadId,
            'ReplyPage': replyPage < 1 ? 1 : replyPage,
            'ReplySize': replySize < 1 ? 1 : replySize,
            'TrackView': trackView ?? replyPage == 1,
          },
          const {'UseGzip': true},
        ],
      );

      if (result == null) {
        return null;
      }
      if (result is Map<dynamic, dynamic> && result.isEmpty) {
        return null;
      }
      if (result is! Map<dynamic, dynamic>) {
        throw Exception(
          'Unexpected GetCommunityThread response: ${result.runtimeType}',
        );
      }

      return CommunityThreadDetail.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to get community thread: $error');
      rethrow;
    }
  }

  Future<CommunityThreadDetail> createCommunityThread(
    CreateCommunityThreadRequest request, {
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'CreateCommunityThread',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          request.toJson(),
          const {'UseGzip': true},
        ],
      );
      return CommunityThreadDetail.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to create community thread: $error');
      rethrow;
    }
  }

  Future<CommunityThreadReply> createCommunityReply(
    CreateCommunityReplyRequest request, {
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'CreateCommunityReply',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          request.toJson(),
          const {'UseGzip': true},
        ],
      );
      return CommunityThreadReply.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to create community reply: $error');
      rethrow;
    }
  }

  Future<CommunityLikeToggleResult> toggleThreadLike(
    int threadId, {
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'ToggleCommunityThreadLike',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          {'ThreadId': threadId},
          const {'UseGzip': true},
        ],
      );
      return CommunityLikeToggleResult.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to toggle thread like: $error');
      rethrow;
    }
  }

  Future<CommunityFavoriteToggleResult> toggleThreadFavorite(
    int threadId, {
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'ToggleCommunityThreadFavorite',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          {'ThreadId': threadId},
          const {'UseGzip': true},
        ],
      );
      return CommunityFavoriteToggleResult.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to toggle thread favorite: $error');
      rethrow;
    }
  }

  Future<CommunityLikeToggleResult> toggleReplyLike(
    int replyId, {
    String? requestScope,
    RequestPriority priority = RequestPriority.high,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'ToggleCommunityReplyLike',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          {'ReplyId': replyId},
          const {'UseGzip': true},
        ],
      );
      return CommunityLikeToggleResult.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to toggle reply like: $error');
      rethrow;
    }
  }

  Future<CommunityReplyChildrenPayload> getCommunityReplyChildren(
    GetCommunityReplyChildrenRequest request, {
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'GetCommunityReplyChildren',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          request.toJson(),
          const {'UseGzip': true},
        ],
      );
      return CommunityReplyChildrenPayload.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to get community reply children: $error');
      rethrow;
    }
  }

  Future<CommunityMyOverview> getMyCommunityOverview({
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'GetMyCommunityOverview',
        requestScope: requestScope ?? RequestScopes.community,
        priority: priority,
        args: [
          <String, dynamic>{},
          const {'UseGzip': true},
        ],
      );
      return CommunityMyOverview.fromJson(result);
    } catch (error) {
      if (isRequestCancelledError(error)) {
        rethrow;
      }
      _logger.severe('Failed to get my community overview: $error');
      rethrow;
    }
  }
}
