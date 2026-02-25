import 'dart:io';
void main() {
  var lines = File(r'c:\Users\HP\Documents\Flutter\AutoMate\test\widget_test.dart').readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    print('${i+1} ${lines[i]}');
  }
}
