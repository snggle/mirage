import 'package:mirage/blocs/pubkey_cubit/a_pubkey_state.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class PubkeyDefaultState extends APubkeyState {
  const PubkeyDefaultState({super.pubkeyModel});

  @override
  APubkeyState copyWith({PubkeyModel? pubkeyModel}) {
    return PubkeyDefaultState(pubkeyModel: pubkeyModel);
  }

  @override
  List<Object?> get props => <Object?>[pubkeyModel];
}
