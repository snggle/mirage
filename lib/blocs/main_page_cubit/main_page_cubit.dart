import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';

class MainPageCubit extends Cubit<AMainPageState> {
  MainPageCubit() : super(MainPageDisabledState());

  void enableAudioTransmission({required String title, required String audioRequestData}) {
    emit(MainPageEnabledState(
      title: title,
      audioRequestData: audioRequestData,
      userTextEditingController: TextEditingController(),
    ));
  }

  void receiveRecordedMsg() {
    emit(MainPageRecordedState(
      title: (state as MainPageEnabledState).title,
      audioRequestData: (state as MainPageEnabledState).audioRequestData,
      userTextEditingController: (state as MainPageEnabledState).userTextEditingController,
    ));
  }

  void disableAudioTransmission() {
    emit(MainPageDisabledState());
  }
}
