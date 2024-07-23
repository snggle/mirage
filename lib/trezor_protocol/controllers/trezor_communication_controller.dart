import 'dart:async';

import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/main_page_cubit.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/protobuf_msg_serializer.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class TrezorCommunicationController {
  late Completer<void> completer;
  late String receivedCbor;

  final MainPageCubit _mainPageCubit = globalLocator<MainPageCubit>();
  late final StreamSubscription<AMainPageState> _xStateSubscription;

  TrezorCommunicationController() : super() {
    _xStateSubscription = _mainPageCubit.stream.listen((AMainPageState xState) {
      if (xState is MainPageRecordedState) {
        receivedCbor = xState.userTextEditingController.text;
      }
      if (xState is MainPageDisabledState) {
        AppLogger().log(message: '\nRECORDED: $receivedCbor\n');
        completer.complete();
      }
    });
  }

  void close() {
    _xStateSubscription.cancel();
  }

  Future<String> handleBuffer(String inputBuffer) async {
    protobuf.GeneratedMessage inputMsg = ProtobufMsgSerializer.deserialize(inputBuffer);
    protobuf.GeneratedMessage responseMsg = await _handleProtobufMsg(inputMsg);
    return ProtobufMsgSerializer.serialize(responseMsg);
  }

  Future<protobuf.GeneratedMessage> _handleProtobufMsg(protobuf.GeneratedMessage inputMsg) async {
    ATrezorInboundRequest trezorInboundRequest = ATrezorInboundRequest.fromProtobufMsg(inputMsg);
    ATrezorOutboundResponse trezorOutboundResponse = await _handleTrezorRequest(trezorInboundRequest);
    return trezorOutboundResponse.toProtobufMsg();
  }

  Future<ATrezorOutboundResponse> _handleTrezorRequest(ATrezorInboundRequest trezorInboundRequest) async {
    switch (trezorInboundRequest) {
      case ATrezorAutomatedRequest trezorAutomatedRequest:
        ATrezorOutboundResponse trezorOutboundResponse = trezorAutomatedRequest.getResponse();
        return trezorOutboundResponse;
      case ATrezorInteractiveRequest trezorInteractiveRequest:
        completer = Completer<void>();
        _mainPageCubit.enableAudioTransmission(
          title: trezorInteractiveRequest.title,
          audioRequestData: trezorInteractiveRequest.requestCbor,
        );
        await completer.future;

        ATrezorAwaitedResponse trezorAwaitedResponse = await trezorInteractiveRequest.getResponseFromCborPayload(receivedCbor);
        return trezorAwaitedResponse;
      default:
        throw ArgumentError();
    }
  }
}
