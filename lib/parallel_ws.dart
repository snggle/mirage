import 'dart:convert';
import 'dart:io';

void main() {
  startWs();
}

Future<void> startWs() async {
  final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 21335);
  print('WS listening on ws://127.0.0.1:21335/connect-ws');

  await for (final HttpRequest req in server) {
    if (req.uri.path != '/connect-ws' || !WebSocketTransformer.isUpgradeRequest(req)) {
      req.response.statusCode = HttpStatus.notFound;
      await req.response.close();
      continue;
    }

    print('WS upgrade from origin=${req.headers.value('origin')} '
        'protocol=${req.headers.value('sec-websocket-protocol')}');

    final WebSocket ws = await WebSocketTransformer.upgrade(req);
    print('WS connected');

    ws
      ..pingInterval = const Duration(seconds: 10) // helps keepalive
      ..listen(
        (dynamic message) async {
          if (message is String) {
            print('WS <= $message');

            try {
              final dynamic obj = jsonDecode(message);
              if (obj is Map && obj.containsKey('id')) {
                if (obj['type'] == 'popup-handshake') {
                  final Map<String, dynamic> ack = <String, dynamic>{
                    'id': obj['id'],
                    'type': 'popup-handshake',
                    'payload': <String, bool>{'ok': true}
                  };
                  ws.add(jsonEncode(ack));
                  print('WS => ack for id=${obj['id']}');
                } else {
                  await Future<void>.delayed(const Duration(milliseconds: 10000));
                  final Map<String, dynamic> ack = <String, dynamic>{
                    'id': obj['id'],
                    'success': true,
                    'payload': <String, Object?>{
                      'path': <int>[
                        2147483692,
                        2147483708,
                        2147483648,
                        0
                      ],
                      'serializedPath': "m/44'/60'/0'/0",
                      'childNum': 0,
                      'xpub': 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
                      'chainCode': '1a477ffa150940178d6d9348fdbaddeacd654a1a0fc0f7ff07de3b565dbda631',
                      'publicKey': '0240e7ecb2364c6195aa6b1abfe8dd5f01aa5904626e2b5517781d97ffd8cd4d8f',
                      'fingerprint': 1881575369,
                      'depth': 4,
                      'descriptor': null
                    },
                    'device': <String, Object>{
                      'path': 'b265a417',
                      'state': <String, Object>{
                        'staticSessionId': 'n3rSLT9Fojbd6FqtmGG6T6y5KveugeyGGf@3D07E6C7214DCA7E8E312709:1',
                        'sessionId': 'c59f3853c2b26936866bbc3622a194e169f304af1aa27bc30fc7d2bcdb7c3fe7',
                        'deriveCardano': false
                      },
                      'instance': 1
                    }
                  };
                  ws.add(jsonEncode(ack));
                  print('WS => ack for id=${obj['id']}');
                }
              } else {
                ws.add(jsonEncode(<String, bool>{'ok': true}));
              }
            } catch (_) {}
          } else if (message is List<int>) {
            print('WS <= (binary ${message.length} bytes)');
          }
        },
        onDone: () {
          print('WS closed. code=${ws.closeCode} reason=${ws.closeReason}');
        },
        onError: (dynamic e) {
          print('WS error: $e');
        },
        cancelOnError: true,
      );
  }
}
