import 'package:flutter/material.dart';

enum ShelfEditAction { move, delete, rename }

class ShelfMoveDestination {
  final String title;
  final String? subtitle;
  final List<String> parents;
  final bool isRoot;

  const ShelfMoveDestination({
    required this.title,
    required this.parents,
    this.subtitle,
    this.isRoot = false,
  });
}

String _buildSelectionSummary({
  required int selectedBookCount,
  required int selectedFolderCount,
}) {
  final folderSummary = '$selectedFolderCount \u4e2a\u6587\u4ef6\u5939';
  if (selectedFolderCount > 0 && selectedBookCount > 0) {
    return '$selectedBookCount \u672c\u4e66\uff0c$folderSummary';
  }
  if (selectedFolderCount > 0) {
    return folderSummary;
  }
  return '$selectedBookCount \u672c\u4e66';
}

Future<ShelfEditAction?> showShelfEditActionSheet({
  required BuildContext context,
  required int selectedBookCount,
  required int selectedFolderCount,
  required int selectedFolderBookCount,
  required bool canMove,
  bool showRenameOption = false,
  bool canRename = false,
  String? moveDisabledReason,
  String? renameDisabledReason,
}) {
  return showModalBottomSheet<ShelfEditAction>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final textTheme = Theme.of(sheetContext).textTheme;
      final selectionSummary = _buildSelectionSummary(
        selectedBookCount: selectedBookCount,
        selectedFolderCount: selectedFolderCount,
      );
      final selectionHint =
          selectedFolderCount > 0
              ? '\u9009\u62e9\u8981\u5bf9\u8fd9\u4e9b\u9879\u76ee\u6267\u884c\u7684\u64cd\u4f5c'
              : '\u9009\u62e9\u8981\u5bf9\u8fd9\u4e9b\u4e66\u7c4d\u6267\u884c\u7684\u64cd\u4f5c';
      final nestedFolderHint =
          selectedFolderCount > 0 && selectedFolderBookCount > 0
              ? '\u6b64\u5916\uff0c\u6587\u4ef6\u5939\u5185\u5305\u542b $selectedFolderBookCount \u672c'
              : null;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '\u5df2\u9009\u62e9 $selectionSummary',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectionHint,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (nestedFolderHint != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      nestedFolderHint,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              enabled: canMove,
              leading: Icon(
                Icons.drive_file_move_outline,
                color:
                    canMove
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
              ),
              title: const Text('\u79fb\u52a8'),
              subtitle: Text(
                canMove
                    ? '\u79fb\u52a8\u5230\u6839\u6587\u4ef6\u5939\u6216\u5176\u5b83\u6587\u4ef6\u5939'
                    : (moveDisabledReason ??
                        '\u5f53\u524d\u9009\u62e9\u4e0d\u652f\u6301\u79fb\u52a8'),
              ),
              onTap:
                  canMove
                      ? () {
                        Navigator.pop(sheetContext, ShelfEditAction.move);
                      }
                      : null,
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colorScheme.error),
              title: Text(
                '\u5220\u9664',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                selectedFolderCount > 0
                    ? '\u4ece\u4e66\u67b6\u5220\u9664\u6240\u9009\u4e66\u7c4d\u548c\u6587\u4ef6\u5939\u5185\u5bb9'
                    : '\u4ece\u4e66\u67b6\u79fb\u51fa\u6240\u9009\u4e66\u7c4d',
              ),
              onTap: () {
                Navigator.pop(sheetContext, ShelfEditAction.delete);
              },
            ),
            if (showRenameOption)
              ListTile(
                enabled: canRename,
                leading: Icon(
                  Icons.drive_file_rename_outline,
                  color:
                      canRename
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                ),
                title: const Text('\u91cd\u547d\u540d'),
                subtitle: Text(
                  canRename
                      ? '\u4fee\u6539\u9009\u4e2d\u6587\u4ef6\u5939\u540d\u79f0'
                      : (renameDisabledReason ??
                          '\u4ec5\u652f\u6301\u5355\u9009\u6587\u4ef6\u5939\u91cd\u547d\u540d'),
                ),
                onTap:
                    canRename
                        ? () {
                          Navigator.pop(sheetContext, ShelfEditAction.rename);
                        }
                        : null,
              ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Future<bool> showShelfDeleteConfirmSheet({
  required BuildContext context,
  required int selectedBookCount,
  required int selectedFolderCount,
  required int selectedFolderBookCount,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isDismissible: false,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final textTheme = Theme.of(sheetContext).textTheme;
      final selectionSummary = _buildSelectionSummary(
        selectedBookCount: selectedBookCount,
        selectedFolderCount: selectedFolderCount,
      );
      final deleteHint =
          selectedFolderCount > 0 && selectedFolderBookCount > 0
              ? '\u786e\u5b9a\u8981\u4ece\u4e66\u67b6\u5220\u9664\u6240\u9009\u7684 $selectionSummary \u5417\uff1f\u6587\u4ef6\u5939\u5185\u542b $selectedFolderBookCount \u672c\u4e66\u4e5f\u4f1a\u4e00\u5e76\u5220\u9664\u3002'
              : null;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                selectedFolderCount > 0
                    ? '\u5220\u9664\u6240\u9009\u9879\u76ee'
                    : '\u79fb\u51fa\u4e66\u67b6',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                selectedFolderCount > 0
                    ? (deleteHint ??
                        '\u786e\u5b9a\u8981\u4ece\u4e66\u67b6\u5220\u9664\u6240\u9009\u7684 $selectionSummary \u5417\uff1f')
                    : '\u786e\u5b9a\u8981\u5c06\u9009\u4e2d\u7684 $selectionSummary \u79fb\u51fa\u4e66\u67b6\u5417\uff1f',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.delete, color: colorScheme.error),
              title: Text(
                '\u786e\u8ba4\u5220\u9664',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () => Navigator.pop(sheetContext, true),
            ),
            ListTile(
              leading: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
              title: const Text('\u53d6\u6d88'),
              onTap: () => Navigator.pop(sheetContext, false),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );

  return confirmed == true;
}

Future<List<String>?> showShelfMoveDestinationSheet({
  required BuildContext context,
  required int selectedBookCount,
  required List<ShelfMoveDestination> destinations,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final textTheme = Theme.of(sheetContext).textTheme;
      var query = '';

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final normalizedQuery = query.trim().toLowerCase();
          final filteredDestinations = destinations
              .where((destination) {
                final haystacks =
                    [
                      destination.title,
                      if (destination.subtitle != null) destination.subtitle!,
                    ].join(' ').toLowerCase();
                return normalizedQuery.isEmpty ||
                    haystacks.contains(normalizedQuery);
              })
              .toList(growable: false);

          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.6,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        '\u79fb\u52a8 $selectedBookCount \u672c\u4e66\u5230...',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        '\u53ef\u4ee5\u79fb\u5230\u6839\u6587\u4ef6\u5939\u6216\u5176\u5b83\u6587\u4ef6\u5939',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setSheetState(() {
                            query = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '\u641c\u7d22\u6587\u4ef6\u5939',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          filteredDestinations.isEmpty
                              ? Center(
                                child: Text(
                                  '\u672a\u627e\u5230\u53ef\u79fb\u52a8\u7684\u76ee\u6807',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                controller: scrollController,
                                itemCount: filteredDestinations.length,
                                itemBuilder: (context, index) {
                                  final destination =
                                      filteredDestinations[index];
                                  return ListTile(
                                    leading: Icon(
                                      destination.isRoot
                                          ? Icons.home_outlined
                                          : Icons.folder_copy_outlined,
                                      color:
                                          destination.isRoot
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                    ),
                                    title: Text(destination.title),
                                    subtitle:
                                        destination.subtitle == null ||
                                                destination.subtitle!.isEmpty
                                            ? null
                                            : Text(destination.subtitle!),
                                    onTap: () {
                                      Navigator.pop(
                                        sheetContext,
                                        destination.parents,
                                      );
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

Future<String?> _showShelfFolderNameSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String hintText,
  required String confirmLabel,
  required IconData icon,
  String initialValue = '',
}) {
  final controller = TextEditingController(text: initialValue);
  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: controller.text.length,
  );

  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final textTheme = Theme.of(sheetContext).textTheme;
      var folderName = initialValue;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final trimmedName = folderName.trim();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
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
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        setSheetState(() {
                          folderName = value;
                        });
                      },
                      onSubmitted: (value) {
                        final nextName = value.trim();
                        if (nextName.isNotEmpty) {
                          Navigator.pop(sheetContext, nextName);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: hintText,
                        prefixIcon: Icon(icon),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('\u53d6\u6d88'),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed:
                              trimmedName.isEmpty
                                  ? null
                                  : () =>
                                      Navigator.pop(sheetContext, trimmedName),
                          icon: Icon(icon),
                          label: Text(confirmLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((value) {
    controller.dispose();
    return value;
  });
}

Future<String?> showShelfCreateFolderSheet({required BuildContext context}) {
  return _showShelfFolderNameSheet(
    context: context,
    title: '\u65b0\u5efa\u6587\u4ef6\u5939',
    subtitle: '\u8f93\u5165\u6587\u4ef6\u5939\u540d\u79f0',
    hintText: '\u4f8b\u5982\uff1a\u5f85\u6574\u7406',
    confirmLabel: '\u65b0\u5efa',
    icon: Icons.create_new_folder_outlined,
  );
}

Future<String?> showShelfRenameFolderSheet({
  required BuildContext context,
  required String initialName,
}) {
  return _showShelfFolderNameSheet(
    context: context,
    title: '\u91cd\u547d\u540d\u6587\u4ef6\u5939',
    subtitle: '\u8f93\u5165\u65b0\u7684\u6587\u4ef6\u5939\u540d\u79f0',
    hintText: '\u4f8b\u5982\uff1a\u5f85\u6574\u7406',
    confirmLabel: '\u786e\u8ba4',
    icon: Icons.drive_file_rename_outline,
    initialValue: initialName,
  );
}
