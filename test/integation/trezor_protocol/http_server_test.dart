import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_http_controller.dart';

import '../../utils/test_utils.dart';

void main() async {
  final ReceivePort receivePort = ReceivePort();

  await Isolate.spawn(_runServer, receivePort.sendPort);
  await receivePort.first;
  await _runIntegrationTests();
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

Future<void> _runIntegrationTests() async {
  group('Should test the HTTP server process', () {
    const String actualHost = '127.0.0.1';
    const int actualPort = 21325;

    test('Should [return version and githash] for the request with EMPTY path', () async {
      // Arrange

      const String actualPath = '/';
      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));
      _setHeaders(actualRequest);

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      String actualResponseContent = await actualResponse.transform(const Utf8Decoder()).join();
      actualClient.close();

      // Assert
      String expectedResponseContent = '{"version":"2.0.34","githash":"e83287a"}\n';

      expect(actualResponseContent, expectedResponseContent);
    });

    test('Should [return JSON with session == null] for the request with ENUMERATE path', () async {
      // Arrange
      const String actualPath = '/enumerate';

      HttpClient actualClient = HttpClient();
      HttpClientRequest actualRequest = await actualClient.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPath'));
      _setHeaders(actualRequest);

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      String actualResponseContent = await actualResponse.transform(const Utf8Decoder()).join();
      actualClient.close();

      // Assert
      String expectedResponseContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":null,"debugSession":null}]\n';

      expect(actualResponseContent, expectedResponseContent);
    });

    test('Should handle request with ACQUIRE path wrapped in a request with LISTEN path (session 1)', () async {
      // Arrange
      const String actualPathListen = '/listen';

      const String actualBodyListen = '[{"path":"1","session":null,"product":0,"vendor":0,"debug":false,"debugSession":null}]';
      HttpClient actualClientListen = HttpClient();
      HttpClientRequest actualRequestListen = await actualClientListen.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathListen'));
      _setHeaders(actualRequestListen, contentLength: actualBodyListen.length);
      actualRequestListen.write(actualBodyListen);

      const String actualPathAcquire = '/acquire/1/null';
      HttpClient actualClientAcquire = HttpClient();
      HttpClientRequest actualRequestAcquire = await actualClientAcquire.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathAcquire'));
      _setHeaders(actualRequestAcquire);

      // Act
      HttpClientResponse actualResponseAcquire = await actualRequestAcquire.close();
      String actualResponseAcquireContent = await actualResponseAcquire.transform(const Utf8Decoder()).join();
      actualClientAcquire.close();

      // Assert
      String expectedResponseAcquireContent = '{"session":"1"}\n';

      TestUtils.printInfo('Should [return session = 1] as a first session');
      expect(actualResponseAcquireContent, expectedResponseAcquireContent);

      // ************************************************************************

      // Act
      HttpClientResponse actualResponseListen = await actualRequestListen.close();
      String actualResponseListenContent = await actualResponseListen.transform(const Utf8Decoder()).join();
      actualClientListen.close();

      // Assert
      String expectedResponseListenContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":"1","debugSession":null}]\n';

      TestUtils.printInfo('Should [return JSON with session = 1]');
      expect(actualResponseListenContent, expectedResponseListenContent);
    });

    test('Should handle request with CALL path wrapped in a request with LISTEN path (session 1)', () async {
      // Arrange
      const String actualPathListen = '/listen';

      const String actualBodyListen = '[{"path":"1","session":"1","product":0,"vendor":0,"debug":false,"debugSession":null}]';
      HttpClient actualClientListen = HttpClient();
      HttpClientRequest actualRequestListen = await actualClientListen.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathListen'));
      _setHeaders(actualRequestListen, contentLength: actualBodyListen.length);
      actualRequestListen.write(actualBodyListen);

      const String actualPathCall = '/call/1';
      String actualBodyCall = '003700000000';
      HttpClient actualClientCall = HttpClient();
      HttpClientRequest actualRequestCall = await actualClientCall.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathCall'));
      _setHeaders(actualRequestCall, contentLength: actualBodyCall.length);
      actualRequestCall.write(actualBodyCall);

      // Act
      HttpClientResponse actualResponseCall = await actualRequestCall.close();
      String actualResponseCallContent = await actualResponseCall.transform(const Utf8Decoder()).join();
      actualClientCall.close();

      // Assert
      String expectedResponseCallContent =
          '0011000000e80a097472657a6f722e696f1002180820013218333535433831373531304330454142463246313437313435380140014a05656e2d555352094d79205472657a6f7260016a14c7832c39ab3c2a9c46544c57d1a8980583609f47800101980100a00100aa010154ca0108454d554c41544f52d80100e00100e80100f00101f00102f00103f00104f00105f00107f00109f0010bf0010cf0010df0010ef0010ff00110f00111f00112f00113f0010af00106f80100800201880200900200a00200a80200b002c0cf24b80200c00200c80200d00202d80200e2020454325431f802f0018003f001900301';

      TestUtils.printInfo('Should [return proto buffer]');
      expect(actualResponseCallContent, expectedResponseCallContent);

      // ************************************************************************

      // Arrange
      String actualPathRelease = '/release/1';

      HttpClient actualClientRelease = HttpClient();
      HttpClientRequest actualRequestRelease = await actualClientRelease.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathRelease'));
      _setHeaders(actualRequestRelease);

      // Act
      HttpClientResponse actualResponseRelease = await actualRequestRelease.close();
      String actualResponseReleaseContent = await actualResponseRelease.transform(const Utf8Decoder()).join();
      actualClientRelease.close();

      // Assert
      String expectedResponseReleaseContent = '{"session":"1"}\n';

      TestUtils.printInfo('Should [return session = 1]');
      expect(actualResponseReleaseContent, expectedResponseReleaseContent);

      // ************************************************************************

      // Act
      HttpClientResponse actualResponseListen = await actualRequestListen.close();
      String actualResponseListenContent = await actualResponseListen.transform(const Utf8Decoder()).join();
      actualClientListen.close();

      // Assert
      String expectedResponseListenContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":null,"debugSession":null}]\n';

      TestUtils.printInfo('Should [return JSON with session = null]');
      expect(actualResponseListenContent, expectedResponseListenContent);
    });

    test('Should handle request with ACQUIRE path wrapped in a request with LISTEN path (session 2)', () async {
      // Arrange
      const String actualPathListen = '/listen';

      const String actualBodyListen = '[{"path":"1","session":null,"product":0,"vendor":0,"debug":false,"debugSession":null}]';
      HttpClient actualClientListen = HttpClient();
      HttpClientRequest actualRequestListen = await actualClientListen.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathListen'));
      _setHeaders(actualRequestListen, contentLength: actualBodyListen.length);
      actualRequestListen.write(actualBodyListen);

      const String actualPathAcquire = '/acquire/1/1';
      HttpClient actualClientAcquire = HttpClient();
      HttpClientRequest actualRequestAcquire = await actualClientAcquire.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathAcquire'));
      _setHeaders(actualRequestAcquire);

      // Act
      HttpClientResponse actualResponseAcquire = await actualRequestAcquire.close();
      String actualResponseAcquireContent = await actualResponseAcquire.transform(const Utf8Decoder()).join();
      actualClientAcquire.close();

      // Assert
      String expectedAcquireResponseContent = '{"session":"2"}\n';

      TestUtils.printInfo('Should [return session = 2]');
      expect(actualResponseAcquireContent, expectedAcquireResponseContent);

      // ************************************************************************

      // Act
      HttpClientResponse actualResponseListen = await actualRequestListen.close();
      String actualResponseListenContent = await actualResponseListen.transform(const Utf8Decoder()).join();
      actualClientListen.close();

      // Assert
      String expectedResponseListenContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":"2","debugSession":null}]\n';

      TestUtils.printInfo('Should [return JSON with session = 2]');
      expect(actualResponseListenContent, expectedResponseListenContent);
    });

    test('Should handle request with CALL path wrapped in a request with LISTEN path (session 2)', () async {
      // Arrange
      const String actualPathListen = '/listen';

      const String actualBodyListen = '[{"path":"1","session":"2","product":0,"vendor":0,"debug":false,"debugSession":null}]';
      HttpClient actualClientListen = HttpClient();
      HttpClientRequest actualRequestListen = await actualClientListen.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathListen'));
      _setHeaders(actualRequestListen, contentLength: actualBodyListen.length);
      actualRequestListen.write(actualBodyListen);

      const String actualPathCall = '/call/2';
      String actualBodyCall = '001d0000002108ac80808008088180808008088080808008080008001207546573746e65742800';
      HttpClient actualClientCall = HttpClient();
      HttpClientRequest actualRequestCall = await actualClientCall.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathCall'));
      _setHeaders(actualRequestCall, contentLength: actualBodyCall.length);
      actualRequestCall.write(actualBodyCall);

      // Act
      HttpClientResponse actualResponseCall = await actualRequestCall.close();
      String actualResponseCallContent = await actualResponseCall.transform(const Utf8Decoder()).join();
      actualClientCall.close();

      // Assert
      String expectedResponseCallContent = '001e000000020a00';

      TestUtils.printInfo('Should [return proto buffer]');
      expect(actualResponseCallContent, expectedResponseCallContent);

      // ************************************************************************

      // Arrange
      actualBodyCall = '000b0000001f08ac8080800808bc80808008088080808008080008002207426974636f696e';
      actualClientCall = HttpClient();
      actualRequestCall = await actualClientCall.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathCall'));
      _setHeaders(actualRequestCall, contentLength: actualBodyCall.length);
      actualRequestCall.write(actualBodyCall);

      // Act
      actualResponseCall = await actualRequestCall.close();
      actualResponseCallContent = await actualResponseCall.transform(const Utf8Decoder()).join();
      actualClientCall.close();

      // Assert
      expectedResponseCallContent = '001a00000002080b';

      TestUtils.printInfo('Should [return proto buffer]');
      expect(actualResponseCallContent, expectedResponseCallContent);

      // ************************************************************************

      // Arrange
      const String actualPathRelease = '/release/2';
      HttpClient actualClientRelease = HttpClient();
      HttpClientRequest actualRequestRelease = await actualClientRelease.postUrl(Uri.parse('http://$actualHost:$actualPort$actualPathRelease'));
      _setHeaders(actualRequestRelease);

      // Act
      HttpClientResponse actualResponseRelease = await actualRequestRelease.close();
      String actualResponseReleaseContent = await actualResponseRelease.transform(const Utf8Decoder()).join();
      actualClientRelease.close();

      // Assert
      String expectedResponseReleaseContent = '{"session":"2"}\n';

      TestUtils.printInfo('Should [return session = 2]');
      expect(actualResponseReleaseContent, expectedResponseReleaseContent);

      // ************************************************************************

      // Act
      HttpClientResponse actualResponseListen = await actualRequestListen.close();
      String actualResponseListenContent = await actualResponseListen.transform(const Utf8Decoder()).join();
      actualClientListen.close();

      // Assert
      String expectedResponseListenContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":null,"debugSession":null}]\n';

      TestUtils.printInfo('Should [return JSON with session = null]');
      expect(actualResponseListenContent, expectedResponseListenContent);
    });
  });
}

void _setHeaders(HttpClientRequest request, {int? contentLength}) {
  request.headers.set('Host', '127.0.0.1:21325');
  request.headers.set('Connection', 'keep-alive');
  contentLength == null ? request.headers.set('Content-Length', '0') : request.headers.set('Content-Length', contentLength.toString());
  request.headers.set('sec-ch-ua', '"Chromium";v="124", "Google Chrome";v="124", "Not-A.Brand";v="99"');
  request.headers.set('sec-ch-ua-mobile', '?0');
  request.headers.set('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36');
  if (contentLength != null) {
    request.headers.set('Content-Type', 'text/plain;charset=UTF-8');
  }
  request.headers.set('sec-ch-ua-platform', '"Linux"');
  request.headers.set('Accept', '*/*');
  request.headers.set('Origin', 'https://connect.trezor.io');
  request.headers.set('Sec-Fetch-Site', 'cross-site');
  request.headers.set('Sec-Fetch-Mode', 'cors');
  request.headers.set('Sec-Fetch-Dest', 'empty');
  request.headers.set('Accept-Encoding', 'gzip, deflate, br, zstd');
  request.headers.set('Accept-Language', 'pl-PL,pl;q=0.9,en-US;q=0.8,en;q=0.7');
}
