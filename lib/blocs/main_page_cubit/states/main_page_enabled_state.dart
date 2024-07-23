import 'package:flutter/material.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';

class MainPageEnabledState extends AMainPageState {
  final String title;
  final String audioRequestData;
  final TextEditingController userTextEditingController;

  MainPageEnabledState({
    required this.title,
    required this.audioRequestData,
    required this.userTextEditingController,
  });

  @override
  List<Object?> get props => <Object>[title, audioRequestData, userTextEditingController];
}
