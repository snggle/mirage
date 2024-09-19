import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class MainPageDisabledState extends AMainPageState {
  const MainPageDisabledState({super.pubkeyModel});

  @override
  AMainPageState copyWith({PubkeyModel? pubkeyModel}) {
    return MainPageDisabledState(pubkeyModel: pubkeyModel);
  }

  @override
  List<Object?> get props => <Object?>[pubkeyModel];
}
