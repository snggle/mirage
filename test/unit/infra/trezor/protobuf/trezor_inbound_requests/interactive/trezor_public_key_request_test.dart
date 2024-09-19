import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';

Future<void> main() async {
  group('Tests of TrezorPublicKeyRequest.getResponse()', () {
    test('Should [return TrezorPublicKeyResponse] containing derived public key info', () async {
      // Arrange
      TrezorPublicKeyRequest actualTrezorPublicKeyRequest = TrezorPublicKeyRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      Secp256k1PublicKey actualSecp256k1PublicKey = Secp256k1PublicKey(
        ecPublicKey: ECPublicKey(
          ECPoint(
            curve: Curves.secp256k1,
            n: BigInt.parse('115792089237316195423570985008687907852837564279074904382605163141518161494337'),
            x: BigInt.parse('55066263022277343669578718895168534326250603453777594175500187360389116729240'),
            y: BigInt.parse('32670510020758816978083085130507043184471273380659243275938904335757337482424'),
            z: BigInt.from(1),
          ),
          ECPoint(
            curve: Curves.secp256k1,
            n: BigInt.parse('115792089237316195423570985008687907852837564279074904382605163141518161494337'),
            x: BigInt.parse('29357797598019490111042495162432345030138196655582932521058771624489363787151'),
            y: BigInt.parse('106424576024797300402618462856750193525871717621220594323833548745795750484228'),
            z: BigInt.from(1),
          ),
        ),
        metadata: Bip32KeyMetadata(
          depth: 4,
          // @formatter:off
          chainCode: Uint8List.fromList(<int>[26, 71, 127, 250, 21, 9, 64, 23, 141, 109, 147, 72, 253, 186, 221, 234, 205, 101, 74, 26, 15, 192, 247, 255, 7, 222, 59, 86, 93, 189, 166, 49]),
          // @formatter:on
          fingerprint: BigInt.from(2382068266),
          parentFingerprint: BigInt.from(1881575369),
          masterFingerprint: null,
          shiftedIndex: 0,
        ),
      );

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = actualTrezorPublicKeyRequest.getDerivedResponse(actualSecp256k1PublicKey);

      // Assert
      ATrezorOutboundResponse expectedTrezorOutboundResponse = TrezorPublicKeyResponse(
        depth: 5,
        fingerprint: 1881575369,
        // @formatter:off
        chainCode: const <int>[26, 71, 127, 250, 21, 9, 64, 23, 141, 109, 147, 72, 253, 186, 221, 234, 205, 101, 74, 26, 15, 192, 247, 255, 7, 222, 59, 86, 93, 189, 166, 49],
        publicKey: const <int>[2, 64, 231, 236, 178, 54, 76, 97, 149, 170, 107, 26, 191, 232, 221, 95, 1, 170, 89, 4, 98, 110, 43, 85, 23, 120, 29, 151, 255, 216, 205, 77, 143],
        // @formatter:on
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
      );

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });
}
