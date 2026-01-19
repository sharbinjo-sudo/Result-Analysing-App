import 'dart:html' as html;

void pickFile() {
  final uploadInput = html.FileUploadInputElement()..accept = '.pdf';
  uploadInput.click();
  uploadInput.onChange.listen((event) {
    final file = uploadInput.files?.first;
    if (file != null) {
      print("Selected file: ${file.name}");
    }
  });
}
