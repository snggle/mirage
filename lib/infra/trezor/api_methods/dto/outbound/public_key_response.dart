import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';

class PublicKeyResponse extends AApiMethodDto {
  final List<int> path;
  final String serializedPath;
  final int childNum;
  final String xpub;
  final String chainCode;
  final String publicKey;
  final int fingerprint;
  final int depth;

  PublicKeyResponse({
    required this.path,
    required this.serializedPath,
    required this.childNum,
    required this.xpub,
    required this.chainCode,
    required this.publicKey,
    required this.fingerprint,
    required this.depth,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'serializedPath': serializedPath,
      'childNum': childNum,
      'xpub': xpub,
      'chainCode': chainCode,
      'publicKey': publicKey,
      'fingerprint': fingerprint,
      'depth': depth,
    };
  }

  @override
  List<Object> get props => <Object>[path, serializedPath, childNum, xpub, chainCode, publicKey, fingerprint, depth];
}
