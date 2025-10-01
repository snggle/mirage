import 'package:flutter/material.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/models/wallet_model.dart';
import 'package:mirage/views/pages/tutorial_page.dart';
import 'package:mirage/views/widgets/wallet_list_preview/wallet_list_preview.dart';

class IdlePage extends StatefulWidget {
  final PubkeyModel? activePubkey;
  final VoidCallback onOpenPubkeyUpload;

  const IdlePage({
    required this.activePubkey,
    required this.onOpenPubkeyUpload,
    super.key,
  });

  @override
  State<IdlePage> createState() => _IdlePageState();
}

class _IdlePageState extends State<IdlePage> {
  List<WalletModel>? _walletListModel;

  @override
  void initState() {
    super.initState();
    _reloadWallets();
  }

  @override
  void didUpdateWidget(covariant IdlePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activePubkey != widget.activePubkey) {
      _reloadWallets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (_walletListModel == null) ...<Widget>[
            const SizedBox(height: 60),
            const Text('Wallet not connected', style: TextStyle(fontSize: 20)),
          ],
          if (_walletListModel != null) ...<Widget>[
            const SizedBox(height: 30),
            const Text('Mirage is waiting for your actions on MetaMask', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 400,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => TutorialPage.walletConnect()),
                      );
                    },
                    child: const Text(
                      'Connect to MetaMask or Reset MetaMask',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => TutorialPage.hardReset()),
                      );
                    },
                    child: const Text(
                      'Send Transaction on MetaMask',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          if (_walletListModel == null) ...<Widget>[
            ElevatedButton(onPressed: widget.onOpenPubkeyUpload, child: const Text('Connect wallet')),
            const SizedBox(height: 50),
          ],
          if (_walletListModel != null) ...<Widget>[
            WalletListPreview(walletModelList: _walletListModel!),
            const SizedBox(height: 10),
            const Text('Example wallets preview', style: TextStyle(fontSize: 12, color: Color(0x95444444))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: widget.onOpenPubkeyUpload, child: const Text('Change wallet')),
            const SizedBox(height: 50),
          ],
        ],
      ),
    );
  }

  void _reloadWallets() {
    if (widget.activePubkey != null) {
      setState(() {
        _walletListModel = _deriveWallets(widget.activePubkey!);
      });
    }
  }

  List<WalletModel> _deriveWallets(PubkeyModel pubkey, {int count = 6}) {
    return List<WalletModel>.generate(count, (int i) {
      PubkeyModel derived = pubkey.derive(i);
      return WalletModel(
        address: derived.ethereumAddress,
        derivationPath: "m/44'/60'/0'/0/$i",
      );
    });
  }
}
