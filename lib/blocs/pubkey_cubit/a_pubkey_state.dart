import 'package:equatable/equatable.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

abstract class APubkeyState extends Equatable {
  final PubkeyModel? pubkeyModel;

  const APubkeyState({this.pubkeyModel});

  bool get pubkeyExistsBool => pubkeyModel != null;

  APubkeyState copyWith({PubkeyModel? pubkeyModel});
}
