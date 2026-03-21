import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novella/core/widgets/m3e_loading_indicator.dart';

Future<void> showReaderImagePreview(
  BuildContext context, {
  required String imageUrl,
  String? alt,
}) async {
  final trimmedUrl = imageUrl.trim();
  if (trimmedUrl.isEmpty) {
    return;
  }

  final caption = alt?.trim();

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'reader_image_preview',
    barrierColor: Colors.black.withValues(alpha: 0.92),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, _, __) {
      final size = MediaQuery.sizeOf(dialogContext);
      final maxWidth = size.width * 0.94;
      final maxHeight = size.height * 0.86;

      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).maybePop(),
                  child: const SizedBox.expand(),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                    ),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: CachedNetworkImage(
                        imageUrl: trimmedUrl,
                        memCacheWidth: 1600,
                        fit: BoxFit.contain,
                        placeholder:
                            (context, url) => const Center(
                              child: M3ELoadingIndicator(size: 24),
                            ),
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 40,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).maybePop(),
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
              ),
              if (caption != null && caption.isNotEmpty)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 16,
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
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
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
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
