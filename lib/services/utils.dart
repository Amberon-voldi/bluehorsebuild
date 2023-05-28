import 'dart:developer';

import 'package:file_selector/file_selector.dart';

class Utils {
  Future<XFile?> fileSelector() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'pdf',
          extensions: ['pdf'],
        ),
      ],
    );
    if (file == null) {
      log("User canceled the file selection");
      return null;
    }
    return file;
  }
}
