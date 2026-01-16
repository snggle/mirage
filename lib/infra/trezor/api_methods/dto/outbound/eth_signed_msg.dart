import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';

class EthSignedMsg extends AApiMethodDto {
  final String address;
  final String signature;

  EthSignedMsg({
    required this.address,
    required this.signature,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'address': address,
      'signature': signature,
    };
  }

  @override
  List<Object> get props => <Object>[address, signature];
}
