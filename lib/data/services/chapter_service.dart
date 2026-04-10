import 'dart:developer' as developer;
import 'package:logging/logging.dart';
import 'package:novella/core/network/api_client.dart';
import 'package:novella/core/network/signalr_service.dart';

class ChapterContent {
  final int id;
  final String title;
  final String content;
  final String? fontUrl;
  final int sortNum;
  // 服务端提供的阅读位置
  final String? serverPosition;

  ChapterContent({
    required this.id,
    required this.title,
    required this.content,
    this.fontUrl,
    required this.sortNum,
    this.serverPosition,
  });

  factory ChapterContent.fromJson(
    Map<dynamic, dynamic> json, {
    String? position,
  }) {
    return ChapterContent(
      id: json['Id'] as int? ?? 0,
      title: json['Title'] as String? ?? 'Unknown Chapter',
      content: json['Content'] as String? ?? '',
      fontUrl: json['Font'] as String?,
      sortNum: json['SortNum'] as int? ?? 0,
      serverPosition: position,
    );
  }
}

class ChapterService {
  static final Logger _logger = Logger('ChapterService');

  /// 是否启用“零宽空格注入”。
  ///
  /// 用途：强制 Flutter 在任意位置断行。
  static const bool _kEnableZeroWidthSpaceInjection = true;

  final ApiClient _apiClient = ApiClient();
  final SignalRService _signalRService = SignalRService();

  /// 获取章节内容
  /// 使用 novel-front 的 REST API
  Future<ChapterContent> getNovelContent(
    int bid,
    int sortNum, {
    String? convert,
  }) async {
    try {
      // 使用 bookId + indexNum 查询章节内容
      // novel-front 支持通过 indexNum 自动查找 bookIndexId
      final response = await _apiClient.dio.get(
        '/book/queryBookContent',
        queryParameters: {
          'bookId': bid,
          'indexNum': sortNum, // 使用 indexNum 参数
        },
      );

      if (response.statusCode != 200 || response.data['code'] != 200) {
        throw Exception('获取章节内容失败');
      }

      final chapterData = response.data['data'] as Map<String, dynamic>;
      
      // 调试：打印原始章节数据
      developer.log(
        'Chapter data keys: ${chapterData.keys.toList()}',
        name: 'CHAPTER',
      );
      developer.log('Font value: null', name: 'CHAPTER'); // novel-front 无 Font 字段

      // 处理内容：必要时注入零宽空格以解决换行问题
      String content = chapterData['content'] as String? ?? '';
      if (_kEnableZeroWidthSpaceInjection && content.isNotEmpty) {
        content = _injectZeroWidthSpace(content);
      }

      // 转换为 ChapterContent 对象
      return ChapterContent(
        id: chapterData['id'] as int? ?? 0,
        title: chapterData['title'] as String? ?? 'Unknown Chapter',
        content: content,
        fontUrl: null, // novel-front 无此字段
        sortNum: chapterData['sortNum'] as int? ?? 0,
        serverPosition: null, // novel-front 无此字段
      );
    } catch (e) {
      _logger.severe('Failed to get novel content: $e');
      rethrow;
    }
  }

  // 欺骗 Flutter 渲染引擎允许在任意位置断行
  String _injectZeroWidthSpace(String htmlContent) {
    return htmlContent.replaceAllMapped(RegExp(r'(>)([^<]+)(<)'), (match) {
      final prefix = match.group(1)!; // >
      final text = match.group(2)!; // Content
      final suffix = match.group(3)!; // <
      // 在所有非空白字符后插入 \u200B
      final newText = _injectZeroWidthSpaceIntoText(text);
      return '$prefix$newText$suffix';
    });
  }

  String _injectZeroWidthSpaceIntoText(String text) {
    if (text.isEmpty) {
      return text;
    }

    final buffer = StringBuffer();
    final entityPattern = RegExp(r'&(#x?[0-9A-Fa-f]+|[A-Za-z]+);');
    var index = 0;

    while (index < text.length) {
      final entityMatch = entityPattern.matchAsPrefix(text, index);
      if (entityMatch != null) {
        buffer.write(entityMatch.group(0));
        index = entityMatch.end;
        continue;
      }

      final character = text[index];
      buffer.write(character);
      if (!RegExp(r'\s').hasMatch(character)) {
        buffer.write('\u200B');
      }
      index++;
    }

    return buffer.toString();
  }
}
