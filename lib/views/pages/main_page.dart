import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/main_page_cubit.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/config/locator.dart';

class MainPage extends StatelessWidget {
  final String title;
  final MainPageCubit _xCubit = globalLocator<MainPageCubit>();

  MainPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainPageCubit, AMainPageState>(
      bloc: _xCubit,
      builder: (BuildContext context, AMainPageState state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (state is MainPageDisabledState)
                  const Text(
                    'Trezor Virtualization',
                  ),
                if (state is MainPageEnabledState) ...<Widget>[
                  Text(state.title),
                  SelectableText(state.audioRequestData.toString()),
                  Expanded(
                    // child: TransmissionWidget(audioMsgOutbound: state.audioMsgOutbound),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Column(
                              children: <Widget>[
                                  TextFormField(
                                    decoration: const InputDecoration(labelText: 'recorded audio'),
                                    controller: state.userTextEditingController,
                                  ),
                                if (state is MainPageRecordedState == false)
                                FloatingActionButton(
                                  onPressed: _xCubit.receiveRecordedMsg,
                                  tooltip: 'Submit',
                                  child: const Icon(Icons.navigate_next_outlined),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
                if (state is MainPageRecordedState) ...<Widget>[
                  const Text('Received a correct message. You can proceed by clicking the button'),
                  FloatingActionButton(
                    onPressed: _xCubit.disableAudioTransmission,
                    tooltip: 'Proceed',
                    child: const Icon(Icons.navigate_next_outlined),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
