import 'dart:io';

import 'package:flutter/material.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';
import 'queue.dart';

import '../models/todo_item.dart';
import 'camera_helpers.dart';
import 'photo_capture_widget.dart';

class PhotoWidget extends StatefulWidget {
  final TodoItem todo;

  PhotoWidget({
    required this.todo,
  }) : super(key: ObjectKey(todo.id));

  @override
  State<StatefulWidget> createState() {
    return _PhotoWidgetState();
  }
}

class _ResolvedPhotoState {
  String? photoPath;
  bool fileExists;
  Attachment? attachment;

  _ResolvedPhotoState(
      {required this.photoPath, required this.fileExists, this.attachment});
}

class _PhotoWidgetState extends State<PhotoWidget> {
  late String photoPath;

  Future<_ResolvedPhotoState> _getPhotoState(photoId) async {
    if (photoId == null) {
      return _ResolvedPhotoState(photoPath: null, fileExists: false);
    }
    photoPath = await attachmentQueue.getLocalUri('$photoId.jpg');

    bool fileExists = await File(photoPath).exists();

    final row = await attachmentQueue.db
        .getOptional('SELECT * FROM attachments_queue WHERE id = ?', [photoId]);

    if (row != null) {
      Attachment attachment = Attachment.fromRow(row);
      return _ResolvedPhotoState(
          photoPath: photoPath, fileExists: fileExists, attachment: attachment);
    }

    return _ResolvedPhotoState(
        photoPath: photoPath, fileExists: fileExists, attachment: null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPhotoState(widget.todo.photoId),
        builder: (BuildContext context,
            AsyncSnapshot<_ResolvedPhotoState> snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          final data = snapshot.data!;
          Widget takePhotoButton = ElevatedButton(
            onPressed: () async {
              final camera = await setupCamera();
              if (!context.mounted) return;

              if (camera == null) {
                const snackBar = SnackBar(
                  content: Text('No camera available'),
                  backgroundColor:
                      Colors.red, // Optional: to highlight it's an error
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TakePhotoWidget(todoId: widget.todo.id, camera: camera),
                ),
              );
            },
            child: const Text('Take Photo'),
          );

          if (widget.todo.photoId == null) {
            return takePhotoButton;
          }

          String? filePath = data.photoPath;
          bool fileIsDownloading = !data.fileExists;
          bool fileArchived =
              data.attachment?.state == AttachmentState.archived.index;

          if (fileArchived) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Unavailable"),
                const SizedBox(height: 8),
                takePhotoButton
              ],
            );
          }

          if (fileIsDownloading) {
            return const Text("Downloading...");
          }

          File imageFile = File(filePath!);
          int lastModified = imageFile.existsSync()
              ? imageFile.lastModifiedSync().millisecondsSinceEpoch
              : 0;
          Key key = ObjectKey('$filePath:$lastModified');

          return Image.file(
            key: key,
            imageFile,
            width: 50,
            height: 50,
          );
        });
  }
}
