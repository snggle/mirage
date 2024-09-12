import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/main_page_cubit.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/views/pages/audio_recording_page.dart';
import 'package:mirage/views/pages/empty_page.dart';

class MainPageWrapper extends StatefulWidget {
  const MainPageWrapper({super.key});

  @override
  State<MainPageWrapper> createState() => _MainPageWrapperState();
}

class _MainPageWrapperState extends State<MainPageWrapper> {
  final MainPageCubit _mainPageCubit = MainPageCubit();

  @override
  void initState() {
    _mainPageCubit.loadPubkey();
    super.initState();
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
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (mainPageState.pubkeyModel != null)
                        Expanded(
                          child: Text(
                            'Active key: ${mainPageState.pubkeyModel!.hex}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      if (mainPageState is MainPageEnabledState)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _mainPageCubit.cancel,
                        ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (mainPageState is MainPageDisabledState) ...<Widget>[
                        EmptyPage(reconnectNeededBool: mainPageState.pubkeyModel == null),
                      ],
                      if (mainPageState is MainPageEnabledState) ...<Widget>[
                        AudioRecordingPage(
                          mainPageState: mainPageState,
                          onSubmitted: _mainPageCubit.processRecordedMsg,
                          onCompleted: _mainPageCubit.completeInteractiveRequest,
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
}
