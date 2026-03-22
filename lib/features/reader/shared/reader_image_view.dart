import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novella/core/widgets/m3e_loading_indicator.dart';

const int _readerImagePreviewMaxZoomPercent = 600;

Future<void> showReaderImagePreview(
  BuildContext context, {
  required String imageUrl,
  String? alt,
}) async {
  final trimmedUrl = imageUrl.trim();
  if (trimmedUrl.isEmpty) {
    return;
  }

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'reader_image_preview',
    barrierColor: Colors.black.withValues(alpha: 0.96),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, _, __) {
      return _ReaderImagePreviewDialog(
        imageUrl: trimmedUrl,
        alt: alt?.trim(),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ReaderImagePreviewDialog extends StatefulWidget {
  final String imageUrl;
  final String? alt;

  const _ReaderImagePreviewDialog({required this.imageUrl, this.alt});

  @override
  State<_ReaderImagePreviewDialog> createState() =>
      _ReaderImagePreviewDialogState();
}

class _ReaderImagePreviewDialogState extends State<_ReaderImagePreviewDialog> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox.expand(),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1,
              maxScale: _readerImagePreviewMaxZoomPercent / 100,
              boundaryMargin: const EdgeInsets.all(64),
              clipBehavior: Clip.none,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Semantics(
                  label: widget.alt?.isNotEmpty == true ? widget.alt : '图片预览',
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    memCacheWidth: 2200,
                    width: size.width,
                    height: size.height,
                    fit: BoxFit.contain,
                    placeholder:
                        (context, url) => const Center(
                          child: M3ELoadingIndicator(size: 26),
                        ),
                    errorWidget:
                        (context, url, error) => Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 44,
                        ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Center(
                  child: AdaptiveButton.child(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: AdaptiveButtonStyle.gray,
                    size: AdaptiveButtonSize.medium,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('退出'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReaderRoundedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String? alt;
  final double borderRadius;
  final double? width;
  final double? height;
  final double? maxWidth;
  final BoxFit fit;
  final int memCacheWidth;
  final Color errorColor;
  final bool previewable;
  final EdgeInsetsGeometry padding;

  const ReaderRoundedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.errorColor,
    this.alt,
    this.borderRadius = 4,
    this.width,
    this.height,
    this.maxWidth,
    this.fit = BoxFit.contain,
    this.memCacheWidth = 1080,
    this.previewable = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget child = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: trimmedUrl,
        memCacheWidth: memCacheWidth,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildError(),
      ),
    );

    if (maxWidth != null) {
      child = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: child,
      );
    }

    if (padding != EdgeInsets.zero) {
      child = Padding(padding: padding, child: child);
    }

    if (previewable) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          showReaderImagePreview(context, imageUrl: trimmedUrl, alt: alt);
        },
        child: child,
      );
    }

    return child;
  }

  Widget _buildPlaceholder() {
    final placeholderWidth = _finiteOrNull(width);
    final placeholderHeight = _finiteOrNull(height);
    if (placeholderWidth != null || placeholderHeight != null) {
      return SizedBox(
        width: placeholderWidth ?? 40,
        height: placeholderHeight ?? 40,
        child: const Center(child: M3ELoadingIndicator(size: 16)),
      );
    }
    return const Center(child: M3ELoadingIndicator(size: 20));
  }

  Widget _buildError() {
    final errorWidth = _finiteOrNull(width);
    final errorHeight = _finiteOrNull(height);
    final icon = Icon(
      Icons.broken_image_outlined,
      color: errorColor.withValues(alpha: 0.4),
      size: 28,
    );
    if (errorWidth != null || errorHeight != null) {
      return SizedBox(
        width: errorWidth ?? 40,
        height: errorHeight ?? 40,
        child: Center(child: icon),
      );
    }
    return Center(child: icon);
  }

  double? _finiteOrNull(double? value) {
    if (value == null || !value.isFinite) {
      return null;
    }
    return value;
  }
}
