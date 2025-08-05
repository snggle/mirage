import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:win32audio/win32audio.dart';

class DeviceSelector extends StatefulWidget {
  const DeviceSelector({super.key});

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  List<AudioDevice> _audioDeviceList = <AudioDevice>[];
  Map<String, Uint8List?> _audioIdIconMap = <String, Uint8List?>{};

  double _volume = 0.0;

  @override
  void initState() {
    super.initState();
    _reloadAudioDevices();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: 70,
            child: Column(
              children: <Widget>[
                if (_audioDeviceList.isNotEmpty) ...<Widget>[
                  Center(
                    child: Text(
                      'Volume: ${(_volume * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Slider(
                    value: _volume,
                    min: 0,
                    max: 1,
                    divisions: 25,
                    onChanged: (double e) async {
                      await Audio.setVolume(e.toDouble(), AudioDeviceType.input);
                      _volume = e;
                      setState(() {});
                    },
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _audioDeviceList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  leading: (_audioIdIconMap.containsKey(_audioDeviceList[index].id))
                      ? Image.memory(
                          _audioIdIconMap[_audioDeviceList[index].id] ?? Uint8List(0),
                          width: 28,
                          height: 28,
                          gaplessPlayback: true,
                        )
                      : const Icon(Icons.spoke_outlined),
                  title: Text(
                    _audioDeviceList[index].name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: Icon(_audioDeviceList[index].isActive == true ? Icons.radio_button_checked : Icons.radio_button_off),
                    iconSize: 16,
                    onPressed: () async {
                      await Audio.setDefaultDevice(_audioDeviceList[index].id);
                      await _reloadAudioDevices();
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(
            thickness: 5,
            height: 10,
            color: Color.fromARGB(12, 0, 0, 0),
          ),
        ],
      ),
    );
  }

  Future<void> _reloadAudioDevices() async {
    if (mounted == false) {
      return;
    }
    _audioDeviceList = await Audio.enumDevices(AudioDeviceType.input) ?? <AudioDevice>[];
    _volume = await Audio.getVolume(AudioDeviceType.input);

    _audioIdIconMap = <String, Uint8List>{};
    for (AudioDevice audioDevice in _audioDeviceList) {
      if (_audioIdIconMap[audioDevice.id] == null) {
        _audioIdIconMap[audioDevice.id] = await WinIcons().extractFileIcon(audioDevice.iconPath, iconID: audioDevice.iconID);
      }
    }

    setState(() {});
  }
}
