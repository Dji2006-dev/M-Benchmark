import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

const int PRIME_LIMIT = 90000;
const int MATRIX_SIZE = 320;
const int HASH_ROUNDS = 450;
const int FFT_ITER = 180;

class Complex {
  final double real;
  final double imag;
  const Complex(this.real, this.imag);
  Complex operator +(Complex other) =>
      Complex(real + other.real, imag + other.imag);
  Complex operator -(Complex other) =>
      Complex(real - other.real, imag - other.imag);
  Complex operator *(Complex other) => Complex(
    real * other.real - imag * other.imag,
    real * other.imag + imag * other.real,
  );
}

List<Complex> fft(List<Complex> x, bool invert) {
  int n = x.length;
  if (n == 1) return x;
  List<Complex> a0 = [], a1 = [];
  for (int i = 0; i < n; i++) {
    if (i.isEven)
      a0.add(x[i]);
    else
      a1.add(x[i]);
  }
  a0 = fft(a0, invert);
  a1 = fft(a1, invert);
  double ang = 2 * pi / n * (invert ? -1 : 1);
  Complex w = Complex(1, 0);
  Complex wn = Complex(cos(ang), sin(ang));
  for (int i = 0; i < n / 2; i++) {
    x[i] = a0[i] + w * a1[i];
    x[i + n ~/ 2] = a0[i] - w * a1[i];
    if (invert) {
      x[i] = Complex(x[i].real / 2, x[i].imag / 2);
      x[i + n ~/ 2] = Complex(x[i + n ~/ 2].real / 2, x[i + n ~/ 2].imag / 2);
    }
    w = w * wn;
  }
  return x;
}

int primeBench(int limit) {
  int count = 0;
  for (int i = 2; i < limit; i++) {
    bool ok = true;
    for (int j = 2; j * j <= i; j++) {
      if (i % j == 0) {
        ok = false;
        break;
      }
    }
    if (ok) count++;
  }
  return count;
}

List<List<double>> matrixMultiply(List<List<double>> a, List<List<double>> b) {
  int n = a.length;
  List<List<double>> res = List.generate(n, (_) => List.filled(n, 0.0));
  for (int i = 0; i < n; i++) {
    for (int k = 0; k < n; k++) {
      double ak = a[i][k];
      for (int j = 0; j < n; j++) {
        res[i][j] += ak * b[k][j];
      }
    }
  }
  return res;
}

int hashBench(int rounds) {
  final data = Uint8List.fromList(List.generate(1024, (i) => i % 255));
  int sum = 0;
  for (int i = 0; i < rounds; i++) {
    final digest = sha256.convert(data);
    sum += digest.bytes[0];
  }
  return sum;
}

// 子线程：全部任务跑完，只发送【完成】信号
void singleCoreWork(SendPort sendPort) {
  try {
    primeBench(PRIME_LIMIT);
    final mat = List.generate(
      MATRIX_SIZE,
      (_) => List.filled(MATRIX_SIZE, 1.23),
    );
    matrixMultiply(mat, mat);
    hashBench(HASH_ROUNDS);
    final fftData = List.generate(
      256,
      (i) => Complex(i.toDouble(), (i * 0.7).toDouble()),
    );
    for (int t = 0; t < FFT_ITER; t++) {
      fft(fftData, false);
    }
    sendPort.send("done");
  } catch (e) {
    sendPort.send("error");
  }
}

final Map<String, Map<String, String>> i18n = {
  "zh": {
    "title": "地狱难度CPU跑分",
    "mode_label": "运行线程数",
    "core_4": "4核",
    "core_8": "8核",
    "progress_text": "进度：{p} %",
    "score_label": "跑分得分：{s}",
    "start_btn_running": "正在跑分...",
    "start_btn_idle": "开始地狱跑分",
    "warn_text": "⚠️警告：会严重发热，不要连续多次运行！",
    "lang_label": "语言",
    "lang_zh": "中文",
    "lang_en": "English",
  },
  "en": {
    "title": "Hell‑Mode CPU Benchmark",
    "mode_label": "Thread Count",
    "core_4": "4 Threads",
    "core_8": "8 Threads",
    "progress_text": "Progress: {p} %",
    "score_label": "Score: {s}",
    "start_btn_running": "Running benchmark...",
    "start_btn_idle": "Start Hell Benchmark",
    "warn_text": "⚠️Warning: Heavy load, do not run repeatedly!",
    "lang_label": "Language",
    "lang_zh": "中文",
    "lang_en": "English",
  },
};

class HellBenchPage extends StatefulWidget {
  const HellBenchPage({super.key});

  @override
  State<HellBenchPage> createState() => _HellBenchPageState();
}

class _HellBenchPageState extends State<HellBenchPage> {
  bool _running = false;
  double _progress = 0;
  int? _score;
  String _lang = "zh";
  int _selectedCore = 4;
  int _finishedIsolate = 0;

  String tr(String key, {Map<String, String>? args}) {
    String text = i18n[_lang]![key]!;
    if (args != null) {
      args.forEach((k, v) {
        text = text.replaceAll("{$k}", v);
      });
    }
    return text;
  }

  Future<void> startBench() async {
    setState(() {
      _running = true;
      _progress = 0;
      _score = null;
      _finishedIsolate = 0;
    });

    final receivePort = ReceivePort();
    final stopwatch = Stopwatch()..start();
    final totalIsolate = _selectedCore;

    // 监听子线程完成消息
    receivePort.listen((msg) {
      setState(() {
        _finishedIsolate += 1;
        _progress = (_finishedIsolate / totalIsolate) * 100;
      });
      // 所有线程全部跑完
      if (_finishedIsolate >= totalIsolate) {
        stopwatch.stop();
        final seconds = stopwatch.elapsedMilliseconds / 1000;
        final int score = (120000 / seconds).round();
        setState(() {
          _score = score;
          _running = false;
        });
        receivePort.close();
      }
    });

    // 批量启动Isolate
    List<Future> isolateList = [];
    for (int i = 0; i < totalIsolate; i++) {
      isolateList.add(Isolate.spawn(singleCoreWork, receivePort.sendPort));
    }
    await Future.wait(isolateList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("title"))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(tr("lang_label")),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _lang,
                  items: [
                    DropdownMenuItem(value: "zh", child: Text(tr("lang_zh"))),
                    DropdownMenuItem(value: "en", child: Text(tr("lang_en"))),
                  ],
                  onChanged: _running
                      ? null
                      : (val) {
                          setState(() => _lang = val!);
                        },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(tr("mode_label")),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _selectedCore,
                  items: [
                    DropdownMenuItem(value: 4, child: Text(tr("core_4"))),
                    DropdownMenuItem(value: 8, child: Text(tr("core_8"))),
                  ],
                  onChanged: _running
                      ? null
                      : (val) {
                          setState(() => _selectedCore = val!);
                        },
                ),
              ],
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(value: _progress / 100, minHeight: 12),
            const SizedBox(height: 12),
            Text(
              tr("progress_text", args: {"p": _progress.toStringAsFixed(1)}),
            ),
            const SizedBox(height: 40),
            if (_score != null)
              Text(
                tr("score_label", args: {"s": "$_score"}),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _running ? null : startBench,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                _running ? tr("start_btn_running") : tr("start_btn_idle"),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr("warn_text"),
              style: const TextStyle(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
