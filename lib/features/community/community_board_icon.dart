import 'package:flutter/material.dart';

IconData? resolveCommunityBoardIcon(String rawName) {
  final trimmed = rawName.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final normalized = _normalizeIconName(trimmed);
  final mapped = _materialBoardIconMap[normalized];
  if (mapped != null) {
    return mapped;
  }

  return null;
}

IconData? resolveCommunityBoardFallbackIcon(String fallbackText) {
  final text = fallbackText.trim();
  if (text.isEmpty) {
    return null;
  }

  if (text.contains('动画') || text.contains('番剧') || text.contains('视频')) {
    return Icons.ondemand_video_rounded;
  }
  if (text.contains('漫画') || text.contains('插画') || text.contains('画')) {
    return Icons.image_outlined;
  }
  if (text.contains('游戏')) {
    return Icons.sports_esports_rounded;
  }
  if (text.contains('小说') || text.contains('轻小说') || text.contains('书')) {
    return Icons.menu_book_rounded;
  }
  if (text.contains('站务') || text.contains('公告') || text.contains('反馈')) {
    return Icons.campaign_outlined;
  }
  if (text.contains('全部') || text.contains('讨论') || text.contains('社区')) {
    return Icons.forum_outlined;
  }

  return null;
}

String _normalizeIconName(String rawName) {
  final lower = rawName.trim().toLowerCase();
  final withoutPrefix = lower.startsWith('mdi') ? lower.substring(3) : lower;
  return withoutPrefix.replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

const Map<String, IconData> _materialBoardIconMap = <String, IconData>{
  'forum': Icons.forum_outlined,
  'forumoutline': Icons.forum_outlined,
  'commentmultiple': Icons.forum_outlined,
  'messageoutline': Icons.chat_bubble_outline_rounded,
  'bullhorn': Icons.campaign_outlined,
  'campaign': Icons.campaign_outlined,
  'web': Icons.language_rounded,
  'video': Icons.ondemand_video_rounded,
  'movie': Icons.movie_outlined,
  'playboxmultipleoutline': Icons.ondemand_video_rounded,
  'image': Icons.image_outlined,
  'imageoutline': Icons.image_outlined,
  'palette': Icons.palette_outlined,
  'controller': Icons.sports_esports_rounded,
  'gamepadvariantoutline': Icons.sports_esports_rounded,
  'gamepadroundoutline': Icons.sports_esports_rounded,
  'book': Icons.menu_book_rounded,
  'bookopenvariant': Icons.auto_stories_outlined,
  'textboxoutline': Icons.notes_rounded,
  'star': Icons.star_outline_rounded,
};

class CommunityBoardIconBadge extends StatelessWidget {
  const CommunityBoardIconBadge({
    super.key,
    required this.accent,
    required this.iconName,
    required this.fallbackText,
    required this.size,
    required this.iconSize,
    required this.borderRadius,
  });

  final Color accent;
  final String iconName;
  final String fallbackText;
  final double size;
  final double iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final iconData =
        resolveCommunityBoardIcon(iconName) ??
        resolveCommunityBoardFallbackIcon(fallbackText);
    final fallback =
        fallbackText.trim().isEmpty
            ? '?'
            : fallbackText.trim().characters.first;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child:
          iconData != null
              ? Icon(iconData, size: iconSize, color: accent)
              : Text(
                fallback,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: iconSize,
                ),
              ),
    );
  }
}
