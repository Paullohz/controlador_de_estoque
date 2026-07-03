import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

/// Diálogos e mensagens padrão do app: ícone dentro de um círculo colorido,
/// título e mensagem — sempre com a mesma cara, pra nenhuma tela usar o
/// AlertDialog/SnackBar cru (sem tema) do Flutter.

/// Diálogo base de feedback (sucesso, aviso ou erro), com um botão de ação.
/// [extra] permite embutir conteúdo extra abaixo da mensagem (ex.: um
/// resumo com valores), quando o texto sozinho não é suficiente.
Future<void> showAppMessageDialog(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String message,
  String buttonLabel = 'OK',
  Widget? extra,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.subheading, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
          if (extra != null) ...[
            const SizedBox(height: 16),
            extra,
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            buttonLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

/// Confirmação de sucesso — verde de marca.
Future<void> showAppSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'OK',
  Widget? extra,
  IconData icon = Icons.check_rounded,
}) {
  return showAppMessageDialog(
    context,
    icon: icon,
    color: AppColors.accent,
    title: title,
    message: message,
    buttonLabel: buttonLabel,
    extra: extra,
  );
}

/// Aviso que exige atenção antes de continuar — âmbar.
Future<void> showAppWarningDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'Entendi',
  IconData icon = Icons.warning_amber_rounded,
}) {
  return showAppMessageDialog(
    context,
    icon: icon,
    color: AppColors.warning,
    title: title,
    message: message,
    buttonLabel: buttonLabel,
  );
}

/// Erro — vermelho, só pra falhas de verdade (nunca cor de marca).
Future<void> showAppErrorDialog(
  BuildContext context, {
  String title = 'Algo deu errado',
  required String message,
  String buttonLabel = 'OK',
  IconData icon = Icons.error_outline_rounded,
}) {
  return showAppMessageDialog(
    context,
    icon: icon,
    color: AppColors.danger,
    title: title,
    message: message,
    buttonLabel: buttonLabel,
  );
}

/// Diálogo de confirmação (pergunta) no mesmo padrão visual — usado antes
/// de ações destrutivas, como excluir um produto. Retorna `true` só se o
/// usuário confirmar.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  Color confirmColor = AppColors.danger,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: confirmColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: confirmColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.subheading, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel,
            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// SnackBar temático, pra feedback rápido que não precisa travar a tela
/// com um diálogo (ex.: uma ação em segundo plano que falhou).
void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isError ? AppColors.danger : AppColors.surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      content: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: isError ? Colors.white : AppColors.textLight,
        ),
      ),
    ),
  );
}
