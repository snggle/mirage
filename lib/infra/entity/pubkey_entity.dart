import 'package:equatable/equatable.dart';

class PubkeyEntity extends Equatable {
  final String xpub;

  const PubkeyEntity({
    required this.xpub,
  });

  factory PubkeyEntity.fromJson(Map<String, dynamic> json) {
    return PubkeyEntity(
      xpub: json['xpub'] as String,
    );
  }

  @override
  String toString() {
    return 'xpub: $xpub';
  }

  @override
  List<Object?> get props => <Object>[xpub];
}
