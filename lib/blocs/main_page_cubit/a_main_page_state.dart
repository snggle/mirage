import 'package:equatable/equatable.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

abstract class AMainPageState extends Equatable {
  final PubkeyModel? pubkeyModel;

  const AMainPageState({this.pubkeyModel});

  AMainPageState copyWith({PubkeyModel? pubkeyModel});
}
