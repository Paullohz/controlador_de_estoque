import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

/// Avatar de usuário reutilizável. Mostra a foto local selecionada, a foto
/// salva (URL) ou, na ausência de ambas, um ícone de usuário padrão —
/// sem depender de nenhuma imagem estática do projeto.
class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final File? localFile;
  final bool editable;
  final VoidCallback? onTap;

  const ProfileAvatar({
    Key? key,
    this.radius = 48,
    this.imageUrl,
    this.localFile,
    this.editable = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = imageUrl != null && imageUrl!.startsWith('http');

    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: localFile != null
          ? Image.file(localFile!, fit: BoxFit.cover)
          : hasNetworkImage
              ? Image.network(imageUrl!, fit: BoxFit.cover)
              : Icon(
                  Icons.person_rounded,
                  size: radius * 1.1,
                  color: AppColors.textMuted,
                ),
    );

    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (editable)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: radius * 0.56,
              height: radius * 0.56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 3),
              ),
              child: Icon(
                Icons.camera_alt,
                size: radius * 0.28,
                color: AppColors.ink,
              ),
            ),
          ),
      ],
    );

    if (!editable) return content;

    return GestureDetector(onTap: onTap, child: content);
  }
}
