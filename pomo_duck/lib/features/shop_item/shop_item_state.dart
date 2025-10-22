part of 'shop_item_cubit.dart';

@immutable
sealed class ShopItemState {}

final class ShopItemInitial extends ShopItemState {}

final class ShopItemLoading extends ShopItemState {}

final class ShopItemLoaded extends ShopItemState {
  final List<ShopItemModel> availableItems;
  final List<ShopItemModel> purchasedItems;
  final int userPoints;

  ShopItemLoaded({
    required this.availableItems,
    required this.purchasedItems,
    required this.userPoints,
  });

  ShopItemLoaded copyWith({
    List<ShopItemModel>? availableItems,
    List<ShopItemModel>? purchasedItems,
    int? userPoints,
  }) {
    return ShopItemLoaded(
      availableItems: availableItems ?? this.availableItems,
      purchasedItems: purchasedItems ?? this.purchasedItems,
      userPoints: userPoints ?? this.userPoints,
    );
  }
}

final class ShopItemError extends ShopItemState {
  final String message;

  ShopItemError(this.message);
}

final class ShopItemPurchaseSuccess extends ShopItemState {
  final ShopItemModel purchasedItem;
  final int remainingPoints;

  ShopItemPurchaseSuccess({
    required this.purchasedItem,
    required this.remainingPoints,
  });
}

final class ShopItemPurchaseError extends ShopItemState {
  final String message;

  ShopItemPurchaseError(this.message);
}
