import 'package:blockies_svg/blockies_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirage/shared/models/wallet_model.dart';

class WalletIcon extends StatelessWidget {
  final WalletModel walletModel;

  const WalletIcon({
    required this.walletModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 40;

    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: SvgPicture.string(
          Blockies(seed: walletModel.address).toSvg(size: size.toInt()),
          width: size,
          height: size,
          fit: BoxFit.cover,
          allowDrawingOutsideViewBox: true,
        ),
      ),
    );
  }
}
