import 'package:flutter/material.dart';
import 'package:novella/data/services/book_service.dart';
import 'package:novella/features/book/book_detail_page.dart';

Future<void> showReaderChapterListSheet(
  BuildContext context, {
  required int bookId,
  required int currentSortNum,
  required ValueChanged<int> onSelected,
}) async {
  var chapters = BookDetailPageState.cachedChapterList;
  final messenger = ScaffoldMessenger.maybeOf(context);

  if (chapters == null || chapters.isEmpty) {
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('正在加载章节列表...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final bookInfo = await BookService().getBookInfo(bookId);
      if (bookInfo.chapters.isNotEmpty) {
        chapters = bookInfo.chapters;
        BookDetailPageState.cachedChapterList = bookInfo.chapters;
      }
    } catch (e) {
      if (context.mounted) {
        messenger?.showSnackBar(SnackBar(content: Text('加载章节列表失败: $e')));
      }
      return;
    }
  }

  if (chapters == null || chapters.isEmpty) {
    if (context.mounted) {
      messenger?.showSnackBar(const SnackBar(content: Text('暂无章节信息')));
    }
    return;
  }

  if (!context.mounted) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      final chapterList = chapters!;

      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  '章节列表',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '共 ${chapterList.length} 章 · 当前第 $currentSortNum 章',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: chapterList.length,
                  itemBuilder: (context, index) {
                    final chapter = chapterList[index];
                    final sortNum = index + 1;
                    final isCurrentChapter = sortNum == currentSortNum;

                    return ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              '$sortNum',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color:
                                    isCurrentChapter
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                fontWeight:
                                    isCurrentChapter ? FontWeight.bold : null,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              chapter.title,
                              style: textTheme.bodyLarge?.copyWith(
                                color:
                                    isCurrentChapter
                                        ? colorScheme.primary
                                        : null,
                                fontWeight:
                                    isCurrentChapter ? FontWeight.bold : null,
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      trailing:
                          isCurrentChapter
                              ? Icon(
                                Icons.play_arrow,
                                color: colorScheme.primary,
                              )
                              : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (sortNum != currentSortNum) {
                          onSelected(sortNum);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
