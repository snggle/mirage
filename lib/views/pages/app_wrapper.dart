import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/main_page_cubit.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_active_state.dart';
import 'package:mirage/blocs/pubkey_cubit/a_pubkey_state.dart';
import 'package:mirage/blocs/pubkey_cubit/pubkey_cubit.dart';
import 'package:mirage/blocs/pubkey_cubit/states/pubkey_uploading_state.dart';
import 'package:mirage/communication_visualizer.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/views/pages/main_page/main_page.dart';
import 'package:mirage/views/pages/manual_pubkey_upload_page.dart';
import 'package:mirage/views/widgets/device_selection_dialog.dart';
import 'package:win32audio/win32audio.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final PubkeyCubit _pubkeyCubit = globalLocator<PubkeyCubit>();
  final MainPageCubit _mainPageCubit = MainPageCubit();
  List<AudioDevice> audioDeviceList = <AudioDevice>[];
  late bool missingDataBool;

  @override
  void initState() {
    super.initState();
    _fetchAudioDevices();
    _pubkeyCubit.loadPubkey();
  }

  @override
  void dispose() {
    _pubkeyCubit.close();
    _mainPageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PubkeyCubit, APubkeyState>(
      bloc: _pubkeyCubit,
      builder: (BuildContext context, APubkeyState pubkeyState) {
        _mainPageCubit.updatePubkey(pubkeyModel: pubkeyState.pubkeyModel);

        return BlocListener<MainPageCubit, AMainPageState>(
          bloc: _mainPageCubit,
          listener: (BuildContext context, AMainPageState mainPageState) {
            if (mainPageState is MainPageActiveState) {
              if (mainPageState.isPubkeyRequiredAndMissing()) {
                _pubkeyCubit.openManualPubkeyUpload();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Mirage Demo App'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showDeviceSelectionDialog(context),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                CommunicationVisualizer(
                  walletConnectedBool: pubkeyState.pubkeyModel != null,
                ),
                if (pubkeyState is PubkeyUploadingState)
                  ManualPubkeyUploadPage(
                    isDeviceListEmpty: _isDeviceListEmpty,
                    onPubkeyUploaded: _uploadRecordedPubkey,
                    onCancel: _cancelManualPubkeyUpload,
                  )
                else
                  MainPage(
                    mainPageCubit: _mainPageCubit,
                    isDeviceListEmpty: _isDeviceListEmpty,
                    pubkeyModel: pubkeyState.pubkeyModel,
                    onOpenPubkeyUpload: _pubkeyCubit.openManualPubkeyUpload,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeviceSelectionDialog(BuildContext context) async {
    await _fetchAudioDevices();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          audioDeviceList.isEmpty ? 'No microphone detected - plug audio input device' : 'Select input device',
          style: const TextStyle(fontSize: 16),
        ),
        content: const DeviceSelectionDialog(),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _uploadRecordedPubkey(Uint8List recordedPubkeyCborObject) {
    _pubkeyCubit
      ..uploadPubkey(recordedPubkeyCborObject)
      ..closeManualPubkeyUpload();
  }

  void _cancelManualPubkeyUpload() {
    if (_mainPageCubit.state is MainPageActiveState) {
      _mainPageCubit.cancel();
    }
    _pubkeyCubit.closeManualPubkeyUpload();
  }

  Future<void> _fetchAudioDevices() async {
    if (mounted == false) {
      return;
    }
    audioDeviceList = await Audio.enumDevices(AudioDeviceType.input) ?? <AudioDevice>[];
  }

  Future<bool> _isDeviceListEmpty() async {
    await _fetchAudioDevices();
    return audioDeviceList.isEmpty;
  }
}
