import 'dart:io';
import 'package:filehive/utilities/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../controllers/pdf_options_controller.dart';
import '../utilities/file_extension.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final String filePath;
  final void Function() snackBarCallback;
  const PreviewScreen(
      {super.key, required this.filePath, required this.snackBarCallback});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  bool endsWith(String absoluteFilePath, List<String> extensions) {
    return extensions.any(
      (extension) {
        return absoluteFilePath.toLowerCase().endsWith(extension.toLowerCase());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditingAllowed = ref.watch(pdfOptionsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (endsWith(widget.filePath, imageExtensions)) {
          return PhotoView(
            imageProvider: FileImage(File(widget.filePath)),
          );
        } else if (endsWith(widget.filePath, ['.pdf'])) {
          return SfPdfViewer.file(
            canShowScrollStatus: true,
            canShowSignaturePadDialog: true,
            canShowHyperlinkDialog: true,
            enableDoubleTapZooming: true,
            interactionMode: isEditingAllowed
                ? PdfInteractionMode.selection
                : PdfInteractionMode.pan,
            File(widget.filePath),
            onDocumentLoadFailed: (details) {
              snackBarText = 'Unable to load document: ${details.description}';
              widget.snackBarCallback();
            },
          );
        } else {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Bootstrap.question, size: 150),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    widget.filePath.split('\\').last,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    'Cannot preview this file at "${widget.filePath.replaceFirst(widget.filePath.split('\\').last, '')}"',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
