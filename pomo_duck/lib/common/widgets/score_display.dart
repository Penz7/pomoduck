import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/global_bloc/score/score_bloc.dart';
import 'package:pomo_duck/common/utils/font_size.dart';
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

  const PointsDisplay({
    super.key,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ScoreDisplay(
      showPoints: true,
      showStreak: false,
      fontSize: fontSize,
      padding: padding,
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
