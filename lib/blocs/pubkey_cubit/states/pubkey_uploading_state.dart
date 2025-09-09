import 'package:mirage/blocs/pubkey_cubit/a_pubkey_state.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class PubkeyUploadingState extends APubkeyState {
  const PubkeyUploadingState({super.pubkeyModel});

  @override
  APubkeyState copyWith({PubkeyModel? pubkeyModel}) {
    return PubkeyUploadingState(pubkeyModel: pubkeyModel);
  }

  @override
  List<Object?> get props => <Object?>[pubkeyModel];
}
