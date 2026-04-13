// Copyright (c)  2024  Xiaomi Corporation
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import './model.dart';
import './utils.dart';

class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  sherpa_onnx.OfflineTts? _tts;
  AudioPlayer? _player;
  bool _isInitialized = false;
  int _maxSpeakerID = 0;
  double _speed = 1.0;
  String _lastFilename = '';

  Future<void> init() async {
    if (!_isInitialized) {
      sherpa_onnx.initBindings();
      _tts?.free();
      _tts = await createOfflineTts();
      _player = AudioPlayer();
      _isInitialized = true;
      _maxSpeakerID = _tts?.numSpeakers ?? 0;
      if (_maxSpeakerID > 0) {
        _maxSpeakerID -= 1;
      }
    }
  }

  /// 播放指定文本
  /// [text] 要播放的文本
  /// [sid] 说话人ID,默认为0
  /// [speed] 语速,默认为1.0
  /// 返回是否播放成功
  Future<bool> speak(String text, {int sid = 0, double speed = 1.0}) async {
    await init();

    if (_tts == null) {
      debugPrint('Failed to initialize tts');
      return false;
    }

    if (text.trim().isEmpty) {
      debugPrint('Text is empty');
      return false;
    }

    try {
      await _player?.stop();

      final stopwatch = Stopwatch();
      stopwatch.start();

      final genConfig = sherpa_onnx.OfflineTtsGenerationConfig(
        sid: sid,
        speed: speed,
        silenceScale: 0.2,
      );

      final audio = _tts!.generateWithConfig(text: text, config: genConfig);
      final suffix = '-sid-$sid-speed-${speed.toStringAsPrecision(2)}';
      final filename = await generateWaveFilename(suffix);

      final ok = sherpa_onnx.writeWave(
        filename: filename,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );

      if (ok) {
        stopwatch.stop();
        double elapsed = stopwatch.elapsed.inMilliseconds.toDouble();
        double waveDuration = audio.samples.length.toDouble() / audio.sampleRate.toDouble();

        debugPrint('Saved to $filename');
        debugPrint('Elapsed: ${(elapsed / 1000).toStringAsPrecision(4)} s');
        debugPrint('Wave duration: ${waveDuration.toStringAsPrecision(4)} s');
        debugPrint('RTF: ${(elapsed / 1000 / waveDuration).toStringAsPrecision(3)}');

        _lastFilename = filename;
        await _player?.play(DeviceFileSource(_lastFilename));
        return true;
      } else {
        debugPrint('Failed to save generated audio');
        return false;
      }
    } catch (e) {
      debugPrint('Error during TTS generation: $e');
      return false;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _player?.stop();
  }

  void dispose() {
    _tts?.free();
    _player?.dispose();
  }
}

class _TtsScreenState extends State<TtsScreen> {
  late final TextEditingController _controller_text_input;
  late final TextEditingController _controller_sid;
  late final TextEditingController _controller_hint;
  late final AudioPlayer _player;
  String _title = 'Text to speech';
  String _lastFilename = '';
  bool _isInitialized = false;
  int _maxSpeakerID = 0;
  double _speed = 1.0;

  sherpa_onnx.OfflineTts? _tts;

  @override
  void initState() {
    _controller_text_input = TextEditingController();
    _controller_hint = TextEditingController();
    _controller_sid = TextEditingController(text: '0');

    super.initState();
  }

