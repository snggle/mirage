import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';

class InteractiveRequestReceivedEvent extends Equatable {
  final ATrezorInteractiveRequest trezorInteractiveRequest;
  final Completer<ATrezorAwaitedResponse> _completer;

  InteractiveRequestReceivedEvent(this.trezorInteractiveRequest) :  _completer = Completer<ATrezorAwaitedResponse>();

  void resolve(ATrezorAwaitedResponse response) {
    if (_completer.isCompleted) {
      throw StateError('Completer already completed');
    }
    _completer.complete(response);
  }

  void reject(Object error, [StackTrace? stackTrace]) {
    if (_completer.isCompleted) {
      throw StateError('Completer already completed');
    }
    _completer.completeError(error, stackTrace);
  }

  Future<ATrezorAwaitedResponse> get future => _completer.future;

  @override
  List<Object?> get props => <Object>[trezorInteractiveRequest];
}