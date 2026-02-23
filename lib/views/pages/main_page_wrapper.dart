import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/main_page_cubit.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/views/pages/data_transfer_page.dart';
import 'package:mirage/views/pages/idle_page.dart';
import 'package:mirage/views/widgets/device_selection_dialog.dart';
import 'package:win32audio/win32audio.dart';

class MainPageWrapper extends StatefulWidget {
  const MainPageWrapper({super.key});

  @override
  State<MainPageWrapper> createState() => _MainPageWrapperState();
}

class _MainPageWrapperState extends State<MainPageWrapper> {
  final MainPageCubit _mainPageCubit = MainPageCubit();
  List<AudioDevice> audioDeviceList = <AudioDevice>[];

  @override
  void initState() {
    super.initState();
    _mainPageCubit.loadPubkey();
    _fetchAudioDevices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainPageCubit, AMainPageState>(
      bloc: _mainPageCubit,
      builder: (BuildContext context, AMainPageState mainPageState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Mirage Demo Main Page'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showDeviceSelectionDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (mainPageState.pubkeyModel != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Active key: ${mainPageState.pubkeyModel!.hex}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (mainPageState is MainPageDisabledState) ...<Widget>[
                        IdlePage(reconnectNeededBool: mainPageState.pubkeyModel == null),
                      ],
                      if (mainPageState is MainPageEnabledState) ...<Widget>[
                        DataTransferPage(
                          mainPageEnabledState: mainPageState,
                          onSubmitted: _mainPageCubit.processRecordedMsg,
                          isDeviceListEmpty: _isDeviceListEmpty, onCancel: () {  },
                        ),
                      ],
                    ],
                  ),
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
