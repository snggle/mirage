import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';

class GetPublicKey extends AApiMethodDto {
  final String path;
  final String? coin;

  GetPublicKey({
    required this.path,
    this.coin,
  });

  factory GetPublicKey.fromJson(Map<String, dynamic> json) {
    return GetPublicKey(
      path: json['path'] as String,
      coin: json['coin'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      if (coin != null) 'coin': coin,
    };
  }

  @override
  List<Object?> get props => <Object?>[path, coin];
}
