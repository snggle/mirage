import 'dart:io';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/infra/dto/a_resp_dto.dart';

class TrezorHttpRepository {
  Future<void> respondOk(HttpRequest request, ARespDto? respModel) async {
    try {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.set('Access-Control-Allow-Origin', 'https://connect.trezor.io')
        ..headers.contentType = ContentType.text
        ..write(respModel?.toPlaintext());
      await request.response.close();
    } catch (e) {
      AppLogger().log(message: 'Failed to respond to the request: $e');
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