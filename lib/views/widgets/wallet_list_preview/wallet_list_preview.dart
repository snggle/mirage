import 'package:flutter/material.dart';
import 'package:mirage/shared/models/wallet_model.dart';
import 'package:mirage/views/widgets/wallet_list_preview/wallet_list_item.dart';

class WalletListPreview extends StatelessWidget {
  final List<WalletModel> walletModelList;

  const WalletListPreview({required this.walletModelList, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      children: <Widget>[
        for (final WalletModel walletModel in walletModelList) WalletListItem(walletModel: walletModel),
      ],
    );
  }
}
