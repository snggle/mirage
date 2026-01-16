import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';

class EthSignedTx extends AApiMethodDto {
  final String r;
  final String s;
  final String v;

  EthSignedTx({
    required this.r,
    required this.s,
    required this.v,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'r': r,
      's': s,
      'v': v,
    };
  }

  @override
  List<Object> get props => <Object>[r, s, v];
}
