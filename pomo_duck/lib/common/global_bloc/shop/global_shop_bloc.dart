import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pomo_duck/data/database/database_helper.dart';
import 'package:pomo_duck/data/models/shop_item_model.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';

part 'global_shop_state.dart';

class GlobalShopBloc extends Cubit<GlobalShopState> {
  GlobalShopBloc() : super(GlobalShopInitial()) {
    _initializeShop();
  }

  /// Notify ScoreBloc để cập nhật hiển thị điểm
  void _notifyScoreBloc() {
    // Tìm ScoreBloc trong context và update
    // Note: Cần access từ context, tạm thời bỏ qua
    // ScoreBloc sẽ tự động refresh khi có thay đổi trong HiveDataManager
  }

  /// Khởi tạo shop system
  Future<void> _initializeShop() async {
    try {
      emit(GlobalShopLoading());
      
      // Khởi tạo default items nếu chưa có
      await DatabaseHelper.instance.initializeDefaultShopItems();
      
      // Load shop items
      await _loadShopItems();
      
    } catch (e) {
      emit(GlobalShopError('Lỗi khởi tạo shop: $e'));
    }
  }

  /// Load danh sách shop items
  Future<void> _loadShopItems() async {
    try {
      final allItems = await DatabaseHelper.instance.getAllShopItems();
      final userScore = HiveDataManager.getUserScore();
      
      // Phân loại items
      final availableItems = <ShopItemModel>[];
      final purchasedItems = <ShopItemModel>[];
      
      for (final item in allItems) {
        if (item.quantity > 0) {
          purchasedItems.add(item);
        } else {
          availableItems.add(item);
        }
      }
      
      
      emit(GlobalShopLoaded(
        availableItems: availableItems,
        purchasedItems: purchasedItems,
        userPoints: userScore.totalPoints,
      ));
    } catch (e) {
      emit(GlobalShopError('Lỗi tải shop items: $e'));
    }
  }

  /// Mua shop item
  Future<void> purchaseItem(ShopItemModel item) async {
    try {
      final currentState = state;
      if (currentState is! GlobalShopLoaded) return;
      
      if (currentState.userPoints < item.price) {
        emit(GlobalShopPurchaseError('Không đủ điểm để mua vật phẩm này!'));
        return;
      }
      // Giới hạn khiên tối đa 3
      if (item.itemType == 'shield' && item.quantity >= 3) {
        emit(GlobalShopPurchaseError('Khiên đã đạt tối đa 3. Không thể mua thêm!'));
        return;
      }
      
      // Trừ điểm
      final newScore = HiveDataManager.getUserScore().subtractPoints(item.price);
      await HiveDataManager.saveUserScore(newScore);
      
      // Tăng quantity thay vì tạo item mới
      final purchasedItem = item.copyWith(
        quantity: item.quantity + 1,
        purchasedAt: item.purchasedAt ?? DateTime.now(), // Chỉ set lần đầu
      );
      
      await DatabaseHelper.instance.updateShopItem(purchasedItem);
      
      // Emit success state
      emit(GlobalShopPurchaseSuccess(
        purchasedItem: purchasedItem,
        remainingPoints: newScore.totalPoints,
      ));
      
      // Reload để cập nhật UI
      await _loadShopItems();
      
    } catch (e) {
      emit(GlobalShopPurchaseError('Lỗi mua vật phẩm: $e'));
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
      emit(GlobalShopError('Lỗi cập nhật vật phẩm: $e'));
    }
  }

  /// Sử dụng item (giảm quantity)
  Future<void> useItem(ShopItemModel item) async {
    try {
      if (item.quantity <= 0) return;
      
      // Giảm quantity thay vì xóa item
      final updatedItem = item.copyWith(
        quantity: item.quantity - 1,
      );
      
      await DatabaseHelper.instance.updateShopItem(updatedItem);
      
      // Reload để cập nhật UI
      await _loadShopItems();
      
    } catch (e) {
      emit(GlobalShopError('Lỗi sử dụng vật phẩm: $e'));
    }
  }

  /// Refresh shop items
  Future<void> refreshShopItems() async {
    await _loadShopItems();
  }

  /// Lấy active items theo loại
  List<ShopItemModel> getActiveItemsByType(String itemType) {
    final currentState = state;
    if (currentState is! GlobalShopLoaded) return [];
    
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

  /// Lấy tất cả active items
  List<ShopItemModel> getAllActiveItems() {
    final currentState = state;
    if (currentState is! GlobalShopLoaded) return [];
    
    return currentState.purchasedItems
        .where((item) => item.isActive)
        .toList();
  }

  /// Reset điểm về 99999 (chỉ để test)
  Future<void> resetPointsForTest() async {
    try {
      final currentScore = HiveDataManager.getUserScore();
      final testScore = currentScore.copyWith(
        totalPoints: 99999,
        updatedAt: DateTime.now(),
      );
      await HiveDataManager.saveUserScore(testScore);
      
      // Reload để cập nhật UI
      await _loadShopItems();
      
    } catch (e) {
      emit(GlobalShopError('Lỗi reset điểm: $e'));
    }
  }

  /// Reset về điểm ban đầu (để production)
  Future<void> resetPointsToOriginal() async {
    try {
      final currentScore = HiveDataManager.getUserScore();
      final originalScore = currentScore.copyWith(
        totalPoints: 0, // Hoặc điểm ban đầu
        updatedAt: DateTime.now(),
      );
      await HiveDataManager.saveUserScore(originalScore);
      
      // Reload để cập nhật UI
      await _loadShopItems();
      
    } catch (e) {
      emit(GlobalShopError('Lỗi reset điểm: $e'));
    }
  }
}
