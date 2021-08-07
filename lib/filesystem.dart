import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class file {
  String fileData = "";
  List<String> _messages = [];
  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/demoTextFile.txt';
    print(filePath);
    return filePath;
  }

  void saveFile(List<ChatMessage> _messages) async {
    File file = File(await getFilePath());
    String data = "";
    for (int i = 0; i < _messages.length; i++) {
      data = data + _messages[i].text + "\n";
    }
    fileData = data;
    file.writeAsString(data, mode: FileMode.write);
  }

  void addToFile(String message) async {
    File file = File(await getFilePath());
    file.writeAsString("\n" + message, mode: FileMode.append);
  }

  void readFile() async {
    File file = File(await getFilePath());
    String fileContent = await file.readAsString();
    fileData = fileContent;
    print('File Content: $fileContent');
  }

  Future<void> load() async {
    File file = File(await getFilePath());
    String fileContent = await file.readAsString();
    fileData = fileContent;
  }

  Future<void> start() {
    return f.load().then((value) => {loadList()});
  }

  void loadList() {
    print("this is fileData $fileData");
    _messages = fileData.split("\n");
    for (int i = _messages.length - 1; i >= 0; i--)
      if (_messages[i].isEmpty) _messages.removeAt(i);
    print("this is _messages $_messages");
  }

  List<String> get() {
    return _messages;
  }
}
