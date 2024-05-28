import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/trezor_http_server.dart';

import '../../../utils/test_utils.dart';

void main() async {
  const String actualServerUri = 'http://127.0.0.1:21325';
  final HttpClient actualHttpClient = HttpClient();
  late TrezorHttpServer trezorHttpServer;

  setUpAll(() async {
    await initLocator();
    trezorHttpServer = TrezorHttpServer();
    await trezorHttpServer.start();
  });

  group('Tests of status code responses for different HTTP methods', () {
    test('Should [return statusCode = 200] for the POST request', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.postUrl(Uri.parse('$actualServerUri/'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 200;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the GET request', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.getUrl(Uri.parse('$actualServerUri/'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the DELETE request', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.deleteUrl(Uri.parse('$actualServerUri/'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the HEAD request', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.headUrl(Uri.parse('$actualServerUri/'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the PATCH request', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.patchUrl(Uri.parse('$actualServerUri/'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for the PUT request', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.putUrl(Uri.parse('$actualServerUri/'));

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });
  });

  group('Should test the HTTP server process', () {
    group('Tests of / endpoint', () {
      test('Should [return return EmptyPathResp] for POST /', () async {
        // Act
        HttpClientResponse actualResponse = await _performPostHttpRequest(
          httpClient: actualHttpClient,
          uri: Uri.parse('$actualServerUri/'),
        );
        String actualResponseContent = await actualResponse.transform(const Utf8Decoder()).join();

        // Assert
        String expectedResponseContent = '{"version":"2.0.34","githash":"e83287a"}';

        expect(actualResponseContent, expectedResponseContent);
      });
    });

    group('Tests of /enumerate endpoint', () {
      test('Should [return EnumerateResp] for POST /enumerate', () async {
        // Act
        HttpClientResponse actualResponse = await _performPostHttpRequest(
          httpClient: actualHttpClient,
          uri: Uri.parse('$actualServerUri/enumerate'),
        );
        String actualResponseContent = await actualResponse.transform(const Utf8Decoder()).join();

        // Assert
        String expectedResponseContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":null,"debugSession":null}]';

        expect(actualResponseContent, expectedResponseContent);
      });
    });

    group('Tests of /listen endpoint', () {
      group('Tests of /acquire endpoint', () {
        test('Should [handle POST /acquire] wrapped with POST /listen', () async {
          // Arrange
          Future<HttpClientResponse> actualResponseListenFuture = _performPostHttpRequest(
            httpClient: actualHttpClient,
            uri: Uri.parse('$actualServerUri/listen'),
            body: '[{"path":"1","session":null,"product":0,"vendor":0,"debug":false,"debugSession":null}]',
          );

          // Act
          HttpClientResponse actualResponseAcquire = await _performPostHttpRequest(
            httpClient: actualHttpClient,
            uri: Uri.parse('$actualServerUri/acquire/1/null'),
          );
          String actualResponseAcquireContent = await actualResponseAcquire.transform(const Utf8Decoder()).join();

          // Assert
          String expectedResponseAcquireContent = '{"session":"1"}';
          TestUtils.printInfo('Should [return AcquireResp] with session = 1');
          expect(actualResponseAcquireContent, expectedResponseAcquireContent);

          // ************************************************************************

          // Act
          HttpClientResponse actualResponseListen = await actualResponseListenFuture;
          String actualResponseListenContent = await actualResponseListen.transform(const Utf8Decoder()).join();

          // Assert
          String expectedResponseListenContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":"1","debugSession":null}]';
          TestUtils.printInfo('Should [return ListenResp] with session = 1');
          expect(actualResponseListenContent, expectedResponseListenContent);
        });
      });

      group('Tests of /call endpoint', () {
        test('Should [handle POST /call] wrapped with POST /listen', () async {
          // Arrange
          Future<HttpClientResponse> actualResponseListenFuture = _performPostHttpRequest(
            httpClient: actualHttpClient,
            uri: Uri.parse('$actualServerUri/listen'),
            body: '[{"path":"1","session":"1","product":0,"vendor":0,"debug":false,"debugSession":null}]',
          );

          // Act
          HttpClientResponse actualResponseCall = await _performPostHttpRequest(
            httpClient: actualHttpClient,
            uri: Uri.parse('$actualServerUri/call/1'),
            body: '001d0000002108ac80808008088180808008088080808008080008001207546573746e65742800',
          );
          String actualResponseCallContent = await actualResponseCall.transform(const Utf8Decoder()).join();

          // Assert
          String expectedResponseCallContent = '001e000000020a00';

          TestUtils.printInfo('Should [return CallResp] with a proto buffer');
          expect(actualResponseCallContent, expectedResponseCallContent);

          // ************************************************************************

          // Act
          actualResponseCall = await _performPostHttpRequest(
            httpClient: actualHttpClient,
            uri: Uri.parse('$actualServerUri/call/1'),
            body: '003700000000',
          );
          actualResponseCallContent = await actualResponseCall.transform(const Utf8Decoder()).join();

          // Assert
          expectedResponseCallContent =
              '0011000000e80a097472657a6f722e696f1002180820013218333535433831373531304330454142463246313437313435380140014a05656e2d555352094d79205472657a6f7260016a14c7832c39ab3c2a9c46544c57d1a8980583609f47800101980100a00100aa010154ca0108454d554c41544f52d80100e00100e80100f00101f00102f00103f00104f00105f00107f00109f0010bf0010cf0010df0010ef0010ff00110f00111f00112f00113f0010af00106f80100800201880200900200a00200a80200b002c0cf24b80200c00200c80200d00202d80200e2020454325431f802f0018003f001900301';

          TestUtils.printInfo('Should [return CallResp] with a proto buffer');
          expect(actualResponseCallContent, expectedResponseCallContent);

          // ************************************************************************

          // Act
          HttpClientResponse actualResponseRelease = await _performPostHttpRequest(
            httpClient: actualHttpClient,
            uri: Uri.parse('$actualServerUri/release/1'),
          );
          String actualResponseReleaseContent = await actualResponseRelease.transform(const Utf8Decoder()).join();

          // Assert
          String expectedResponseReleaseContent = '{"session":"1"}';

          TestUtils.printInfo('Should [return ReleaseResp] with session = 1');
          expect(actualResponseReleaseContent, expectedResponseReleaseContent);

          // ************************************************************************

          // Act
          HttpClientResponse actualResponseListen = await actualResponseListenFuture;
          String actualResponseListenContent = await actualResponseListen.transform(const Utf8Decoder()).join();

          // Assert
          String expectedResponseListenContent = '[{"path":"1","vendor":1,"product":0,"debug":false,"session":null,"debugSession":null}]';

          TestUtils.printInfo('Should [return ListenResp] with session = null');
          expect(actualResponseListenContent, expectedResponseListenContent);
        });
      });
    });
  });

  tearDownAll(() async {
    await trezorHttpServer.dispose();
  });
}

Future<HttpClientResponse> _performPostHttpRequest({required HttpClient httpClient, required Uri uri, String? body}) async {
  HttpClientRequest actualRequest = await httpClient.postUrl(uri);
  if (body != null) {
    actualRequest.write(body);
  }

  return actualRequest.close();
}
