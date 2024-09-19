import 'dart:convert';
import 'dart:io';

import 'package:mirage/infra/entity/pubkey_entity.dart';

class PubkeyRepository {
  final Directory directory;
  final File file;

  PubkeyRepository(String storagePath)
      : directory = Directory(storagePath),
        file = File('$storagePath/pubkey.json');

  Future<PubkeyEntity> get() async {
    try {
      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return PubkeyEntity.fromJson(jsonData);
    } catch (e) {
      throw Exception('Cannot read the public key from the file');
    }
  }

  Future<void> save(Map<String, dynamic> content) async {
    if (await directory.exists() == false) {
      await directory.create(recursive: true);
    }
    String jsonString = jsonEncode(content);
    await file.writeAsString(jsonString);
  }
}
