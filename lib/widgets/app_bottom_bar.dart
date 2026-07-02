import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

/// Barra de navegação inferior própria do app, sem depender de pacote
/// externo. O botão central ("Adicionar") flutua por cima da barra —
/// como a curva de terceiros fazia, mas com cada pixel sob nosso controle.
class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const double _barHeight = 60;
  static const double _buttonSize = 58;
  static const double _totalHeight = 76;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: _barHeight,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavIcon(
                    icon: Icons.list_alt,
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  SizedBox(width: _buttonSize),
                  _NavIcon(
                    icon: Icons.person,
                    selected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 4),
                ),
                child: const Icon(Icons.add, color: AppColors.ink, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Icon(
          icon,
          size: 26,
          color: selected ? AppColors.accent : AppColors.textMuted,
        ),
      ),
    );
  }
}
