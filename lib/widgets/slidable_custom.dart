import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:flutter_shiftsync/widgets/app_dialogs.dart';
import 'package:flutter_shiftsync/widgets/product_avatar.dart';

class SlidableCustom extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageurl;
  final bool favorito;
  final Color? subtitleColor;
  final VoidCallback action1;
  final VoidCallback action2;
  final Function() onDelete;
  final VoidCallback? onToggleFavorite;

  const SlidableCustom({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageurl,
    this.favorito = false,
    this.subtitleColor,
    required this.action1,
    required this.action2,
    required this.onDelete,
    this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Slidable(
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => action1(),
                backgroundColor: AppColors.accentSecondary,
                foregroundColor: AppColors.ink,
                icon: Icons.edit,
                label: 'Editar',
              ),
              SlidableAction(
                onPressed: (context) => _showDeleteConfirmationDialog(context),
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Excluir',
              ),
            ],
          ),
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                ProductAvatar(nome: title, imageUrl: imageurl, size: 54, radius: AppRadius.sm),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.body.copyWith(
                          color: subtitleColor ?? AppColors.accentSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    favorito ? Icons.star_rounded : Icons.star_border_rounded,
                    color: favorito ? AppColors.accent : AppColors.textMuted,
                  ),
                  tooltip: favorito ? 'Remover dos favoritos' : 'Marcar como favorito',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Excluir produto',
      message: 'Tem certeza que deseja excluir "$title"? Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed) {
      onDelete();
    }
  }
}
