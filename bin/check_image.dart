import 'dart:io';

void main() async {
  final file = File('assets/background/maimaidx/utage/floor.webp');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }

  // Actually we can't easily parse webp dimensions in dart without a library.
  // How about just reading its size in bytes
  final bytes = file.readAsBytesSync();
  print('Size: ${bytes.length} bytes');
}
