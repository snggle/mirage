import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/pubkey_cubit/a_pubkey_state.dart';
import 'package:mirage/blocs/pubkey_cubit/states/pubkey_default_state.dart';
import 'package:mirage/blocs/pubkey_cubit/states/pubkey_uploading_state.dart';
import 'package:mirage/blocs/visualizer_cubit/visualizer_cubit.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_public_key_response.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/utils/app_logger.dart';

class PubkeyCubit extends Cubit<APubkeyState> {
  final PubkeyService _pubkeyService = globalLocator<PubkeyService>();

  PubkeyCubit() : super(const PubkeyDefaultState());

  void openManualPubkeyUpload() {
    globalLocator<VisualizerCubit>().switchToRecording();
    emit(PubkeyUploadingState(pubkeyModel: state.pubkeyModel));
  }

  void closeManualPubkeyUpload() {
    globalLocator<VisualizerCubit>().switchToInitial();
    emit(PubkeyDefaultState(pubkeyModel: state.pubkeyModel));
  }

  Future<void> uploadPubkey(Uint8List recordedPubkeyCborBytes) async {
    TrezorPublicKeyResponse trezorPublicKeyResponse = TrezorPublicKeyResponse.fromSerializedCbor(
      recordedPubkeyCborBytes,
      const <int>[2147483692, 2147483708, 2147483648, 0],
      "m/44'/60'/0'/0",
    );
    await _pubkeyService.saveXPub(trezorPublicKeyResponse.xpub);
    await loadPubkey();
  }

  Future<void> loadPubkey() async {
    try {
      PubkeyModel pubkeyModel = await _pubkeyService.getPublicKey();
      emit(state.copyWith(pubkeyModel: pubkeyModel));
    } catch (e) {
      AppLogger().log(message: 'No active public key. Connect the wallet.');
      return;
    }
  }
}
