import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';

class EthSignMsg extends AApiMethodDto {
  final String path;
  final String message;
  final bool? hex;

  EthSignMsg({
    required this.path,
    required this.message,
    this.hex,
  });

  factory EthSignMsg.fromJson(Map<String, dynamic> json) {
    return EthSignMsg(
      path: json['path'] as String,
      message: json['message'] as String,
      hex: json['hex'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'message': message,
      if (hex != null) 'hex': hex,
    };
  }

  @override
  List<Object?> get props => <Object?>[path, message, hex];
}
