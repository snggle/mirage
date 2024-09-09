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
  Widget build(BuildContext context) {
    return BlocBuilder<MainPageCubit, AMainPageState>(
      bloc: _mainPageCubit,
      builder: (BuildContext context, AMainPageState mainPageState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Mirage Demo Main Page'),
          ),
          body: Stack(
            children: <Widget>[
              if (mainPageState is MainPageEnabledState)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(icon: const Icon(Icons.close), onPressed: _mainPageCubit.cancel),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (mainPageState is MainPageDisabledState) ...<Widget>[
                      const EmptyPage(),
                    ],
                    if (mainPageState is MainPageEnabledState) ...<Widget>[
                      AudioRecordingPage(
                        mainPageState: mainPageState,
                        mainPageCubit: _mainPageCubit,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