  Future<void> _init() async {
    if (!_isInitialized) {
      sherpa_onnx.initBindings();

      _tts?.free();
      _tts = await createOfflineTts();

      _player = AudioPlayer();

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                  decoration: InputDecoration(
                    labelText: "Speaker ID (0-$_maxSpeakerID)",
                    hintText: 'Please input your speaker ID',
                  ),
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  controller: _controller_sid,
                  onTapOutside: (PointerDownEvent event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]),
              Slider(
                // decoration: InputDecoration(
                //   labelText: "speech speed",
                // ),
                label: "Speech speed ${_speed.toStringAsPrecision(2)}",
                min: 0.5,
                max: 3.0,
                divisions: 25,
                value: _speed,
                onChanged: (value) {
                  setState(() {
                    _speed = value;
                  });
                },
              ),
              const SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Please enter your text here',
                ),
                maxLines: 5,
                controller: _controller_text_input,
                onTapOutside: (PointerDownEvent event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                OutlinedButton(
                  child: Text("Test"),
                  onPressed: () async {
                    await TtsService().speak('你好,这是一个测试');
                  },
                ),
                const SizedBox(width: 5),
                OutlinedButton(
                  child: Text("Generate"),
                  onPressed: () async {
                    await _init();
                    await _player?.stop();

                    setState(() {
                      _maxSpeakerID = _tts?.numSpeakers ?? 0;
                      if (_maxSpeakerID > 0) {
                        _maxSpeakerID -= 1;
                      }
                    });

                    if (_tts == null) {
                      _controller_hint.value = TextEditingValue(
                        text: 'Failed to initialize tts',
                      );
                      return;
                    }

                    _controller_hint.value = TextEditingValue(
                      text: '',
                    );

                    final text = _controller_text_input.text.trim();
                    if (text == '') {
                      _controller_hint.value = TextEditingValue(
                        text: 'Please first input your text to generate',
                      );
                      return;
                    }

                    final sid = int.tryParse(_controller_sid.text.trim()) ?? 0;

                    final stopwatch = Stopwatch();
                    stopwatch.start();
                    final genConfig = sherpa_onnx.OfflineTtsGenerationConfig(
                      sid: sid,
                      speed: _speed,
                      silenceScale: 0.2,
                    );
                    final audio =
                        _tts!.generateWithConfig(text: text, config: genConfig);
                    final suffix = '-sid-$sid-speed-${_speed.toStringAsPrecision(2)}';
                    final filename = await generateWaveFilename(suffix);

                    final ok = sherpa_onnx.writeWave(
                      filename: filename,
                      samples: audio.samples,
                      sampleRate: audio.sampleRate,
                    );

                    if (ok) {
                      stopwatch.stop();
                      double elapsed = stopwatch.elapsed.inMilliseconds.toDouble();

                      double waveDuration = audio.samples.length.toDouble() / audio.sampleRate.toDouble();

                      _controller_hint.value = TextEditingValue(
                        text: 'Saved to\n$filename\n'
                            'Elapsed: ${(elapsed / 1000).toStringAsPrecision(4)} s\n'
                            'Wave duration: ${waveDuration.toStringAsPrecision(4)} s\n'
                            'RTF: ${(elapsed / 1000).toStringAsPrecision(4)}/${waveDuration.toStringAsPrecision(4)} '
                            '= ${(elapsed / 1000 / waveDuration).toStringAsPrecision(3)} ',
                      );
                      _lastFilename = filename;

                      await _player?.play(DeviceFileSource(_lastFilename));
                    } else {
                      _controller_hint.value = TextEditingValue(
                        text: 'Failed to save generated audio',
                      );
                    }
                  },
                ),
                const SizedBox(width: 5),
                OutlinedButton(
                  child: Text("Clear"),
                  onPressed: () {
                    _controller_text_input.value = TextEditingValue(
                      text: '',
                    );

                    _controller_hint.value = TextEditingValue(
                      text: '',
                    );
                  },
                ),
                const SizedBox(width: 5),
                OutlinedButton(
                  child: Text("Play"),
                  onPressed: () async {
                    if (_lastFilename == '') {
                      _controller_hint.value = TextEditingValue(
                        text: 'No generated wave file found',
                      );
                      return;
                    }
                    await _player?.stop();
                    await _player?.play(DeviceFileSource(_lastFilename));
                    _controller_hint.value = TextEditingValue(
                      text: 'Playing\n$_lastFilename',
                    );
                  },
                ),
                const SizedBox(width: 5),
                OutlinedButton(
                  child: Text("Stop"),
                  onPressed: () async {
                    await _player?.stop();
                    _controller_hint.value = TextEditingValue(
                      text: '',
                    );
                  },
                ),
              ]),
              const SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Logs will be shown here.\n'
                      'The first run is slower due to model initialization.',
                ),
                maxLines: 6,
                controller: _controller_hint,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts?.free();
    super.dispose();
  }
}
