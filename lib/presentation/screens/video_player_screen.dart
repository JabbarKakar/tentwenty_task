import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../domain/entities/video_entity.dart';
import '../widgets/loading_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoEntity video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  WebViewController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Lock to landscape and full-screen immersive
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();
  }

  @override
  void dispose() {
    // Restore portrait and system UI when leaving (back to details screen)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      // Use movie/#MOVIE_ID#/videos API data: site (YouTube, Vimeo, Dailymotion) and key
      if (!widget.video.isPlayable) {
        setState(() {
          _hasError = true;
        });
        return;
      }

      final embedUrl = widget.video.embedUrl;
      if (embedUrl.isEmpty) {
        setState(() {
          _hasError = true;
        });
        return;
      }

      // Simple iframe embed for YouTube, Vimeo, Dailymotion. Listens for video end to auto-close.
      final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <meta name="referrer" content="strict-origin-when-cross-origin">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; background: #000; }
        iframe {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            border: none;
        }
    </style>
</head>
<body>
    <iframe
        id="player"
        src="$embedUrl"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
        onload="try{this.contentWindow.postMessage(JSON.stringify({event:'listening',id:1,channel:'widget'}),'*');}catch(e){}"
    ></iframe>
    <script>
        window.addEventListener('message', function(e) {
            try {
                if (typeof VideoEnd === 'undefined') return;
                var data = typeof e.data === 'string' ? (function(){try{return JSON.parse(e.data);}catch(x){return {};}})() : (e.data || {});
                var o = e.origin || '';
                if (o.indexOf('youtube.com') >= 0 || o.indexOf('youtube-nocookie.com') >= 0) {
                    if (data.event === 'infoDelivery' && data.info && data.info.playerState === 0) VideoEnd.postMessage('ended');
                    else if (typeof e.data === 'string' && (e.data.indexOf('"playerState":0') >= 0 || e.data.indexOf('"info":0') >= 0)) VideoEnd.postMessage('ended');
                } else if (o.indexOf('player.vimeo.com') >= 0) {
                    if (data.event === 'ended') VideoEnd.postMessage('ended');
                } else if (o.indexOf('dailymotion.com') >= 0) {
                    if (data.event === 'ended' || data.event === 'video_end' || data.type === 'ended') VideoEnd.postMessage('ended');
                }
            } catch(x) {}
        });
    </script>
</body>
</html>
      ''';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..addJavaScriptChannel(
          'VideoEnd',
          onMessageReceived: (JavaScriptMessage m) {
            if (m.message == 'ended' && mounted) {
              Navigator.of(context).pop();
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isInitialized = true;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // 152/153 = YouTube embed not allowed
              if (mounted && !_hasError && (error.errorCode == 153 || error.errorCode == 152)) {
                setState(() {
                  _hasError = true;
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              final u = request.url.toLowerCase();
              if (u.contains('youtube.com') || u.contains('youtu.be') ||
                  u.contains('vimeo.com') || u.contains('dailymotion.com')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        );

      // Allow autoplay without user gesture on Android
      if (_controller!.platform is AndroidWebViewController) {
        await (_controller!.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      await _controller!.loadHtmlString(
        htmlContent,
        baseUrl: 'https://example.com',
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  /// Open in native app or browser (YouTube, Vimeo, Dailymotion)
  Future<void> _openExternally() async {
    final url = widget.video.externalUrl;
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);

      // For YouTube: try app first
      if (widget.video.isYouTube) {
        try {
          final appUri = Uri.parse('vnd.youtube:${widget.video.key}');
          if (await canLaunchUrl(appUri)) {
            final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
            if (launched && mounted) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) Navigator.of(context).pop();
              });
              return;
            }
          }
        } catch (_) {}
      }

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched && mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) Navigator.of(context).pop();
          });
          return;
        }
      }

      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _onDone() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canOpenExternally = widget.video.externalUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to load trailer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.video.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _onDone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (canOpenExternally) ...[
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _openExternally,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Open in ${widget.video.externalLabel}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    )
                  : _isInitialized && _controller != null
                      ? WebViewWidget(controller: _controller!)
                      : const LoadingWidget.fullScreen(
                          color: Colors.white70,
                          message: 'Loading trailer...',
                        ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: _onDone,
            ),
          ),
        ],
      ),
    );
  }
}
