import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';

class ErrorResponse extends AApiMethodDto {
  final String code;
  final String message;

  ErrorResponse({
    required this.code,
    required this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'message': message,
    };
  }

  @override
  List<Object> get props => <Object>[code, message];
}
