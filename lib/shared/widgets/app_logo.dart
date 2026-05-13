import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Logo de AquaSave que se adapta al tema: usa la versión en blanco cuando la
/// app está en modo oscuro y la versión a color en modo claro.
class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? AppConstants.imgAquaSaveLogoWhite : AppConstants.imgAquaSaveLogo,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
