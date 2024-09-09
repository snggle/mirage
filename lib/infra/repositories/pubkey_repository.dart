import 'dart:convert';
import 'dart:io';

import 'package:mirage/infra/trezor/entity/pubkey_entity.dart';

class PubkeyRepository {
  final Directory directory;
  final File file;

  PubkeyRepository(String storagePath)
      : directory = Directory(storagePath),
        file = File('$storagePath/pubkey.json');

  Future<void> save(Map<String, dynamic> content) async {
    if (await directory.exists() == false) {
      await directory.create(recursive: true);
    }
    String jsonString = jsonEncode(content);
    await file.writeAsString(jsonString);
  }

  Future<PubkeyEntity> get() async {
    try {
      String contents = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(contents) as Map<String, dynamic>;
      return PubkeyEntity.fromJson(jsonData);
    } catch (e) {
      throw Exception('Cannot read the public key from the file');
    }
  }
}
