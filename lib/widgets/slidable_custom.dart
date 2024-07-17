import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';

class SlidableCustom extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imageurl;
  final VoidCallback action1;
  final VoidCallback action2;
  final Function() onDelete;

  const SlidableCustom({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageurl,
    required this.action1,
    required this.action2,
    required this.onDelete,
  }) : super(key: key);

  @override
  _SlidableCustomState createState() => _SlidableCustomState();
}

class _SlidableCustomState extends State<SlidableCustom> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageurl;
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => widget.action1(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
          SlidableAction(
            onPressed: () => _showDeleteConfirmationDialog(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Excluir',
          ),
        ],
      ),
      child: ListTile(
        leading: _buildImage(),
        title: Text(widget.title),
        subtitle: Text(widget.subtitle),
      ),
    );
  }

  Widget _buildImage() {
    if (_imageUrl != null) {
      return Image.network(
        _imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Icon(Icons.error, size: 50);
        },
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
      );
    } else {
      return GestureDetector(
        onTap: _selectImage,
        child: Icon(Icons.photo_camera, size: 50),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir ${widget.title}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
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
