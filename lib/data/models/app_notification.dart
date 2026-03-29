enum AppNotificationType {
  comment,
  commentReply,
  communityThreadReply,
  communityThreadChildReply;

  static AppNotificationType fromApi(String? value) {
    switch (value) {
      case 'Comment':
        return AppNotificationType.comment;
      case 'CommentReply':
        return AppNotificationType.commentReply;
      case 'CommunityThreadReply':
        return AppNotificationType.communityThreadReply;
      case 'CommunityThreadChildReply':
        return AppNotificationType.communityThreadChildReply;
      default:
        return AppNotificationType.comment;
    }
  }
}

enum AppNotificationObjectType {
  book,
  announcement,
  communityThread;

  static AppNotificationObjectType fromApi(String? value) {
    switch (value) {
      case 'Book':
        return AppNotificationObjectType.book;
      case 'Announcement':
        return AppNotificationObjectType.announcement;
      case 'CommunityThread':
        return AppNotificationObjectType.communityThread;
      default:
        return AppNotificationObjectType.book;
    }
  }
}

class AppNotificationActor {
  const AppNotificationActor({
    required this.id,
    required this.userName,
    required this.avatar,
  });

  final int id;
  final String userName;
  final String avatar;

  factory AppNotificationActor.fromJson(Map<dynamic, dynamic> json) {
    return AppNotificationActor(
      id: _toInt(json['Id']),
      userName: _toString(json['UserName']),
      avatar: _toString(json['Avatar']),
    );
  }
}

class AppNotificationExtra {
  const AppNotificationExtra({
    required this.objectId,
    required this.objectTitle,
    required this.preview,
    required this.replyId,
    required this.parentReplyId,
    required this.replyToReplyId,
    required this.replyPreview,
  });

  final int objectId;
  final String objectTitle;
  final String preview;
  final int? replyId;
  final int? parentReplyId;
  final int? replyToReplyId;
  final String replyPreview;

  factory AppNotificationExtra.fromJson(Map<dynamic, dynamic> json) {
    return AppNotificationExtra(
      objectId: _toInt(json['object_id']),
      objectTitle: _toString(json['object_title']),
      preview: _toString(json['preview']),
      replyId: _toNullableInt(json['reply_id']),
      parentReplyId: _toNullableInt(json['parent_reply_id']),
      replyToReplyId: _toNullableInt(json['reply_to_reply_id']),
      replyPreview: _toString(json['reply_preview']),
    );
  }
}

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.actor,
    required this.type,
    required this.objectType,
    required this.objectId,
    required this.isRead,
    required this.createdAt,
    required this.extra,
  });

  final int id;
  final AppNotificationActor? actor;
  final AppNotificationType type;
  final AppNotificationObjectType objectType;
  final int objectId;
  final bool isRead;
  final DateTime? createdAt;
  final AppNotificationExtra extra;

  factory AppNotificationItem.fromJson(Map<dynamic, dynamic> json) {
    final extraJson =
        json['Extra'] is Map<dynamic, dynamic>
            ? json['Extra'] as Map<dynamic, dynamic>
            : const <dynamic, dynamic>{};
    return AppNotificationItem(
      id: _toInt(json['Id']),
      actor:
          json['Actor'] is Map<dynamic, dynamic>
              ? AppNotificationActor.fromJson(
                json['Actor'] as Map<dynamic, dynamic>,
              )
              : null,
      type: AppNotificationType.fromApi(json['Type']?.toString()),
      objectType: AppNotificationObjectType.fromApi(
        json['ObjectType']?.toString(),
      ),
      objectId: _toInt(json['ObjectId']),
      isRead: _toBool(json['IsRead']),
      createdAt: _toDateTime(json['CreatedAt']),
      extra: AppNotificationExtra.fromJson(extraJson),
    );
  }
}

class AppNotificationPage {
  const AppNotificationPage({
    required this.totalPages,
    required this.page,
    required this.items,
  });

  final int totalPages;
  final int page;
  final List<AppNotificationItem> items;

  factory AppNotificationPage.fromJson(Map<dynamic, dynamic> json) {
    return AppNotificationPage(
      totalPages: _toInt(json['TotalPages']),
      page: _toInt(json['Page'], fallback: 1),
      items: (json['Data'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(AppNotificationItem.fromJson)
          .toList(growable: false),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _toNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  return _toInt(value);
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  final normalized = value?.toString().toLowerCase();
  if (normalized == 'true' || normalized == '1') {
    return true;
  }
  if (normalized == 'false' || normalized == '0') {
    return false;
  }
  return fallback;
}

String _toString(dynamic value, {String fallback = ''}) {
  final result = value?.toString();
  if (result == null || result == 'null') {
    return fallback;
  }
  return result;
}

DateTime? _toDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
