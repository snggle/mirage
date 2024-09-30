import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart' as cryptography_utils;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/multipart/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/supplementary/trezor_eip1559_data_supply.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/trezor_ask_more_data_response.dart';

import '../../../../../../../utils/test_utils.dart';

void main() {
  group('Tests of TrezorEIP1559SignatureRequest.askForSupplementaryInfo()', () {
    test('Should [return TrezorAskMoreDataResponse] with [requestedBytesLength = 512] if [data is NOT COMPLETE] (1024 bytes, dataLength = 1536)', () async {
      // Arrange
      TrezorEIP1559SignatureRequest actualTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          // @formatter:off
          data: Uint8List.fromList(<int>[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 31, 31, 31, 31, 31, 31, 31, 31, 32, 32, 32, 32, 32, 32, 32, 32, 33, 33, 33, 33, 33, 33, 33, 33, 34, 34, 34, 34, 34, 34, 34, 34, 35, 35, 35, 35, 35, 35, 35, 35, 36, 36, 36, 36, 36, 36, 36, 36, 37, 37, 37, 37, 37, 37, 37, 37, 38, 38, 38, 38, 38, 38, 38, 38, 39, 39, 39, 39, 39, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 41, 41, 42, 42, 42, 42, 42, 42, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 45, 45, 45, 45, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 47, 47, 47, 47, 47, 47, 47, 47, 48, 48, 48, 48, 48, 48, 48, 48, 49, 49, 49, 49, 49, 49, 49, 49, 50, 50, 50, 50, 50, 50, 50, 50, 51, 51, 51, 51, 51, 51, 51, 51, 52, 52, 52, 52, 52, 52, 52, 52, 53, 53, 53, 53, 53, 53, 53, 53, 54, 54, 54, 54, 54, 54, 54, 54, 55, 55, 55, 55, 55, 55, 55, 55, 56, 56, 56, 56, 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 59, 59, 59, 59, 59, 59, 59, 59, 60, 60, 60, 60, 60, 60, 60, 60, 61, 61, 61, 61, 61, 61, 61, 61, 62, 62, 62, 62, 62, 62, 62, 62, 63, 63, 63, 63, 63, 63, 63, 63, 64, 64, 64, 64, 64, 64, 64, 64, 65, 65, 65, 65, 65, 65, 65, 65, 66, 66, 66, 66, 66, 66, 66, 66, 67, 67, 67, 67, 67, 67, 67, 67, 68, 68, 68, 68, 68, 68, 68, 68, 69, 69, 69, 69, 69, 69, 69, 69, 70, 70, 70, 70, 70, 70, 70, 70, 71, 71, 71, 71, 71, 71, 71, 71, 72, 72, 72, 72, 72, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73, 74, 74, 74, 74, 74, 74, 74, 74, 75, 75, 75, 75, 75, 75, 75, 75, 76, 76, 76, 76, 76, 76, 76, 76, 77, 77, 77, 77, 77, 77, 77, 77, 78, 78, 78, 78, 78, 78, 78, 78, 79, 79, 79, 79, 79, 79, 79, 79, 80, 80, 80, 80, 80, 80, 80, 80, 81, 81, 81, 81, 81, 81, 81, 81, 82, 82, 82, 82, 82, 82, 82, 82, 83, 83, 83, 83, 83, 83, 83, 83, 84, 84, 84, 84, 84, 84, 84, 84, 85, 85, 85, 85, 85, 85, 85, 85, 86, 86, 86, 86, 86, 86, 86, 86, 87, 87, 87, 87, 87, 87, 87, 87, 88, 88, 88, 88, 88, 88, 88, 88, 89, 89, 89, 89, 89, 89, 89, 89, 90, 90, 90, 90, 90, 90, 90, 90, 91, 91, 91, 91, 91, 91, 91, 91, 92, 92, 92, 92, 92, 92, 92, 92, 93, 93, 93, 93, 93, 93, 93, 93, 94, 94, 94, 94, 94, 94, 94, 94, 95, 95, 95, 95, 95, 95, 95, 95, 96, 96, 96, 96, 96, 96, 96, 96, 97, 97, 97, 97, 97, 97, 97, 97, 98, 98, 98, 98, 98, 98, 98, 98, 99, 99, 99, 99, 99, 99, 99, 99, 100, 100, 100, 100, 100, 100, 100, 100, 101, 101, 101, 101, 101, 101, 101, 101, 102, 102, 102, 102, 102, 102, 102, 102, 103, 103, 103, 103, 103, 103, 103, 103, 104, 104, 104, 104, 104, 104, 104, 104, 105, 105, 105, 105, 105, 105, 105, 105, 106, 106, 106, 106, 106, 106, 106, 106, 107, 107, 107, 107, 107, 107, 107, 107, 108, 108, 108, 108, 108, 108, 108, 108, 109, 109, 109, 109, 109, 109, 109, 109, 110, 110, 110, 110, 110, 110, 110, 110, 111, 111, 111, 111, 111, 111, 111, 111, 112, 112, 112, 112, 112, 112, 112, 112, 113, 113, 113, 113, 113, 113, 113, 113, 114, 114, 114, 114, 114, 114, 114, 114, 115, 115, 115, 115, 115, 115, 115, 115, 116, 116, 116, 116, 116, 116, 116, 116, 117, 117, 117, 117, 117, 117, 117, 117, 118, 118, 118, 118, 118, 118, 118, 118, 119, 119, 119, 119, 119, 119, 119, 119, 120, 120, 120, 120, 120, 120, 120, 120, 121, 121, 121, 121, 121, 121, 121, 121, 122, 122, 122, 122, 122, 122, 122, 122, 123, 123, 123, 123, 123, 123, 123, 123, 124, 124, 124, 124, 124, 124, 124, 124, 125, 125, 125, 125, 125, 125, 125, 125, 126, 126, 126, 126, 126, 126, 126, 126, 127, 127, 127, 127, 127, 127, 127, 127, 128, 128, 128, 128, 128, 128, 128, 128]),
          // @formatter:on
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 1536,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = actualTrezorEIP1559SignatureRequest.askForSupplementaryInfo();

      // Assert
      TrezorAskMoreDataResponse expectedTrezorOutboundResponse = TrezorAskMoreDataResponse(requestedBytesLength: 512);

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });

    test('Should [return TrezorAskMoreDataResponse] with [requestedBytesLength = 1024] if [data is NOT COMPLETE] (1024 bytes, dataLength = 2048)', () async {
      // Arrange
      TrezorEIP1559SignatureRequest actualTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          // @formatter:off
          data: Uint8List.fromList(<int>[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 31, 31, 31, 31, 31, 31, 31, 31, 32, 32, 32, 32, 32, 32, 32, 32, 33, 33, 33, 33, 33, 33, 33, 33, 34, 34, 34, 34, 34, 34, 34, 34, 35, 35, 35, 35, 35, 35, 35, 35, 36, 36, 36, 36, 36, 36, 36, 36, 37, 37, 37, 37, 37, 37, 37, 37, 38, 38, 38, 38, 38, 38, 38, 38, 39, 39, 39, 39, 39, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 41, 41, 42, 42, 42, 42, 42, 42, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 45, 45, 45, 45, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 47, 47, 47, 47, 47, 47, 47, 47, 48, 48, 48, 48, 48, 48, 48, 48, 49, 49, 49, 49, 49, 49, 49, 49, 50, 50, 50, 50, 50, 50, 50, 50, 51, 51, 51, 51, 51, 51, 51, 51, 52, 52, 52, 52, 52, 52, 52, 52, 53, 53, 53, 53, 53, 53, 53, 53, 54, 54, 54, 54, 54, 54, 54, 54, 55, 55, 55, 55, 55, 55, 55, 55, 56, 56, 56, 56, 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 59, 59, 59, 59, 59, 59, 59, 59, 60, 60, 60, 60, 60, 60, 60, 60, 61, 61, 61, 61, 61, 61, 61, 61, 62, 62, 62, 62, 62, 62, 62, 62, 63, 63, 63, 63, 63, 63, 63, 63, 64, 64, 64, 64, 64, 64, 64, 64, 65, 65, 65, 65, 65, 65, 65, 65, 66, 66, 66, 66, 66, 66, 66, 66, 67, 67, 67, 67, 67, 67, 67, 67, 68, 68, 68, 68, 68, 68, 68, 68, 69, 69, 69, 69, 69, 69, 69, 69, 70, 70, 70, 70, 70, 70, 70, 70, 71, 71, 71, 71, 71, 71, 71, 71, 72, 72, 72, 72, 72, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73, 74, 74, 74, 74, 74, 74, 74, 74, 75, 75, 75, 75, 75, 75, 75, 75, 76, 76, 76, 76, 76, 76, 76, 76, 77, 77, 77, 77, 77, 77, 77, 77, 78, 78, 78, 78, 78, 78, 78, 78, 79, 79, 79, 79, 79, 79, 79, 79, 80, 80, 80, 80, 80, 80, 80, 80, 81, 81, 81, 81, 81, 81, 81, 81, 82, 82, 82, 82, 82, 82, 82, 82, 83, 83, 83, 83, 83, 83, 83, 83, 84, 84, 84, 84, 84, 84, 84, 84, 85, 85, 85, 85, 85, 85, 85, 85, 86, 86, 86, 86, 86, 86, 86, 86, 87, 87, 87, 87, 87, 87, 87, 87, 88, 88, 88, 88, 88, 88, 88, 88, 89, 89, 89, 89, 89, 89, 89, 89, 90, 90, 90, 90, 90, 90, 90, 90, 91, 91, 91, 91, 91, 91, 91, 91, 92, 92, 92, 92, 92, 92, 92, 92, 93, 93, 93, 93, 93, 93, 93, 93, 94, 94, 94, 94, 94, 94, 94, 94, 95, 95, 95, 95, 95, 95, 95, 95, 96, 96, 96, 96, 96, 96, 96, 96, 97, 97, 97, 97, 97, 97, 97, 97, 98, 98, 98, 98, 98, 98, 98, 98, 99, 99, 99, 99, 99, 99, 99, 99, 100, 100, 100, 100, 100, 100, 100, 100, 101, 101, 101, 101, 101, 101, 101, 101, 102, 102, 102, 102, 102, 102, 102, 102, 103, 103, 103, 103, 103, 103, 103, 103, 104, 104, 104, 104, 104, 104, 104, 104, 105, 105, 105, 105, 105, 105, 105, 105, 106, 106, 106, 106, 106, 106, 106, 106, 107, 107, 107, 107, 107, 107, 107, 107, 108, 108, 108, 108, 108, 108, 108, 108, 109, 109, 109, 109, 109, 109, 109, 109, 110, 110, 110, 110, 110, 110, 110, 110, 111, 111, 111, 111, 111, 111, 111, 111, 112, 112, 112, 112, 112, 112, 112, 112, 113, 113, 113, 113, 113, 113, 113, 113, 114, 114, 114, 114, 114, 114, 114, 114, 115, 115, 115, 115, 115, 115, 115, 115, 116, 116, 116, 116, 116, 116, 116, 116, 117, 117, 117, 117, 117, 117, 117, 117, 118, 118, 118, 118, 118, 118, 118, 118, 119, 119, 119, 119, 119, 119, 119, 119, 120, 120, 120, 120, 120, 120, 120, 120, 121, 121, 121, 121, 121, 121, 121, 121, 122, 122, 122, 122, 122, 122, 122, 122, 123, 123, 123, 123, 123, 123, 123, 123, 124, 124, 124, 124, 124, 124, 124, 124, 125, 125, 125, 125, 125, 125, 125, 125, 126, 126, 126, 126, 126, 126, 126, 126, 127, 127, 127, 127, 127, 127, 127, 127, 128, 128, 128, 128, 128, 128, 128, 128]),
          // @formatter:on
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 2048,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = actualTrezorEIP1559SignatureRequest.askForSupplementaryInfo();

      // Assert
      TrezorAskMoreDataResponse expectedTrezorOutboundResponse = TrezorAskMoreDataResponse(requestedBytesLength: 1024);

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });

    test('Should [return TrezorAskMoreDataResponse] with [requestedBytesLength = 1024] if [data is NOT COMPLETE] (1024 bytes, dataLength = 2560)', () async {
      // Arrange
      TrezorEIP1559SignatureRequest actualTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          // @formatter:off
          data: Uint8List.fromList(<int>[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 31, 31, 31, 31, 31, 31, 31, 31, 32, 32, 32, 32, 32, 32, 32, 32, 33, 33, 33, 33, 33, 33, 33, 33, 34, 34, 34, 34, 34, 34, 34, 34, 35, 35, 35, 35, 35, 35, 35, 35, 36, 36, 36, 36, 36, 36, 36, 36, 37, 37, 37, 37, 37, 37, 37, 37, 38, 38, 38, 38, 38, 38, 38, 38, 39, 39, 39, 39, 39, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 41, 41, 42, 42, 42, 42, 42, 42, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 45, 45, 45, 45, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 47, 47, 47, 47, 47, 47, 47, 47, 48, 48, 48, 48, 48, 48, 48, 48, 49, 49, 49, 49, 49, 49, 49, 49, 50, 50, 50, 50, 50, 50, 50, 50, 51, 51, 51, 51, 51, 51, 51, 51, 52, 52, 52, 52, 52, 52, 52, 52, 53, 53, 53, 53, 53, 53, 53, 53, 54, 54, 54, 54, 54, 54, 54, 54, 55, 55, 55, 55, 55, 55, 55, 55, 56, 56, 56, 56, 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 59, 59, 59, 59, 59, 59, 59, 59, 60, 60, 60, 60, 60, 60, 60, 60, 61, 61, 61, 61, 61, 61, 61, 61, 62, 62, 62, 62, 62, 62, 62, 62, 63, 63, 63, 63, 63, 63, 63, 63, 64, 64, 64, 64, 64, 64, 64, 64, 65, 65, 65, 65, 65, 65, 65, 65, 66, 66, 66, 66, 66, 66, 66, 66, 67, 67, 67, 67, 67, 67, 67, 67, 68, 68, 68, 68, 68, 68, 68, 68, 69, 69, 69, 69, 69, 69, 69, 69, 70, 70, 70, 70, 70, 70, 70, 70, 71, 71, 71, 71, 71, 71, 71, 71, 72, 72, 72, 72, 72, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73, 74, 74, 74, 74, 74, 74, 74, 74, 75, 75, 75, 75, 75, 75, 75, 75, 76, 76, 76, 76, 76, 76, 76, 76, 77, 77, 77, 77, 77, 77, 77, 77, 78, 78, 78, 78, 78, 78, 78, 78, 79, 79, 79, 79, 79, 79, 79, 79, 80, 80, 80, 80, 80, 80, 80, 80, 81, 81, 81, 81, 81, 81, 81, 81, 82, 82, 82, 82, 82, 82, 82, 82, 83, 83, 83, 83, 83, 83, 83, 83, 84, 84, 84, 84, 84, 84, 84, 84, 85, 85, 85, 85, 85, 85, 85, 85, 86, 86, 86, 86, 86, 86, 86, 86, 87, 87, 87, 87, 87, 87, 87, 87, 88, 88, 88, 88, 88, 88, 88, 88, 89, 89, 89, 89, 89, 89, 89, 89, 90, 90, 90, 90, 90, 90, 90, 90, 91, 91, 91, 91, 91, 91, 91, 91, 92, 92, 92, 92, 92, 92, 92, 92, 93, 93, 93, 93, 93, 93, 93, 93, 94, 94, 94, 94, 94, 94, 94, 94, 95, 95, 95, 95, 95, 95, 95, 95, 96, 96, 96, 96, 96, 96, 96, 96, 97, 97, 97, 97, 97, 97, 97, 97, 98, 98, 98, 98, 98, 98, 98, 98, 99, 99, 99, 99, 99, 99, 99, 99, 100, 100, 100, 100, 100, 100, 100, 100, 101, 101, 101, 101, 101, 101, 101, 101, 102, 102, 102, 102, 102, 102, 102, 102, 103, 103, 103, 103, 103, 103, 103, 103, 104, 104, 104, 104, 104, 104, 104, 104, 105, 105, 105, 105, 105, 105, 105, 105, 106, 106, 106, 106, 106, 106, 106, 106, 107, 107, 107, 107, 107, 107, 107, 107, 108, 108, 108, 108, 108, 108, 108, 108, 109, 109, 109, 109, 109, 109, 109, 109, 110, 110, 110, 110, 110, 110, 110, 110, 111, 111, 111, 111, 111, 111, 111, 111, 112, 112, 112, 112, 112, 112, 112, 112, 113, 113, 113, 113, 113, 113, 113, 113, 114, 114, 114, 114, 114, 114, 114, 114, 115, 115, 115, 115, 115, 115, 115, 115, 116, 116, 116, 116, 116, 116, 116, 116, 117, 117, 117, 117, 117, 117, 117, 117, 118, 118, 118, 118, 118, 118, 118, 118, 119, 119, 119, 119, 119, 119, 119, 119, 120, 120, 120, 120, 120, 120, 120, 120, 121, 121, 121, 121, 121, 121, 121, 121, 122, 122, 122, 122, 122, 122, 122, 122, 123, 123, 123, 123, 123, 123, 123, 123, 124, 124, 124, 124, 124, 124, 124, 124, 125, 125, 125, 125, 125, 125, 125, 125, 126, 126, 126, 126, 126, 126, 126, 126, 127, 127, 127, 127, 127, 127, 127, 127, 128, 128, 128, 128, 128, 128, 128, 128]),
          // @formatter:on
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 2560,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = actualTrezorEIP1559SignatureRequest.askForSupplementaryInfo();

      // Assert
      TrezorAskMoreDataResponse expectedTrezorOutboundResponse = TrezorAskMoreDataResponse(requestedBytesLength: 1024);

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });

  group('Tests of TrezorEIP1559SignatureRequest.fillData()', () {
    test('Should [fill the data parameter] when given ATrezorSupplementaryRequest', () async {
      // Arrange
      TrezorEIP1559SignatureRequest actualTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          data: Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8]),
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 16,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      TrezorEIP1559DataSupply trezorEIP1559DataSupply = TrezorEIP1559DataSupply(dataChunk: Uint8List.fromList(<int>[9, 10, 11, 12, 13, 14, 15, 16]));

      // Act
      actualTrezorEIP1559SignatureRequest = actualTrezorEIP1559SignatureRequest.fillData(trezorEIP1559DataSupply);

      // Assert
      TrezorEIP1559SignatureRequest expectedTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          data: Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]),
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 16,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      TestUtils.printInfo('Should [fill the data parameter] when given TrezorTxDataSupply');
      expect(actualTrezorEIP1559SignatureRequest, expectedTrezorEIP1559SignatureRequest);
    });
  });

  group('Tests of TrezorEIP1559SignatureRequest.requestReady()', () {
    test('Should [return false] if [data is NOT COMPLETE] (8 bytes, dataLength = 16)', () async {
      // Arrange
      TrezorEIP1559SignatureRequest actualTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          data: Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8]),
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 16,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      // Act
      bool actualRequestReadyBool = actualTrezorEIP1559SignatureRequest.requestReady;

      // Assert
      bool expectedRequestReadyBool = false;

      expect(actualRequestReadyBool, expectedRequestReadyBool);
    });

    test('Should [return true] if [data is COMPLETE] (16 bytes, dataLength = 16)', () async {
      // Arrange
      TrezorEIP1559SignatureRequest actualTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          data: Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]),
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 16,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      // Act
      bool actualRequestReadyBool = actualTrezorEIP1559SignatureRequest.requestReady;

      // Assert
      bool expectedRequestReadyBool = true;

      expect(actualRequestReadyBool, expectedRequestReadyBool);
    });
  });
}
