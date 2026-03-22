import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novella/features/settings/settings_provider.dart';
import 'package:novella/features/settings/widgets/settings_header_card.dart';
import 'package:novella/features/settings/widgets/settings_ui_helper.dart';

const _readerViewModeLabels = {
  ReaderViewMode.paged: '左右翻页',
  ReaderViewMode.scroll: '滑动翻页',
};

const _convertTypeLabels = {
  'none': '关闭',
  't2s': '繁转简',
  's2t': '简转繁',
};

const _cleanChapterTitleScopeLabels = {
  AppSettings.cleanChapterTitleContinueReadingScope: '续读按钮',
  AppSettings.cleanChapterTitleReaderTitleScope: '阅读页面',
};

const _cleanChapterTitleScopeIcons = {
  AppSettings.cleanChapterTitleContinueReadingScope: Icons.play_circle_outline,
  AppSettings.cleanChapterTitleReaderTitleScope:
      Icons.chrome_reader_mode_outlined,
};

const _cleanChapterTitleScopes = [
  AppSettings.cleanChapterTitleContinueReadingScope,
  AppSettings.cleanChapterTitleReaderTitleScope,
];

class ReadingSettingsPage extends ConsumerWidget {
  const ReadingSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final currentConvertTypeLabel =
        _convertTypeLabels[settings.convertType] ?? '关闭';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(),
          const SliverToBoxAdapter(
            child: SettingsHeaderCard(
              icon: Icons.menu_book,
              title: '阅读设置',
              subtitle: '管理排版样式与阅读习惯',
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('字体大小'),
                subtitle: Text('${settings.fontSize.toInt()} px'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: settings.fontSize,
                    min: 12,
                    max: 32,
                    divisions: 20,
                    label: '${settings.fontSize.toInt()}',
                    onChanged: notifier.setFontSize,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.format_line_spacing),
                title: const Text('行间距'),
                subtitle: Text(settings.readerLineHeight.toStringAsFixed(1)),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: settings.readerLineHeight,
                    min: 1.2,
                    max: 2.4,
                    divisions: 12,
                    label: settings.readerLineHeight.toStringAsFixed(1),
                    onChanged: notifier.setReaderLineHeight,
                  ),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.format_indent_increase),
                title: const Text('首行缩进'),
                subtitle: const Text('为段落开头添加两个全角空格'),
                value: settings.readerFirstLineIndent,
                onChanged: notifier.setReaderFirstLineIndent,
              ),
              ListTile(
                leading: Icon(
                  settings.readerViewMode == ReaderViewMode.paged
                      ? Icons.swap_horiz
                      : Icons.swap_vert,
                ),
                title: const Text('阅读方式'),
                subtitle: Text(
                  _readerViewModeLabels[settings.readerViewMode] ?? '左右翻页',
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap:
                    () => SettingsUIHelper.showSelectionSheet<ReaderViewMode>(
                      context: context,
                      title: '阅读方式',
                      subtitle: '选择滑动滚动或左右翻页',
                      currentValue: settings.readerViewMode,
                      options: _readerViewModeLabels,
                      icons: const {
                        ReaderViewMode.paged: Icons.swap_horiz,
                        ReaderViewMode.scroll: Icons.swap_vert,
                      },
                      onSelected: notifier.setReaderViewMode,
                    ),
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('繁简转换'),
                subtitle: Text(currentConvertTypeLabel),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap:
                    () => SettingsUIHelper.showSelectionSheet<String>(
                      context: context,
                      title: '繁简转换',
                      subtitle: '阅读时自动转换文字',
                      currentValue: settings.convertType,
                      options: _convertTypeLabels,
                      icons: const {
                        'none': Icons.close,
                        't2s': Icons.arrow_circle_down_outlined,
                        's2t': Icons.arrow_circle_up_outlined,
                      },
                      onSelected: notifier.setConvertType,
                    ),
              ),
              ListTile(
                leading: const Icon(Icons.auto_fix_high),
                title: const Text('简化章节标题'),
                subtitle: Text(_getCleanChapterTitleScopeSummary(settings)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _showCleanChapterTitleScopeSheet(context),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  String _getCleanChapterTitleScopeSummary(AppSettings settings) {
    final enabledScopes =
        _cleanChapterTitleScopes
            .where(settings.isCleanChapterTitleEnabled)
            .toList(growable: false);
    if (enabledScopes.isEmpty) {
      return '关闭';
    }
    if (enabledScopes.length == _cleanChapterTitleScopes.length) {
      return '全部';
    }
    if (enabledScopes.length == 1) {
      return _cleanChapterTitleScopeLabels[enabledScopes.first] ?? '关闭';
    }
    return '${enabledScopes.length} 个作用域';
  }

  void _showCleanChapterTitleScopeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final settings = ref.watch(settingsProvider);
            final notifier = ref.read(settingsProvider.notifier);
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        '简化章节标题',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        '选择标题简化的作用域；不选择任何作用域时视为关闭。',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ..._cleanChapterTitleScopes.map((scopeId) {
                      final isEnabled = settings.isCleanChapterTitleEnabled(
                        scopeId,
                      );
                      return ListTile(
                        leading: Icon(
                          _cleanChapterTitleScopeIcons[scopeId],
                          color:
                              isEnabled
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          _cleanChapterTitleScopeLabels[scopeId] ?? scopeId,
                          style: TextStyle(
                            color: isEnabled ? colorScheme.primary : null,
                            fontWeight: isEnabled ? FontWeight.bold : null,
                          ),
                        ),
                        trailing: Switch(
                          value: isEnabled,
                          onChanged: (value) {
                            final nextScopes = List<String>.from(
                              settings.cleanChapterTitleScopes,
                            );
                            if (value) {
                              if (!nextScopes.contains(scopeId)) {
                                nextScopes.add(scopeId);
                              }
                            } else {
                              nextScopes.remove(scopeId);
                            }
                            notifier.setCleanChapterTitleScopes(nextScopes);
                          },
                        ),
                        onTap: () {
                          final nextScopes = List<String>.from(
                            settings.cleanChapterTitleScopes,
                          );
                          if (isEnabled) {
                            nextScopes.remove(scopeId);
                          } else if (!nextScopes.contains(scopeId)) {
                            nextScopes.add(scopeId);
                          }
                          notifier.setCleanChapterTitleScopes(nextScopes);
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
