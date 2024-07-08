import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';

enum AwaitedRequestType {
  publicKey,
  eip1559Signature,
  ethMsgSignature;

  static ButtonRequest_ButtonRequestType toProtobufEnum(AwaitedRequestType awaitedRequestType) {
    switch (awaitedRequestType) {
      case AwaitedRequestType.publicKey:
        return ButtonRequest_ButtonRequestType.ButtonRequest_PublicKey;
      case AwaitedRequestType.eip1559Signature:
        return ButtonRequest_ButtonRequestType.ButtonRequest_SignTx;
      case AwaitedRequestType.ethMsgSignature:
        return ButtonRequest_ButtonRequestType.ButtonRequest_SignTx;
      default:
        return ButtonRequest_ButtonRequestType.ButtonRequest_Other;
    }
  }
}
