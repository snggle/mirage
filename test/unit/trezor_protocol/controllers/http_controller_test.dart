import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_http_controller.dart';

void main() async {
  final ReceivePort receivePort = ReceivePort();

  await Isolate.spawn(_runServer, receivePort.sendPort);
  await receivePort.first;
  _runIntegrationTests();
}

Future<void> _runServer(SendPort sendPort) async {
  await initLocator();

  try {
    HttpServer server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      21325,
    );

    AppLogger().log(message: 'Running HTTP server on localhost:${server.port}');

    sendPort.send(true);

    await for (HttpRequest request in server) {
      globalLocator<TrezorHttpController>().handleRequest(request);
    }
  } on SocketException catch (e) {
    if (e.osError?.errorCode == 48 || e.osError?.errorCode == 98) {
      AppLogger().log(message: 'Port 21325 is already in use. Please close the application using this port or try "sudo fuser -k 21325/tcp".');
    } else {
      AppLogger().log(message: 'Failed to bind the HTTP server: $e');
    }
  } catch (e) {
    AppLogger().log(message: 'An unexpected error occurred: $e');
  }
}

void _runIntegrationTests() {
  group('Should test different HTTP methods', () {
    const String actualHost = '127.0.0.1';
    const int actualPort = 21325;
    const String actualPath = '/';

    test('Should [return statusCode = 405] for the GET request', () async {
      // Arrange
      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.getUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the DELETE request', () async {
      // Arrange
      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.deleteUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the HEAD request', () async {
      // Arrange
      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.headUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the PATCH request', () async {
      // Arrange
      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.patchUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the PUT request', () async {
      // Arrange
      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.putUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 200] for the POST request', () async {
      // Arrange
      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 200;
      expect(actualStatusCode, expectedStatusCode);
    });
  });
}
