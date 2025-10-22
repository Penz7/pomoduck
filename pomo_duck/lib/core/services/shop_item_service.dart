import 'package:pomo_duck/data/database/database_helper.dart';
import 'package:pomo_duck/data/models/shop_item_model.dart';
import 'package:pomo_duck/common/global_bloc/shop/global_shop_bloc.dart';

/// Service quản lý shop items và effects
class ShopItemService {
  static final ShopItemService _instance = ShopItemService._internal();
  static ShopItemService get instance => _instance;
  
  ShopItemService._internal();

  /// Lấy tất cả active shop items
  Future<List<ShopItemModel>> getActiveShopItems() async {
    try {
      return await DatabaseHelper.instance.getActiveShopItems();
    } catch (e) {
      return [];
    }
  }

  /// Kiểm tra có active shield không
  Future<bool> hasActiveShield() async {
    final activeItems = await getActiveShopItems();
    return activeItems.any((item) => item.itemType == 'shield' && item.isActive);
  }

  /// Kiểm tra có active sword không
  Future<bool> hasActiveSword() async {
    final activeItems = await getActiveShopItems();
    return activeItems.any((item) => item.itemType == 'sword' && item.isActive);
  }

  /// Kiểm tra có active coffee không
  Future<bool> hasActiveCoffee() async {
    final activeItems = await getActiveShopItems();
    return activeItems.any((item) => item.itemType == 'coffee' && item.isActive);
  }

  /// Áp dụng sword effect - giảm thời gian work session
  Future<int> applySwordEffect(int originalDuration) async {
    final hasSword = await hasActiveSword();
    if (hasSword) {
      // Giảm 5 phút (300 giây)
      return (originalDuration - 300).clamp(60, originalDuration); // Tối thiểu 1 phút
    }
    return originalDuration;
  }

  /// Áp dụng coffee effect - tăng thời gian break session
  Future<int> applyCoffeeEffect(int originalDuration) async {
    final hasCoffee = await hasActiveCoffee();
    if (hasCoffee) {
      // Tăng 5 phút (300 giây)
      return originalDuration + 300;
    }
    return originalDuration;
  }

  /// Kiểm tra có thể bỏ qua penalty khi dừng giữa chừng
  Future<bool> canSkipStopPenalty(GlobalShopBloc? globalShopBloc) async {
    if (globalShopBloc == null) return false;
    
    final hasShield = globalShopBloc.hasActiveShield();
    if (hasShield) {
      // Sử dụng shield và deactivate nó
      final activeShields = globalShopBloc.getActiveItemsByType('shield');
      if (activeShields.isNotEmpty) {
        await globalShopBloc.useItem(activeShields.first);
      }
      return true;
    }
    return false;
  }

  /// Lấy thông tin shop items cho debug
  Future<Map<String, bool>> getShopItemsStatus() async {
    return {
      'shield': await hasActiveShield(),
      'sword': await hasActiveSword(),
      'coffee': await hasActiveCoffee(),
    };
  }
}
