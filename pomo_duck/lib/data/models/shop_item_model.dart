/// Model cho Shop Item - lưu trong SQLite
/// Quản lý các vật phẩm có thể mua trong shop
class ShopItemModel {
  final int? id;
  final String name;
  final String description;
  final int price;
  final String itemType; // 'shield', 'sword', 'coffee'
  final String iconPath;
  final bool isActive; // Có đang sử dụng không
  final DateTime? purchasedAt;
  final DateTime? expiresAt; // Thời gian hết hạn (nếu có)
  final DateTime createdAt;
  final int quantity; // Số lượng items đã mua

  const ShopItemModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.itemType,
    required this.iconPath,
    this.isActive = false,
    this.purchasedAt,
    this.expiresAt,
    required this.createdAt,
    this.quantity = 0,
  });

  /// Tạo ShopItemModel từ Map (từ database)
  factory ShopItemModel.fromMap(Map<String, dynamic> map) {
    return ShopItemModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as int,
      itemType: map['item_type'] as String,
      iconPath: map['icon_path'] as String,
      isActive: (map['is_active'] as int) == 1,
      purchasedAt: map['purchased_at'] != null
          ? DateTime.parse(map['purchased_at'] as String)
          : null,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      quantity: map['quantity'] as int? ?? 0,
    );
  }

  /// Chuyển ShopItemModel thành Map (để lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'item_type': itemType,
      'icon_path': iconPath,
      'is_active': isActive ? 1 : 0,
      'purchased_at': purchasedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'quantity': quantity,
    };
  }

  /// Tạo copy với các field được update
  ShopItemModel copyWith({
    int? id,
    String? name,
    String? description,
    int? price,
    String? itemType,
    String? iconPath,
    bool? isActive,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    int? quantity,
  }) {
    return ShopItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      itemType: itemType ?? this.itemType,
      iconPath: iconPath ?? this.iconPath,
      isActive: isActive ?? this.isActive,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Kiểm tra item có hết hạn không
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Kiểm tra item có thể sử dụng không
  bool get canUse {
    return isActive && !isExpired;
  }
}

/// Enum cho loại shop item
enum ShopItemType {
  shield('shield', 'Khiên'),
  sword('sword', 'Kiếm'),
  coffee('coffee', 'Cà phê');

  const ShopItemType(this.value, this.displayName);
  final String value;
  final String displayName;

  static ShopItemType fromString(String value) {
    switch (value) {
      case 'shield':
        return ShopItemType.shield;
      case 'sword':
        return ShopItemType.sword;
      case 'coffee':
        return ShopItemType.coffee;
      default:
        return ShopItemType.shield;
    }
  }
}
