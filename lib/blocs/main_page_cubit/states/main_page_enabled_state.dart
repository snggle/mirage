import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/multipart/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/trezor_event.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class MainPageEnabledState extends AMainPageState {
  final TrezorEvent activeEvent;
  final bool repeatedAttemptBool;

  const MainPageEnabledState({
    required this.activeEvent,
    this.repeatedAttemptBool = false,
    super.pubkeyModel,
  });

  @override
  AMainPageState copyWith({PubkeyModel? pubkeyModel}) {
    return MainPageEnabledState(
      activeEvent: activeEvent,
      pubkeyModel: pubkeyModel,
    );
  }

  String get title => activeEvent.trezorInteractiveRequest.title;

  List<String> get description => activeEvent.trezorInteractiveRequest.description;

  String get audioRequestData {
    switch (activeEvent.trezorInteractiveRequest) {
      case TrezorPublicKeyRequest trezorPublicKeyRequest:
        return HexCodec.encode(trezorPublicKeyRequest.toSerializedCbor());
      case TrezorEIP1559SignatureRequest trezorEIP1559SignatureRequest:
        return HexCodec.encode(trezorEIP1559SignatureRequest.toSerializedCbor(pubkeyModel: pubkeyModel));
      case TrezorEthMsgSignatureRequest trezorEthMsgSignatureRequest:
        return HexCodec.encode(trezorEthMsgSignatureRequest.toSerializedCbor(pubkeyModel: pubkeyModel));
      default:
        return HexCodec.encode(activeEvent.trezorInteractiveRequest.toSerializedCbor());
    }
  }

  @override
  List<Object?> get props => <Object?>[activeEvent, pubkeyModel];
}
