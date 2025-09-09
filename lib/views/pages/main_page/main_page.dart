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

  const MainPage({
    required this.mainPageCubit,
    required this.isDeviceListEmpty,
    required this.pubkeyModel,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (widget.pubkeyModel != null)
                      Expanded(
                        child: Text(
                          'Active key: ${widget.pubkeyModel!.hex}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    if (mainPageState is MainPageActiveState)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.mainPageCubit.cancel,
                      ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (mainPageState is MainPageIdleState) IdlePage(pubkeyExistsBool: widget.pubkeyModel != null),
                    if (mainPageState is MainPageActiveState) ...<Widget>[
                      DataTransferPage(
                        mainPageActiveState: mainPageState,
                        onSubmitted: widget.mainPageCubit.processRecordedMsg,
                        isDeviceListEmpty: widget.isDeviceListEmpty,
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
