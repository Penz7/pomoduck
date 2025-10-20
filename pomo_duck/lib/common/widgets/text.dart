import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../utils/font_size.dart';

class LCText extends Text {
  LCText.base(
      String text, {
        Key? key,
        double? fontSize = FontSizes.medium,
        Color? color = Colors.black,
        FontWeight? fontWeight,
        int? maxLines,
        TextAlign? textAlign,
        TextOverflow? textOverflow = TextOverflow.ellipsis,
      }) : super(
    /// can use tr() if you use multiple language
    text.tr(),
    style: TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    ),
    overflow: textOverflow,
    maxLines: maxLines,
    textAlign: textAlign,
    key: key,
  );

  LCText.medium(
      String text, {
        Key? key,
        double? fontSize = FontSizes.medium,
        Color? color = Colors.black,
        FontWeight? fontWeight = FontWeight.w500,
        int? maxLines,
        TextAlign? textAlign,
        TextOverflow? textOverflow = TextOverflow.ellipsis,
        Map<String, String>? namedArgs,
      }) : super(
    /// can use tr() if you use multiple language
    text.tr(namedArgs: namedArgs),
    style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
    maxLines: maxLines,
    key: key,
    textAlign: textAlign,
    overflow: textOverflow,
  );

  LCText.semiBold(
      String text, {
        Key? key,
        double? fontSize = FontSizes.medium,
        Color? color = Colors.black,
        FontWeight? fontWeight = FontWeight.w600,
        int? maxLines,
        TextAlign? textAlign,
        TextOverflow? textOverflow = TextOverflow.ellipsis,
        Map<String, String>? namedArgs,
      }) : super(
    /// can use tr() if you use multiple language
    text.tr(namedArgs: namedArgs),
    style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
    maxLines: maxLines,
    key: key,
    textAlign: textAlign,
    overflow: textOverflow,
  );

  LCText.bold(
      String text, {
        Key? key,
        double? fontSize = FontSizes.medium,
        Color? color = Colors.black,
        FontWeight? fontWeight = FontWeight.w700,
        int? maxLines,
        TextOverflow? textOverflow = TextOverflow.ellipsis,
        TextAlign? textAlign,
      }) : super(
    /// can use tr() if you use multiple language
    text.tr(),
    style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
    maxLines: maxLines,
    textAlign: textAlign,
    key: key,
    overflow: textOverflow,
  );
}
