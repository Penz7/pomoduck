import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);

  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get keyboardHeight => _mediaQuery.viewInsets.bottom;

  double get topPadding => _mediaQuery.padding.top;
  double get bottomPadding => _mediaQuery.padding.bottom;

  double get paddingBottomForButton =>
      bottomPadding > 0 ? bottomPadding + 16 : 16;

  double get numberKeyboardHeight =>
      keyboardHeight == 0 ? 0 : keyboardHeight + 50;

  double get correctHeightAboveKeyboard =>
      keyboardHeight == 0 ? 35 : (keyboardHeight + 16);

  double get correctHeightAboveNumberKeyboard =>
      keyboardHeight == 0 ? 35 : (keyboardHeight + 56);
}
