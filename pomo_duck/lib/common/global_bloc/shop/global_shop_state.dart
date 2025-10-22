part of 'global_shop_bloc.dart';

@immutable
sealed class GlobalShopState {}

final class GlobalShopInitial extends GlobalShopState {}

final class GlobalShopLoading extends GlobalShopState {}

final class GlobalShopLoaded extends GlobalShopState {
  final List<ShopItemModel> availableItems;
  final List<ShopItemModel> purchasedItems;
  final int userPoints;

  GlobalShopLoaded({
    required this.availableItems,
    required this.purchasedItems,
    required this.userPoints,
  });

  GlobalShopLoaded copyWith({
    List<ShopItemModel>? availableItems,
    List<ShopItemModel>? purchasedItems,
    int? userPoints,
  }) {
    return GlobalShopLoaded(
      availableItems: availableItems ?? this.availableItems,
      purchasedItems: purchasedItems ?? this.purchasedItems,
      userPoints: userPoints ?? this.userPoints,
    );
  }
}

final class GlobalShopError extends GlobalShopState {
  final String message;

  GlobalShopError(this.message);
}

final class GlobalShopPurchaseSuccess extends GlobalShopState {
  final ShopItemModel purchasedItem;
  final int remainingPoints;

  GlobalShopPurchaseSuccess({
    required this.purchasedItem,
    required this.remainingPoints,
  });
}

final class GlobalShopPurchaseError extends GlobalShopState {
  final String message;

  GlobalShopPurchaseError(this.message);
}
