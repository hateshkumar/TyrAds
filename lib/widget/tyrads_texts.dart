import 'package:flutter/material.dart';

class TyrAdsText extends Text {
  TyrAdsText.headerText({
    super.key,
    String? text,
    double? fontSize,
    TextAlign? textAlign,
    Color? color,
  }) : super(text!,
            textAlign: textAlign ?? TextAlign.center,
            style: TextStyle(fontSize: fontSize, color: color));

  TyrAdsText.subHeaderText({
    super.key,
    String? text,
    int? maxLines,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    double? letterSpacing,
    double? wordSpacing,
    TextDecoration? textDecoration,
  }) : super(text!,
            maxLines: maxLines,
            textAlign: textAlign ?? TextAlign.center,
            overflow: overflow ?? TextOverflow.visible,
            style: TextStyle(
                color: color ?? const Color(0xff000000),
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.normal,
                letterSpacing: letterSpacing,
                wordSpacing: wordSpacing,
                decoration: textDecoration));
}
