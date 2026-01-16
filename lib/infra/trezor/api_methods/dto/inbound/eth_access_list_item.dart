import 'package:equatable/equatable.dart';

class EthAccessListItem extends Equatable {
  final String address;
  final List<String> storageKeys;

  const EthAccessListItem({
    required this.address,
    required this.storageKeys,
  });

  factory EthAccessListItem.fromJson(Map<String, dynamic> json) {
    return EthAccessListItem(
      address: json['address'] as String,
      storageKeys: (json['storageKeys'] as List<dynamic>).map((dynamic e) => e as String).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'address': address,
      'storageKeys': storageKeys,
    };
  }

  @override
  List<Object?> get props => <Object?>[address, storageKeys];
}
