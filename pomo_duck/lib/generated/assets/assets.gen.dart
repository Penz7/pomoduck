/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/background.jpg
  AssetGenImage get background =>
      const AssetGenImage('assets/images/background.jpg');

  /// File path: assets/images/border_button.png
  AssetGenImage get borderButton =>
      const AssetGenImage('assets/images/border_button.png');

  /// File path: assets/images/duck.png
  AssetGenImage get duck => const AssetGenImage('assets/images/duck.png');

  /// File path: assets/images/duck_focus.png
  AssetGenImage get duckFocus =>
      const AssetGenImage('assets/images/duck_focus.png');

  /// File path: assets/images/duck_pause.png
  AssetGenImage get duckPause =>
      const AssetGenImage('assets/images/duck_pause.png');

  /// File path: assets/images/duck_sport.png
  AssetGenImage get duckSport =>
      const AssetGenImage('assets/images/duck_sport.png');

  /// File path: assets/images/duck_study.png
  AssetGenImage get duckStudy =>
      const AssetGenImage('assets/images/duck_study.png');

  /// File path: assets/images/duck_tag.png
  AssetGenImage get duckTag =>
      const AssetGenImage('assets/images/duck_tag.png');

  /// File path: assets/images/ic_check.png
  AssetGenImage get icCheck =>
      const AssetGenImage('assets/images/ic_check.png');

  /// File path: assets/images/ic_left.png
  AssetGenImage get icLeft => const AssetGenImage('assets/images/ic_left.png');

  /// File path: assets/images/ic_pause.png
  AssetGenImage get icPause =>
      const AssetGenImage('assets/images/ic_pause.png');

  /// File path: assets/images/ic_play.png
  AssetGenImage get icPlay => const AssetGenImage('assets/images/ic_play.png');

  /// File path: assets/images/ic_right.png
  AssetGenImage get icRight =>
      const AssetGenImage('assets/images/ic_right.png');

  /// Directory path: assets/images/navigation
  $AssetsImagesNavigationGen get navigation =>
      const $AssetsImagesNavigationGen();

  /// List of all assets
  List<AssetGenImage> get values => [
        background,
        borderButton,
        duck,
        duckFocus,
        duckPause,
        duckSport,
        duckStudy,
        duckTag,
        icCheck,
        icLeft,
        icPause,
        icPlay,
        icRight
      ];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/en-US.json
  String get enUS => 'assets/translations/en-US.json';

  /// File path: assets/translations/vi-VN.json
  String get viVN => 'assets/translations/vi-VN.json';

  /// List of all assets
  List<String> get values => [enUS, viVN];
}

class $AssetsImagesNavigationGen {
  const $AssetsImagesNavigationGen();

  /// File path: assets/images/navigation/ic_home.png
  AssetGenImage get icHome =>
      const AssetGenImage('assets/images/navigation/ic_home.png');

  /// File path: assets/images/navigation/ic_home_active.png
  AssetGenImage get icHomeActive =>
      const AssetGenImage('assets/images/navigation/ic_home_active.png');

  /// File path: assets/images/navigation/ic_setting.png
  AssetGenImage get icSetting =>
      const AssetGenImage('assets/images/navigation/ic_setting.png');

  /// File path: assets/images/navigation/ic_setting_active.png
  AssetGenImage get icSettingActive =>
      const AssetGenImage('assets/images/navigation/ic_setting_active.png');

  /// File path: assets/images/navigation/ic_stats.png
  AssetGenImage get icStats =>
      const AssetGenImage('assets/images/navigation/ic_stats.png');

  /// File path: assets/images/navigation/ic_stats_active.png
  AssetGenImage get icStatsActive =>
      const AssetGenImage('assets/images/navigation/ic_stats_active.png');

  /// File path: assets/images/navigation/ic_time_line.png
  AssetGenImage get icTimeLine =>
      const AssetGenImage('assets/images/navigation/ic_time_line.png');

  /// File path: assets/images/navigation/ic_time_line_active.png
  AssetGenImage get icTimeLineActive =>
      const AssetGenImage('assets/images/navigation/ic_time_line_active.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        icHome,
        icHomeActive,
        icSetting,
        icSettingActive,
        icStats,
        icStatsActive,
        icTimeLine,
        icTimeLineActive
      ];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
