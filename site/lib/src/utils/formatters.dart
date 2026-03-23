String formatChineseDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${local.year}年${local.month}月${local.day}日';
}

String formatCompactNumber(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1)}M';
  }
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(value >= 100000 ? 0 : 1)} 万';
  }
  return '$value';
}

String formatFileSize(int bytes) {
  if (bytes <= 0) {
    return '未知大小';
  }

  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;

  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }

  final precision = size >= 100 || unitIndex == 0 ? 0 : 1;
  return '${size.toStringAsFixed(precision)} ${units[unitIndex]}';
}
