import 'dart:io';
import 'package:mirage/shared/resp_model/a_resp_model.dart';

// ignore_for_file: avoid_print
class TrezorHttpRepository {
  Future<void> respondOk(HttpRequest request, ARespModel? respModel) async {
    try {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.set('Access-Control-Allow-Origin', 'https://connect.trezor.io')
        ..headers.contentType = ContentType.text
        ..write(respModel?.toPlaintext());
      await request.response.close();
    } catch (e) {
      print('Failed to respond to the request: $e');
    }
  }

  Future<void> respondNotAllowed(HttpRequest request) async {
    request.response
      ..statusCode = HttpStatus.methodNotAllowed
      ..write('Method not allowed');
    await request.response.close();
  }

  Future<void> respondNotFound(HttpRequest request) async {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Unknown request\n');
    await request.response.close();
  }

  Future<void> respondInternalError(HttpRequest request) async {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write('Internal Server Error\n');
    await request.response.close();
  }
}