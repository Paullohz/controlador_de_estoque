import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

/// Identidade visual de um produto sem depender de foto enviada: um
/// quadrado colorido com a inicial do nome, cor derivada do próprio nome
/// (o mesmo produto sempre cai na mesma cor). Se existir uma URL de imagem
/// válida (produtos antigos que já tinham foto), ela é usada no lugar.
class ProductAvatar extends StatelessWidget {
  final String nome;
  final String? imageUrl;
  final double size;
  final double radius;

  const ProductAvatar({
    Key? key,
    required this.nome,
    this.imageUrl,
    this.size = 54,
    this.radius = 12,
  }) : super(key: key);

  Color get _backgroundColor {
    final trimmed = nome.trim();
    if (trimmed.isEmpty) return AppColors.surfaceHigh;
    final sum = trimmed.toLowerCase().codeUnits.fold<int>(0, (acc, c) => acc + c);
    return AppColors.productPalette[sum % AppColors.productPalette.length];
  }

  String get _initial {
    final trimmed = nome.trim();
    return trimmed.isEmpty ? '' : trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = imageUrl != null && imageUrl!.startsWith('http');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: hasNetworkImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    if (_initial.isEmpty) {
      return Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textMuted,
        size: size * 0.42,
      );
    }
    return Text(
      _initial,
      style: GoogleFonts.spaceGrotesk(
        fontSize: size * 0.42,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }
}
