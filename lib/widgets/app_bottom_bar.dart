import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

/// Barra de navegação inferior própria do app, sem depender de pacote
/// externo. Nenhum tamanho é fixo — a barra cresce a partir do próprio
/// conteúdo (ícone + rótulo) e usa SafeArea para lidar com o inset inferior
/// de cada aparelho, então se adapta tanto a telas pequenas quanto a
/// aparelhos com área segura maior, como o iPhone 16 Pro.
///
/// A cor de fundo é AppColors.ink (a mesma da página, nunca a mesma dos
/// campos de formulário, que usam surface/surfaceHigh) — de propósito, pra
/// nunca se confundir visualmente com um card ou input. Uma borda verde
/// sutil + sombra dão o contorno que separa a barra da página por trás.
class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const _items = [
    (icon: Icons.list_alt_rounded, label: 'Produtos'),
    (icon: Icons.add_rounded, label: 'Adicionar'),
    (icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.accent.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: selected ? AppColors.textLight : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          color: selected ? AppColors.textLight : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
