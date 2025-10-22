import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/global_bloc/score/score_bloc.dart';
import 'package:pomo_duck/common/utils/font_size.dart';
import 'package:pomo_duck/common/global_bloc/shop/global_shop_bloc.dart';
import 'package:pomo_duck/common/widgets/text.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';

class ScoreDisplay extends StatelessWidget {
  final bool showPoints;
  final bool showStreak;
  final double? fontSize;
  final EdgeInsets? padding;

  const ScoreDisplay({
    super.key,
    this.showPoints = true,
    this.showStreak = true,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreBloc, ScoreState>(
      builder: (context, state) {
        if (state is ScoreLoaded) {
          int shieldCount = 0;
          // Lấy số khiên từ GlobalShopBloc nếu có
          final shopState = context.read<GlobalShopBloc>().state;
          if (shopState is GlobalShopLoaded) {
            final merged = [...shopState.availableItems, ...shopState.purchasedItems];
            final shields = merged.where((i) => i.itemType == 'shield');
            if (shields.isNotEmpty) {
              shieldCount = shields.first.quantity;
            }
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPoints) ...[
                LCText.semiBold(
                  '${state.totalPoints}',
                  fontSize: FontSizes.big,
                ),
                Assets.images.duckCoin.image(
                  width: fontSize ?? FontSizes.big,
                  height: fontSize ?? FontSizes.big,
                ),
                if (showStreak) 10.width,
              ],
              if (showStreak) ...[
                LCText.semiBold(
                  '${state.currentStreak}',
                  fontSize: FontSizes.big,
                ),
                Assets.images.icStreak.image(
                  width: fontSize ?? FontSizes.big,
                  height: fontSize ?? FontSizes.big,
                ),
                if (shieldCount > 0) ...[
                  6.width,
                  const Icon(Icons.shield, size: 18, color: Colors.blueGrey),
                  2.width,
                  LCText.semiBold('x$shieldCount', fontSize: FontSizes.small),
                ],
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class PointsDisplay extends StatelessWidget {
  final double? fontSize;
  final EdgeInsets? padding;
  final bool isClickable;

  const PointsDisplay({
    super.key,
    this.fontSize,
    this.padding,
    this.isClickable = true,
  });

  @override
  Widget build(BuildContext context) {
    final display = ScoreDisplay(
      showPoints: true,
      showStreak: false,
      fontSize: fontSize,
      padding: padding,
    );

    if (!isClickable) return display;

    return GestureDetector(
      onTap: () {
        // Navigate to shop screen
        context.go('/home/shop');
      },
      child: display,
    );
  }
}

class StreakDisplay extends StatelessWidget {
  final double? fontSize;
  final EdgeInsets? padding;

  const StreakDisplay({
    super.key,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ScoreDisplay(
      showPoints: false,
      showStreak: true,
      fontSize: fontSize,
      padding: padding,
    );
  }
}
