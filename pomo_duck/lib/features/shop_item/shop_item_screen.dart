import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/utils/font_size.dart';
import 'package:pomo_duck/common/widgets/text.dart';
import 'package:pomo_duck/common/widgets/score_display.dart';
import 'package:pomo_duck/data/models/shop_item_model.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';
import 'package:pomo_duck/common/global_bloc/shop/global_shop_bloc.dart';

class ShopItemScreen extends StatelessWidget {
  const ShopItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: LCText.bold(
          'Cửa Hàng Vật Phẩm',
          fontSize: FontSizes.big,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: PointsDisplay(),
          ),
        ],
      ),
      body: BlocConsumer<GlobalShopBloc, GlobalShopState>(
        listener: (context, state) {
          if (state is GlobalShopPurchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mua thành công ${state.purchasedItem.name}!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is GlobalShopPurchaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is GlobalShopError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GlobalShopLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GlobalShopLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<GlobalShopBloc>().refreshShopItems();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin điểm hiện tại
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Assets.images.duckCoin.image(
                            width: 32,
                            height: 32,
                          ),
                          12.width,
                          LCText.bold(
                            'Điểm hiện tại: ${state.userPoints}',
                            fontSize: FontSizes.medium,
                            color: Colors.blue.shade800,
                          ),
                        ],
                      ),
                    ),
                    20.height,
                    
                    // Vật phẩm đã mua
                    if (state.purchasedItems.isNotEmpty) ...[
                      LCText.bold(
                        'Vật Phẩm Đã Mua',
                        fontSize: FontSizes.big,
                      ),
                      12.height,
                      ...state.purchasedItems.map((item) => _buildPurchasedItemCard(context, item)),
                      20.height,
                    ],
                    
                    // Cửa hàng - luôn hiển thị tất cả items
                    LCText.bold(
                      'Cửa Hàng',
                      fontSize: FontSizes.big,
                    ),
                    12.height,
                    // Hiển thị tất cả items (cả available và purchased)
                    ...state.availableItems.map((item) => _buildAvailableItemCard(context, item, state)),
                    ...state.purchasedItems.map((item) => _buildAvailableItemCard(context, item, state)),
                  ],
                ),
              ),
            );
          } else if (state is GlobalShopError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  16.height,
                  LCText.medium(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
                  16.height,
                  ElevatedButton(
                    onPressed: () {
                      context.read<GlobalShopBloc>().refreshShopItems();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPurchasedItemCard(BuildContext context, ShopItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.isActive ? Colors.green.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getItemIcon(item.itemType),
                color: item.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                size: 24,
              ),
            ),
            12.width,
            
            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LCText.semiBold(
                    item.name,
                    fontSize: FontSizes.medium,
                  ),
                  4.height,
                  LCText.medium(
                    item.description,
                    fontSize: FontSizes.small,
                    color: Colors.grey.shade600,
                    maxLines: 2,
                  ),
                  8.height,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LCText.medium(
                          'Đã mua: ${item.quantity}',
                          fontSize: FontSizes.small,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableItemCard(BuildContext context, ShopItemModel item, GlobalShopLoaded state) {
    final canAfford = state.userPoints >= item.price;
    final hasQuantity = item.quantity > 0;
    final isShieldMaxed = item.itemType == 'shield' && item.quantity >= 3;
    final isBuyEnabled = canAfford && !isShieldMaxed;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isShieldMaxed
                    ? Colors.grey.shade200
                    : (canAfford ? Colors.blue.shade100 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getItemIcon(item.itemType),
                color: isShieldMaxed
                    ? Colors.grey.shade500
                    : (canAfford ? Colors.blue.shade700 : Colors.grey.shade600),
                size: 24,
              ),
            ),
            12.width,
            
            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LCText.semiBold(
                        item.name,
                        fontSize: FontSizes.medium,
                      ),
                      if (hasQuantity) ...[
                        8.width,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: LCText.medium(
                            'x${item.quantity}',
                            fontSize: FontSizes.small,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  4.height,
                  LCText.medium(
                    item.description,
                    fontSize: FontSizes.small,
                    color: Colors.grey.shade600,
                    maxLines: 2,
                  ),
                  8.height,
                  Row(
                    children: [
                      Assets.images.duckCoin.image(
                        width: 16,
                        height: 16,
                      ),
                      4.width,
                      LCText.semiBold(
                        '${item.price}',
                        fontSize: FontSizes.small,
                        color: isShieldMaxed
                            ? Colors.grey.shade600
                            : (canAfford ? Colors.blue.shade700 : Colors.red.shade600),
                      ),
                      if (item.itemType == 'shield') ...[
                        8.width,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isShieldMaxed ? Colors.red.shade50 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: LCText.medium(
                            isShieldMaxed ? 'Tối đa 3' : 'Tối đa 3',
                            fontSize: FontSizes.small,
                            color: isShieldMaxed ? Colors.red.shade700 : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Buy button
            ElevatedButton(
              onPressed: isBuyEnabled ? () {
                context.read<GlobalShopBloc>().purchaseItem(item);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isBuyEnabled ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: LCText.medium(
                isShieldMaxed
                    ? 'Đã tối đa'
                    : (canAfford ? 'Mua' : 'Không đủ điểm'),
                fontSize: FontSizes.small,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getItemIcon(String itemType) {
    switch (itemType) {
      case 'shield':
        return Icons.shield;
      case 'sword':
        return Icons.flash_on;
      case 'coffee':
        return Icons.local_cafe;
      default:
        return Icons.shopping_bag;
    }
  }
}