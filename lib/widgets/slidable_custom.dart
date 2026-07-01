import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

class SlidableCustom extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imageurl;
  final VoidCallback action1;
  final VoidCallback action2;
  final Function() onDelete;
  final Function(String newImageUrl)? onImageUpdated;

  const SlidableCustom({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageurl,
    required this.action1,
    required this.action2,
    required this.onDelete,
    this.onImageUpdated,
  }) : super(key: key);

  @override
  _SlidableCustomState createState() => _SlidableCustomState();
}

class _SlidableCustomState extends State<SlidableCustom> {
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageurl;
  }

  @override
  void didUpdateWidget(covariant SlidableCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageurl != widget.imageurl) {
      _imageUrl = widget.imageurl;
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = 'produtos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(File(pickedFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
        _isUploading = false;
      });

      widget.onImageUpdated?.call(downloadUrl);
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível enviar a imagem.')),
        );
      }
    }
  }

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
                onPressed: (context) => widget.action1(),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: _buildImage(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.accentSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_isUploading) {
      return const SizedBox(
        width: 54,
        height: 54,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accentSecondary),
        ),
      );
    }
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: _selectImage,
        child: Image.network(
          _imageUrl!,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Container(
              width: 54,
              height: 54,
              color: AppColors.surfaceHigh,
              child: const Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
            );
          },
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accentSecondary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: _selectImage,
        child: Container(
          width: 54,
          height: 54,
          color: AppColors.surfaceHigh,
          child: const Icon(Icons.photo_camera_outlined, color: AppColors.textMuted),
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          title: Text('Confirmar Exclusão', style: AppTextStyles.subheading),
          content: Text(
            'Tem certeza que deseja excluir ${widget.title}?',
            style: AppTextStyles.body,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: AppTextStyles.bodyMuted),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir', style: TextStyle(color: AppColors.danger)),
              onPressed: () {
                widget.onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
