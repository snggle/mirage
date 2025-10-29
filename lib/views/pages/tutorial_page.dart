import 'package:flutter/material.dart';
import 'package:mirage/views/widgets/tutorial_slide.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialPage extends StatefulWidget {
  final String title;
  final List<TutorialSlide> slides;

  const TutorialPage({
    required this.title,
    required this.slides,
    super.key,
  });

  TutorialPage.walletConnect({Key? key})
      : title = 'Connect wallet on MetaMask - Tutorial',
        slides = <TutorialSlide>[
          TutorialSlide(
            text: 'This instruction describes the process of connecting to MetaMask via audio, using Snggle and Mirage',
            imagePath: 'assets/wallet_connect_tutorial_images/0.png',
          ),
          TutorialSlide(
            text: 'Open MetaMask, click on the account dropdown',
            imagePath: 'assets/wallet_connect_tutorial_images/1.png',
          ),
          TutorialSlide(
            text: 'Press "add account or wallet" button',
            imagePath: 'assets/wallet_connect_tutorial_images/2.png',
          ),
          TutorialSlide(
            text: 'Select "Hardware wallet"',
            imagePath: 'assets/wallet_connect_tutorial_images/3.png',
          ),
          TutorialSlide(
            text: 'Choose Trezor and press the "Continue" button (Mirage needs to be running)',
            imagePath: 'assets/wallet_connect_tutorial_images/4.png',
          ),
          TutorialSlide(
            text: 'On the Trezor page, allow permissions to read public keys',
            imagePath: 'assets/wallet_connect_tutorial_images/5.png',
          ),
          TutorialSlide(
            text: 'Press the "Export" button',
            imagePath: 'assets/wallet_connect_tutorial_images/6.png',
          ),
          TutorialSlide(
            text:
                'Mirage will detect the action, press the "Start recording" button. Optionally configure the audio recording device, by clicking the Settings icon.',
            imagePath: 'assets/wallet_connect_tutorial_images/7.png',
          ),
          TutorialSlide(
            text: 'Go to snggle and open the wallet you want to use, then press the "Connect wallet" button',
            imagePath: 'assets/wallet_connect_tutorial_images/8.png',
          ),
          TutorialSlide(
            text: 'Select the "Hardware based" option and press the "Audio interface" button',
            imagePath: 'assets/wallet_connect_tutorial_images/9.png',
          ),
          TutorialSlide(
            text: 'Press the "Emit audio" button and try to record it via Mirage',
            imagePath: 'assets/wallet_connect_tutorial_images/10.png',
          ),
          TutorialSlide(
            text: 'If the recording was successful, press the "Submit" button. If not, try again.',
            imagePath: 'assets/wallet_connect_tutorial_images/11.png',
          ),
          TutorialSlide(
            text: 'Select accounts you want to use on MetaMask',
            imagePath: 'assets/wallet_connect_tutorial_images/12.png',
          ),
          TutorialSlide(
            text: 'Press the "Unlock" button',
            imagePath: 'assets/wallet_connect_tutorial_images/13.png',
          ),
          TutorialSlide(
            text: 'You are ready to perform transactions on MetaMask',
            imagePath: 'assets/wallet_connect_tutorial_images/14.png',
          ),
          TutorialSlide(
            text: 'Mirage stores the pubkey data and is ready to handle transactions',
            imagePath: 'assets/wallet_connect_tutorial_images/15.png',
          ),
        ],
        super(key: key);

  TutorialPage.hardReset({Key? key})
      : title = 'Hard reset on MetaMask - Tutorial',
        slides = <TutorialSlide>[
          TutorialSlide(
            text: 'This instruction shows how to delete Trezor account on MetaMask, to allow connecting another account.\nWarning! The transaction history on MetaMask will be lost.',
            imagePath: 'assets/hard_reset_tutorial_images/0.png',
          ),
          TutorialSlide(
            text: 'Start by clicking on the account dropdown',
            imagePath: 'assets/hard_reset_tutorial_images/1.png',
          ),
          TutorialSlide(
            text: 'Press "add account or wallet" button',
            imagePath: 'assets/hard_reset_tutorial_images/2.png',
          ),
          TutorialSlide(
            text: 'Select "Hardware wallet"',
            imagePath: 'assets/hard_reset_tutorial_images/3.png',
          ),
          TutorialSlide(
            text: 'Choose Trezor and press the "Continue" button',
            imagePath: 'assets/hard_reset_tutorial_images/4.png',
          ),
          TutorialSlide(
            text: 'On the Trezor page, allow permissions to read public keys',
            imagePath: 'assets/hard_reset_tutorial_images/5.png',
          ),
          TutorialSlide(
            text: 'Press the "Export" button',
            imagePath: 'assets/hard_reset_tutorial_images/6.png',
          ),
          TutorialSlide(
            text: 'Press "Forget this device"',
            imagePath: 'assets/hard_reset_tutorial_images/7.png',
          ),
          TutorialSlide(
            text: 'Now you can connect another wallet',
            imagePath: 'assets/hard_reset_tutorial_images/8.png',
          ),
        ],
        super(key: key);

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex < widget.slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TutorialSlide> slides = widget.slides;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: slides.length,
        onPageChanged: (int i) => setState(() => _currentIndex = i),
        itemBuilder: (_, int index) {
          final TutorialSlide slide = slides[index];
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Image.asset(
                    slide.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(slide.text, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Text('${_currentIndex + 1} / ${slides.length}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SmoothPageIndicator(
              controller: _controller,
              count: slides.length,
              effect: const WormEffect(dotHeight: 10, dotWidth: 10),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton(onPressed: _currentIndex > 0 ? _goPrev : null, child: const Text('Previous')),
                ElevatedButton(
                  onPressed: _goNext,
                  child: Text(_currentIndex == slides.length - 1 ? 'Finish' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
