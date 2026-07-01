import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

/// Wordmark da marca "StockHub". Bicolor (branco + verde-esmeralda),
/// em Space Grotesk bold, para funcionar em qualquer fundo escuro do app
/// sem depender de nenhum arquivo de imagem/SVG.
class AppLogo extends StatelessWidget {
  /// Tamanho de referência do wordmark (equivalente ao antigo `height`
  /// do SVG). O tamanho da fonte é derivado a partir daqui.
  final double height;

  const AppLogo({Key? key, this.height = 40}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = height * 0.75;
    final style = GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Stock', style: style.copyWith(color: AppColors.textLight)),
          TextSpan(text: 'Hub', style: style.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }
}
