import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novella/features/reader/reader_paged_page.dart';
import 'package:novella/features/reader/reader_scroll_page.dart';
import 'package:novella/features/settings/settings_provider.dart';

class ReaderPage extends ConsumerWidget {
  final int bid;
  final int sortNum;
  final int totalChapters;
  final String? coverUrl;
  final String? bookTitle;
  final bool allowServerOverrideOnOpen;

  const ReaderPage({
    super.key,
    required this.bid,
    required this.sortNum,
    required this.totalChapters,
    this.coverUrl,
    this.bookTitle,
    this.allowServerOverrideOnOpen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readerViewMode = ref.watch(
      settingsProvider.select((settings) => settings.readerViewMode),
    );

    if (readerViewMode == ReaderViewMode.paged) {
      return ReaderPagedPage(
        bid: bid,
        sortNum: sortNum,
        totalChapters: totalChapters,
        coverUrl: coverUrl,
        bookTitle: bookTitle,
        allowServerOverrideOnOpen: allowServerOverrideOnOpen,
      );
    }

    return ReaderScrollPage(
      bid: bid,
      sortNum: sortNum,
      totalChapters: totalChapters,
      coverUrl: coverUrl,
      bookTitle: bookTitle,
      allowServerOverrideOnOpen: allowServerOverrideOnOpen,
    );
  }
}
