import 'dart:io';

import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorPublicKeyResponse extends ATrezorAwaitedResponse {
  final int depth;
  final int fingerprint;
  final List<int> chainCode;
  final List<int> publicKey;
  final String xpub;

  TrezorPublicKeyResponse({
    required this.depth,
    required this.fingerprint,
    required this.chainCode,
    required this.publicKey,
    required this.xpub,
  });

  factory TrezorPublicKeyResponse.getDataFromUser() {
    stdout.write('Enter depth: ');
    String depthLine = stdin.readLineSync()!;

    stdout.write('Enter fingerprint: ');
    String fingerprintLine = stdin.readLineSync()!;

    stdout.write('Enter chainCode: ');
    String chainCodeLine = stdin.readLineSync()!;

    stdout.write('Enter publicKey: ');
    String publicKeyLine = stdin.readLineSync()!;

    stdout.write('Enter xpub: ');
    String xpubLine = stdin.readLineSync()!;

    return TrezorPublicKeyResponse(
      depth: int.parse(depthLine),
      fingerprint: int.parse(fingerprintLine),
      chainCode: BytesUtils.parseStringToList(chainCodeLine),
      publicKey: BytesUtils.parseStringToList(publicKeyLine),
      xpub: xpubLine,
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return PublicKey(
      node: HDNodeType(
        depth: depth,
        fingerprint: fingerprint,
        childNum: 0,
        chainCode: chainCode,
        publicKey: publicKey,
      ),
      xpub: xpub,
    );
  }

  @override
  List<Object?> get props => <Object>[depth, fingerprint, chainCode, publicKey, xpub];
}
