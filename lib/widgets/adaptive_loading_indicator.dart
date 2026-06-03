import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A platform-adaptive loading indicator that shows:
/// - CupertinoActivityIndicator on iOS
/// - CircularProgressIndicator on Android and other platforms
class AdaptiveLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  final double? size;

  const AdaptiveLoadingIndicator({
    super.key,
    this.color,
    this.strokeWidth,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        color: color ?? AppColors.primary,
        radius: size != null ? size! / 2 : 10,
      );
    }

    return CircularProgressIndicator(
      color: color ?? AppColors.primary,
      strokeWidth: strokeWidth ?? 4.0,
    );
  }
}

/// A centered adaptive loading indicator with optional size constraint
class CenteredAdaptiveLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  final double? size;

  const CenteredAdaptiveLoadingIndicator({
    super.key,
    this.color,
    this.strokeWidth,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    Widget indicator = AdaptiveLoadingIndicator(
      color: color,
      strokeWidth: strokeWidth,
      size: size,
    );

    if (size != null && !Platform.isIOS) {
      indicator = SizedBox(
        width: size,
        height: size,
        child: indicator,
      );
    }

    return Center(child: indicator);
  }
}

