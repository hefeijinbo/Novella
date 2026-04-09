import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:novella/core/network/api_client.dart';
import 'package:novella/core/network/request_queue.dart';
import 'package:novella/core/network/signalr_service.dart';
import 'package:novella/data/models/book.dart';
import 'package:novella/data/services/book_cover_hint_service.dart';
import 'package:novella/features/book/book_detail_page.dart';

class BookService {
  static final Logger _logger = Logger('BookService');
  final ApiClient _apiClient = ApiClient();
  final SignalRService _signalRService = SignalRService();
  final BookCoverHintService _bookCoverHintService = BookCoverHintService();

  Future<List<Book>> getLatestBooks({
    int page = 1,
    int size = 20,
    bool ignoreJapanese = false,
    bool ignoreAI = false,
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'GetLatestBookList',
        requestScope: requestScope,
        priority: priority,
        args: [
          // 请求参数
          {
            'Page': page,
            'Size': size,
            'Order': 'latest',
            'IgnoreJapanese': ignoreJapanese,
            'IgnoreAI': ignoreAI,
          },
          // 选项（参考 defaultRequestOptions）
          {'UseGzip': true},
        ],
      );

      if (result['Data'] is List) {
        final List<dynamic> list = result['Data'];
        _logger.info('Parsed ${list.length} books from server');
        final books = list.map((e) => Book.fromJson(e)).toList();
        _bookCoverHintService.rememberBooks(books);
        return books;
      }
      return [];
    } catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.severe('Failed to get latest books: $e');
      rethrow;
    }
  }

  /// 获取书籍列表（分页/排序/过滤）
  Future<SearchResult> getBookList({
    int page = 1,
    int size = 20,
    String order = 'latest',
    bool ignoreJapanese = false,
    bool ignoreAI = false,
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/book/searchByPage',
        queryParameters: {
          'curr': page,
          'limit': size,
          'sort': order == 'latest' ? 'last_index_update_time' : order,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          final code = data['code'];
          if (code == 200) {
            final pageData = data['data'];
            if (pageData is Map) {
              final List<dynamic> list = pageData['list'] ?? [];
              final int total = int.tryParse(pageData['total']?.toString() ?? '0') ?? 0;
              final totalPages = (total / size).ceil();

              final books = list.map((e) => Book.fromJson(e)).toList();
              _bookCoverHintService.rememberBooks(books);

              return SearchResult(
                books: books,
                totalPages: totalPages,
                currentPage: page,
              );
            }
          }
        }
      }
      throw Exception('获取书籍列表失败');
    } on DioException catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.severe('Failed to get book list: ${e.message}');
      rethrow;
    } catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.severe('Failed to get book list: $e');
      rethrow;
    }
  }

  Future<List<Book>> getBooksByIds(
    List<int> ids, {
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    if (ids.isEmpty) return [];

    // 分块加载，每块最多 24 个（参考 PRD）
    final List<Book> allBooks = [];
    final int chunkSize = 24;

    for (var i = 0; i < ids.length; i += chunkSize) {
      final end = (i + chunkSize < ids.length) ? i + chunkSize : ids.length;
      final chunk = ids.sublist(i, end);

      try {
        final result = await _signalRService.invoke<List<dynamic>>(
          'GetBookListByIds',
          requestScope: requestScope,
          priority: priority,
          args: [
            // Request params
            {'Ids': chunk},
            // 选项
            {'UseGzip': true},
          ],
        );

        // 过滤 null 元素（服务端对权限受限书籍可能返回 null）
        final books =
            result
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => Book.fromJson(e))
                .toList();
        _bookCoverHintService.rememberBooks(books);
        allBooks.addAll(books);
      } catch (e) {
        if (isRequestCancelledError(e)) rethrow;
        _logger.severe('Failed to get books chunk $i-$end: $e');
        // 跳过失败分块，继续处理其他分块
      }
    }

    return allBooks;
  }

  /// 获取详细书籍信息（含章节）
  /// 使用 novel-front 的 REST API
  Future<BookInfo> getBookInfo(
    int id, {
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      // 1. 获取书籍详情
      final bookResponse = await _apiClient.dio.get(
        '/book/queryBookDetail/$id',
      );

      if (bookResponse.statusCode != 200 || bookResponse.data['code'] != 200) {
        throw Exception('获取书籍详情失败');
      }

      final bookData = bookResponse.data['data'] as Map<String, dynamic>;
      final bookInfo = BookInfo.fromJson(bookData);

      // 2. 获取章节列表（默认获取前100章，按序号升序）
      final chaptersResponse = await _apiClient.dio.get(
        '/book/queryIndexList',
        queryParameters: {
          'bookId': id,
          'curr': 1,
          'limit': 100,
          'orderBy': 'index_num asc',
        },
      );

      if (chaptersResponse.statusCode == 200 &&
          chaptersResponse.data['code'] == 200) {
        final pageData = chaptersResponse.data['data'];
        if (pageData is Map) {
          final List<dynamic> chapterList = pageData['list'] ?? [];
          final chapters = chapterList
              .map((e) => ChapterInfo.fromJson(e as Map<String, dynamic>))
              .toList();

          // 返回包含章节的完整书籍信息
          return BookInfo(
            id: bookInfo.id,
            title: bookInfo.title,
            cover: bookInfo.cover,
            author: bookInfo.author,
            introduction: bookInfo.introduction,
            lastUpdatedAt: bookInfo.lastUpdatedAt,
            lastUpdatedChapter: bookInfo.lastUpdatedChapter,
            favorite: bookInfo.favorite,
            views: bookInfo.views,
            canEdit: bookInfo.canEdit,
            chapters: chapters,
            user: bookInfo.user,
            serverReadPosition: bookInfo.serverReadPosition,
          );
        }
      }

      _logger.info('Got book info for id=$id with ${bookInfo.chapters.length} chapters');
      return bookInfo;
    } catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.severe('Failed to get book info: $e');
      rethrow;
    }
  }

  /// 获取指定周期的排行榜
  /// 使用 novel-front 的 REST API
  /// [days]: 1=日榜, 7=周榜, 31=月榜 (novel-front 不支持天数，统一返回总榜)
  Future<List<Book>> getRank(
    int days, {
    String? requestScope,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      // novel-front 的 type 参数:
      // 0: 点击榜, 1: 新书榜, 2: 更新榜, 3: 评论榜
      // 这里将 days 映射为 type:
      // days <= 1 -> type 0 (点击榜)
      // days <= 7 -> type 2 (更新榜)
      // days > 7 -> type 1 (新书榜)
      final int type;
      if (days <= 1) {
        type = 0; // 点击榜
      } else if (days <= 7) {
        type = 2; // 更新榜
      } else {
        type = 1; // 新书榜
      }

      final response = await _apiClient.dio.get(
        '/book/listRank',
        queryParameters: {
          'type': type,
          'limit': 30, // 默认返回30条
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final books = dataList.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
        _bookCoverHintService.rememberBooks(books);
        _logger.info('Got ${books.length} books from ranking (type=$type)');
        return books;
      }

      throw Exception('获取排行榜失败');
    } catch (e) {
      if (isRequestCancelledError(e)) rethrow;
      _logger.severe('Failed to get ranking: $e');
      rethrow;
    }
  }

  /// 关键词搜索书籍
  /// 参考 services/book/index.ts
  Future<SearchResult> searchBooks(
    String keywords, {
    int page = 1,
    int size = 10,
    bool ignoreJapanese = false,
    bool ignoreAI = false,
  }) async {
    try {
      final result = await _signalRService.invoke<Map<dynamic, dynamic>>(
        'GetBookList',
        args: [
          {
            'Page': page,
            'Size': size,
            'KeyWords': keywords,
            'IgnoreJapanese': ignoreJapanese,
            'IgnoreAI': ignoreAI,
          },
          {'UseGzip': true},
        ],
      );

      final List<dynamic> data = result['Data'] ?? [];
      final int totalPages = result['TotalPages'] ?? 0;

      _logger.info(
        'Search "$keywords" page $page: ${data.length} results, $totalPages pages',
      );

      return SearchResult(
        books: data.map((e) => Book.fromJson(e)).toList(),
        totalPages: totalPages,
        currentPage: page,
      );
    } catch (e) {
      _logger.severe('Failed to search books: $e');
      rethrow;
    }
  }
}

/// 带分页信息的搜索结果
class SearchResult {
  final List<Book> books;
  final int totalPages;
  final int currentPage;

  SearchResult({
    required this.books,
    required this.totalPages,
    required this.currentPage,
  });
}
