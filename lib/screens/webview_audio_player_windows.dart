import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class WebviewAudioPlayerWindows extends StatefulWidget {
  final String audioUrl;
  final String titolo;
  final Color playerColore;
  final Color testoColore;
  final Color testoSecColore;

  const WebviewAudioPlayerWindows({
    super.key,
    required this.audioUrl,
    required this.titolo,
    required this.playerColore,
    required this.testoColore,
    required this.testoSecColore,
  });

  @override
  State<WebviewAudioPlayerWindows> createState() =>
      _WebviewAudioPlayerWindowsState();
}

class _WebviewAudioPlayerWindowsState
    extends State<WebviewAudioPlayerWindows> {
  final _controller = WebviewController();
  bool _inizializzato = false;

  @override
  void initState() {
    super.initState();
    _inizializza();
  }

  Future<void> _inizializza() async {
    await _controller.initialize();
    await _controller.loadStringContent(_buildHtml());
    if (mounted) setState(() => _inizializzato = true);
  }

  @override
  void didUpdateWidget(WebviewAudioPlayerWindows oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl && _inizializzato) {
      _controller.loadStringContent(_buildHtml());
    }
  }

  String _colorToHex(Color color) =>
      '#${color.red.toRadixString(16).padLeft(2, '0')}'
          '${color.green.toRadixString(16).padLeft(2, '0')}'
          '${color.blue.toRadixString(16).padLeft(2, '0')}';

  String _buildHtml() {
    final bg = _colorToHex(widget.playerColore);
    final fg = _colorToHex(widget.testoColore);
    final sec = _colorToHex(widget.testoSecColore);
    final url = widget.audioUrl;
    final titolo = widget.titolo
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('"', '&quot;');

    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body {
    width: 100%; height: 100%;
    background: $bg;
    color: $fg;
    font-family: Segoe UI, sans-serif;
    overflow: hidden;
  }
  .player {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 0 20px;
    height: 100%;
    width: 100%;
  }
  .titolo {
    font-size: 13px;
    font-weight: 600;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 280px;
    min-width: 120px;
    color: $fg;
    flex-shrink: 0;
  }
  .btn {
    background: none;
    border: none;
    cursor: pointer;
    padding: 4px;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .time {
    font-size: 12px;
    color: $sec;
    white-space: nowrap;
    flex-shrink: 0;
    min-width: 40px;
    text-align: center;
  }
  .seek-wrap {
    flex: 1;
    display: flex;
    align-items: center;
    min-width: 0;
  }
  input[type=range] {
    -webkit-appearance: none;
    width: 100%;
    height: 4px;
    border-radius: 2px;
    background: $sec;
    outline: none;
    cursor: pointer;
  }
  input[type=range]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    background: $fg;
    cursor: pointer;
  }
  #progress { background: linear-gradient(to right, $fg 0%, $sec 0%); }
</style>
</head>
<body>
<div class="player">
  <div class="titolo">$titolo</div>

  <button class="btn" onclick="skip(-10)">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M11.99 5V1l-5 5 5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6h-2c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z" fill="$sec"/>
      <text x="12" y="15.5" text-anchor="middle" font-size="5.5" font-family="Segoe UI" fill="$sec">10</text>
    </svg>
  </button>

  <button class="btn" id="playBtn" onclick="togglePlay()">
    <svg id="playIcon" width="36" height="36" viewBox="0 0 24 24" fill="$fg">
      <path d="M8 5v14l11-7z"/>
    </svg>
    <svg id="pauseIcon" width="36" height="36" viewBox="0 0 24 24" fill="$fg" style="display:none">
      <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
    </svg>
  </button>

  <button class="btn" onclick="skip(10)">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M12.01 5V1l5 5-5 5V7c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6h2c0 4.42-3.58 8-8 8s-8-3.58-8-8 3.58-8 8-8z" fill="$sec"/>
      <text x="12" y="15.5" text-anchor="middle" font-size="5.5" font-family="Segoe UI" fill="$sec">10</text>
    </svg>
  </button>

  <span class="time" id="pos">00:00</span>
  <div class="seek-wrap">
    <input type="range" id="progress" min="0" max="100" value="0"
      oninput="onSeek(this.value)">
  </div>
  <span class="time" id="dur">00:00</span>
</div>

<audio id="audio" src="$url"></audio>

<script>
  const audio = document.getElementById('audio');
  const progress = document.getElementById('progress');
  const posEl = document.getElementById('pos');
  const durEl = document.getElementById('dur');
  const playIcon = document.getElementById('playIcon');
  const pauseIcon = document.getElementById('pauseIcon');

  // Tenta il play appena possibile con retry
  let playAttempted = false;
  function tentaPlay() {
    if (playAttempted) return;
    audio.play().then(() => {
      playAttempted = true;
    }).catch(() => {
      setTimeout(tentaPlay, 300);
    });
  }

  audio.addEventListener('canplay', tentaPlay, { once: true });
  audio.addEventListener('loadeddata', tentaPlay, { once: true });
  audio.addEventListener('loadedmetadata', tentaPlay, { once: true });
  // Fallback dopo 1 secondo
  setTimeout(tentaPlay, 1000);

  function fmt(s) {
    s = Math.floor(s || 0);
    const m = Math.floor(s / 60).toString().padStart(2, '0');
    const sec = (s % 60).toString().padStart(2, '0');
    return m + ':' + sec;
  }

  audio.addEventListener('timeupdate', () => {
    if (!audio.duration) return;
    const pct = (audio.currentTime / audio.duration) * 100;
    progress.value = pct;
    progress.style.background =
      'linear-gradient(to right, $fg ' + pct + '%, $sec ' + pct + '%)';
    posEl.textContent = fmt(audio.currentTime);
  });

  audio.addEventListener('durationchange', () => {
    durEl.textContent = fmt(audio.duration);
  });

  audio.addEventListener('play', () => {
    playAttempted = true;
    playIcon.style.display = 'none';
    pauseIcon.style.display = 'block';
  });

  audio.addEventListener('pause', () => {
    playIcon.style.display = 'block';
    pauseIcon.style.display = 'none';
  });

  audio.addEventListener('ended', () => {
    playAttempted = false;
    playIcon.style.display = 'block';
    pauseIcon.style.display = 'none';
    progress.value = 0;
    progress.style.background = 'linear-gradient(to right, $fg 0%, $sec 0%)';
    posEl.textContent = '00:00';
  });

  function togglePlay() {
    if (audio.paused) audio.play();
    else audio.pause();
  }

  function skip(sec) {
    audio.currentTime = Math.max(0,
      Math.min(audio.duration || 0, audio.currentTime + sec));
  }

  function onSeek(val) {
    if (audio.duration) audio.currentTime = (val / 100) * audio.duration;
  }
</script>
</body>
</html>''';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_inizializzato) {
      return SizedBox(
        height: 70,
        width: double.infinity,
        child: Center(child: CircularProgressIndicator(
            color: widget.testoColore, strokeWidth: 2)),
      );
    }
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Webview(_controller),
    );
  }
}