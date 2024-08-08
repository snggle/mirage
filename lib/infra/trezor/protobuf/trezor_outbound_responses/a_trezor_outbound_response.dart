import 'package:equatable/equatable.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

abstract class ATrezorOutboundResponse extends Equatable {
  protobuf.GeneratedMessage toProtobufMsg();
}
