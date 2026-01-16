import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';

class TrezorWsEvent extends Equatable {
  final ATrezorInboundRequest trezorInboundRequest;
  final Completer<ATrezorOutboundResponse> _completer;

  TrezorWsEvent(this.trezorInboundRequest) :  _completer = Completer<ATrezorOutboundResponse>();

  void resolve(ATrezorOutboundResponse trezorOutboundResponse) {
    if (_completer.isCompleted) {
      throw StateError('Completer already completed');
    }
    _completer.complete(trezorOutboundResponse);
  }

  void reject(Object error, [StackTrace? stackTrace]) {
    if (_completer.isCompleted) {
      throw StateError('Completer already completed');
    }
    _completer.completeError(error, stackTrace);
  }

  Future<ATrezorOutboundResponse> get future => _completer.future;

  @override
  List<Object?> get props => <Object>[trezorInboundRequest];
}