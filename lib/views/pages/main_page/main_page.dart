import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/main_page_cubit.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_active_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_idle_state.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/views/pages/main_page/data_transfer_page.dart';
import 'package:mirage/views/pages/main_page/idle_page.dart';

class MainPage extends StatefulWidget {
  final MainPageCubit mainPageCubit;
  final Future<bool> Function() isDeviceListEmpty;
  final PubkeyModel? pubkeyModel;
  final VoidCallback onOpenPubkeyUpload;

  const MainPage({
    required this.mainPageCubit,
    required this.isDeviceListEmpty,
    required this.pubkeyModel,
    required this.onOpenPubkeyUpload,
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainPageCubit, AMainPageState>(
      bloc: widget.mainPageCubit,
      builder: (BuildContext context, AMainPageState mainPageState) {
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (mainPageState is MainPageIdleState)
                      IdlePage(
                        activePubkey: widget.pubkeyModel,
                        onOpenPubkeyUpload: widget.onOpenPubkeyUpload,
                      ),
                    if (mainPageState is MainPageActiveState) ...<Widget>[
                      DataTransferPage(
                        mainPageActiveState: mainPageState,
                        onSubmitted: widget.mainPageCubit.processRecordedMsg,
                        isDeviceListEmpty: widget.isDeviceListEmpty,
                        onCancel: widget.mainPageCubit.cancel,
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
