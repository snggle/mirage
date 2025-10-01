import 'package:flutter/material.dart';
import 'package:mirage/shared/models/wallet_model.dart';
import 'package:mirage/views/widgets/wallet_list_preview/gradient_text.dart';
import 'package:mirage/views/widgets/wallet_list_preview/legacy_derivation_path_overflow_text.dart';
import 'package:mirage/views/widgets/wallet_list_preview/list_item_layout.dart';
import 'package:mirage/views/widgets/wallet_list_preview/wallet_icon.dart';

class WalletListItem extends StatelessWidget {
  final WalletModel walletModel;

  const WalletListItem({
    required this.walletModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ListItemLayout(
      iconWidget: WalletIcon(
        walletModel: walletModel,
      ),
      titleWidget: GradientText(
        walletModel.getShortAddress(4),
        textStyle: textTheme.titleMedium?.copyWith(fontSize: MediaQuery.of(context).size.width * 0.018),
        overflow: TextOverflow.ellipsis,
        gradient: const RadialGradient(
          radius: 7,
          center: Alignment(-1, 1.5),
          colors: <Color>[
            Color(0xFF000000),
            Color(0xFF42D2FF),
            Color(0xFF939393),
            Color(0xFF000000),
          ],
        ),
      ),
      subtitleWidget: LegacyDerivationPathOverflowText(
        derivationPath: walletModel.derivationPath,
        textAlign: TextAlign.start,
        textStyle: textTheme.labelMedium!.copyWith(
          color: const Color(0xFF969696),
          fontSize: MediaQuery.of(context).size.width * 0.018,
        ),
      ),
    );
  }
}
