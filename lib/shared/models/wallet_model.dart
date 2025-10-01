import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final String address;
  final String derivationPath;

  const WalletModel({
    required this.address,
    required this.derivationPath,
  });

  String getShortAddress(int length) {
    return '${address.substring(0, length + 2)}...${address.substring(address.length - length)}';
  }

  @override
  List<Object?> get props => <Object>[address, derivationPath];
}
