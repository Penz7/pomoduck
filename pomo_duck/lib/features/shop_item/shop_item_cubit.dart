import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/data/database/database_helper.dart';
import 'package:pomo_duck/data/models/shop_item_model.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';

part 'shop_item_state.dart';

class ShopItemCubit extends Cubit<ShopItemState> {
  ShopItemCubit() : super(ShopItemInitial()) {
    _loadShopItems();
  }

  /// Load danh sách shop items
  Future<void> _loadShopItems() async {
    try {
      emit(ShopItemLoading());
      await DatabaseHelper.instance.initializeDefaultShopItems();
      final allItems = await DatabaseHelper.instance.getAllShopItems();
      final userScore = HiveDataManager.getUserScore();
      final availableItems = <ShopItemModel>[];
      final purchasedItems = <ShopItemModel>[];
      
      for (final item in allItems) {
        if (item.purchasedAt != null) {
          purchasedItems.add(item);
        } else {
          availableItems.add(item);
        }
      }
      
      emit(ShopItemLoaded(
        availableItems: availableItems,
        purchasedItems: purchasedItems,
        userPoints: userScore.totalPoints,
      ));
    } catch (e) {
      emit(ShopItemError('Lỗi tải shop items: $e'));
    }
  }

  /// Mua shop item
  Future<void> purchaseItem(ShopItemModel item) async {
    try {
      final currentState = state;
      if (currentState is! ShopItemLoaded) return;
      if (currentState.userPoints < item.price) {
        emit(ShopItemPurchaseError('Không đủ điểm để mua vật phẩm này!'));
        return;
      }
      if (item.purchasedAt != null) {
        emit(ShopItemPurchaseError('Bạn đã mua vật phẩm này rồi!'));
        return;
      }
      final newScore = HiveDataManager.getUserScore().subtractPoints(item.price);
      await HiveDataManager.saveUserScore(newScore);
      final purchasedItem = item.copyWith(
        purchasedAt: DateTime.now(),
        isActive: true,
      );
      
      await DatabaseHelper.instance.updateShopItem(purchasedItem);
      
      // Emit success state
      emit(ShopItemPurchaseSuccess(
        purchasedItem: purchasedItem,
        remainingPoints: newScore.totalPoints,
      ));
      
      // Reload để cập nhật UI
      await _loadShopItems();
      
    } catch (e) {
      emit(ShopItemPurchaseError('Lỗi mua vật phẩm: $e'));
    }
  }

  /// Sử dụng shop item (activate/deactivate)
  Future<void> toggleItemUsage(ShopItemModel item) async {
    try {
      if (item.purchasedAt == null) return; // Chưa mua
      
      final updatedItem = item.copyWith(
        isActive: !item.isActive,
      );
      
      await DatabaseHelper.instance.updateShopItem(updatedItem);
      
      // Reload để cập nhật UI
      await _loadShopItems();
      
    } catch (e) {
      emit(ShopItemError('Lỗi cập nhật vật phẩm: $e'));
    }
  }

  /// Refresh shop items
  Future<void> refreshShopItems() async {
    await _loadShopItems();
  }

  /// Lấy active items theo loại
  List<ShopItemModel> getActiveItemsByType(String itemType) {
    final currentState = state;
    if (currentState is! ShopItemLoaded) return [];
    
    return currentState.purchasedItems
        .where((item) => item.itemType == itemType && item.isActive)
        .toList();
  }

  /// Kiểm tra có active shield không
  bool hasActiveShield() {
    return getActiveItemsByType('shield').isNotEmpty;
  }

  /// Kiểm tra có active sword không
  bool hasActiveSword() {
    return getActiveItemsByType('sword').isNotEmpty;
  }

  /// Kiểm tra có active coffee không
  bool hasActiveCoffee() {
    return getActiveItemsByType('coffee').isNotEmpty;
  }
}
