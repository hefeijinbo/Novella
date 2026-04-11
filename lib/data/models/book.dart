/// API 返回的书籍分类信息
class BookCategory {
  final String shortName; // "录入"/"翻译"/"转载"
  final String name; // "录入完成" / "翻译中" etc.
  final String color; // 服务端返回的 Hex 颜色

  const BookCategory({
    required this.shortName,
    required this.name,
    required this.color,
  });

  factory BookCategory.fromJson(Map<dynamic, dynamic> json) {
    return BookCategory(
      shortName: json['ShortName'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      color: json['Color'] as String? ?? '',
    );
  }
}

class Book {
  final int id;
  final String title;
  final String cover;
  final String author;
  final DateTime lastUpdatedAt;
  final String? userName;
  final int? level;
  final int? interiorLevel;
  final BookCategory? category;

  Book({
    required this.id,
    required this.title,
    required this.cover,
    required this.author,
    required this.lastUpdatedAt,
    this.userName,
    this.level,
    this.interiorLevel,
    this.category,
  });

  factory Book.fromJson(Map<dynamic, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Book(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['bookName'] as String? ?? 'Unknown',
      cover: json['picUrl'] as String? ?? '',
      author: json['authorName'] as String? ?? 'Unknown',
      lastUpdatedAt: parseDate(json['lastIndexUpdateTime']),
      userName: null,
      level: null,
      interiorLevel: null,
      category: null,
    );
  }
}

class Chapter {
  final int id;
  final String title;

  Chapter({required this.id, required this.title});

  factory Chapter.fromJson(Map<dynamic, dynamic> json) {
    return Chapter(
      id: json['Id'] as int? ?? 0,
      title: json['Title'] as String? ?? '',
    );
  }
}

enum ShelfItemType { book, folder }

class ShelfItem {
  final int id; // int(书) 或 String(文件夹)
  final ShelfItemType type;
  final String title;
  final List<String> parents;
  final int index;
  final DateTime updatedAt;

  ShelfItem({
    required this.id,
    required this.type,
    this.title = '',
    this.parents = const [],
    this.index = 0,
    required this.updatedAt,
  });

  factory ShelfItem.fromJson(Map<dynamic, dynamic> json) {
    final typeStr = (json['type'] ?? json['Type']) as String? ?? 'BOOK';
    final type =
        typeStr == 'FOLDER' ? ShelfItemType.folder : ShelfItemType.book;

    return ShelfItem(
      id: int.parse(json['id'] ?? json['Id']),
      type: type,
      title: (json['title'] ?? json['Title']) as String? ?? '',
      parents:
          ((json['parents'] ?? json['Parents']) as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      index: (json['index'] ?? json['Index']) as int? ?? 0,
      updatedAt:
          DateTime.tryParse(
            ((json['updateAt'] ?? json['UpdateAt']) as String?) ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == ShelfItemType.folder ? 'FOLDER' : 'BOOK',
      'title': title,
      'parents': parents,
      'index': index,
      'updateAt': updatedAt.toIso8601String(),
    };
  }
}
