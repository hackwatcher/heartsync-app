import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/sync_colors.dart';
import '../core/services/watch_service.dart';

import '../ui/notification_system.dart';
import '../ui/video_call_overlay.dart';
import '../ui/ai_cowatch_overlay.dart';

class CinemaBrowserScreen extends StatefulWidget {
  const CinemaBrowserScreen({super.key});

  @override
  State<CinemaBrowserScreen> createState() => _CinemaBrowserScreenState();
}

class _CinemaBrowserScreenState extends State<CinemaBrowserScreen> {
  InAppWebViewController? _webViewController;
  final TextEditingController _urlController = TextEditingController();
  final WatchService _watchService = WatchService();

  bool _isSyncing = false;
  bool _showLaunchpad = true;
  double _progress = 0;

  final List<Map<String, String>> _quickLinks = [
    {'name': 'YouTube', 'url': 'https://www.youtube.com', 'id': 'youtube'},
    {'name': 'Netflix', 'url': 'https://www.netflix.com', 'id': 'netflix'},
    {'name': 'Disney+', 'url': 'https://www.disneyplus.com', 'id': 'disney'},
    {'name': 'Prime Video', 'url': 'https://www.primevideo.com', 'id': 'prime'},
  ];

  // JavaScript for video synchronization (Robust for SPAs like YouTube/Netflix)
  final String _syncJS = """
    (function() {
      if (window.hsInitDone) return;
      window.hsInitDone = true;
      window.isRemoteCommand = false;
      
      function attachVideoListeners() {
        var video = document.querySelector('video');
        if (video && !video.hsHandlerSet) {
          video.hsHandlerSet = true;
          video.addEventListener('play', function() { 
            if(!window.isRemoteCommand) window.flutter_inappwebview.callHandler('onVideoPlay', video.currentTime); 
          });
          video.addEventListener('pause', function() { 
            if(!window.isRemoteCommand) window.flutter_inappwebview.callHandler('onVideoPause', video.currentTime); 
          });
          video.addEventListener('seeked', function() { 
            if(!window.isRemoteCommand) window.flutter_inappwebview.callHandler('onVideoSeek', video.currentTime); 
          });
          video.addEventListener('waiting', function() { 
            if(!window.isRemoteCommand) window.flutter_inappwebview.callHandler('onVideoBuffer', video.currentTime); 
          });
          console.log('HeartSync: Video listeners attached.');
        }
      }
      
      // Monitor URL changes for navigation sync
      var lastUrl = location.href;
      function checkUrlChange() {
        if (location.href !== lastUrl) {
          lastUrl = location.href;
          if(!window.isRemoteCommand) window.flutter_inappwebview.callHandler('onUrlChange', lastUrl);
        }
      }

      window.hsExecuteRemote = function(action, time, url) {
        window.isRemoteCommand = true;
        
        if (action === 'changeUrl' && url) {
           location.href = url;
           setTimeout(() => { window.isRemoteCommand = false; }, 2000);
           return;
        }
        
        var video = document.querySelector('video');
        if(!video) return;
        
        if (action === 'play') {
          if (video.paused) video.play();
          
          // Soft Correction Engine (<150ms drift target)
          if (time > 0) {
            var drift = time - video.currentTime;
            if (Math.abs(drift) > 2.0) {
              // Hard correction
              video.currentTime = time;
              video.playbackRate = 1.0;
            } else if (drift > 0.15) {
              // Client is behind -> Soft speed up
              video.playbackRate = 1.05;
              setTimeout(() => { if(video) video.playbackRate = 1.0; }, Math.abs(drift / 0.05) * 1000);
            } else if (drift < -0.15) {
              // Client is ahead -> Soft slow down
              video.playbackRate = 0.95;
              setTimeout(() => { if(video) video.playbackRate = 1.0; }, Math.abs(drift / 0.05) * 1000);
            } else {
              video.playbackRate = 1.0;
            }
          }
        } else if (action === 'pause') {
          if (!video.paused) video.pause();
          if (time > 0 && Math.abs(video.currentTime - time) > 0.5) video.currentTime = time;
        } else if (action === 'seek') {
          if (Math.abs(video.currentTime - time) > 1.0) {
            video.currentTime = time;
          }
        }
        
        setTimeout(() => { window.isRemoteCommand = false; }, 300);
      };

      // Check immediately, and also observe DOM changes for dynamically loaded videos
      attachVideoListeners();
      var observer = new MutationObserver(() => {
        attachVideoListeners();
        checkUrlChange();
      });
      observer.observe(document.body, { childList: true, subtree: true });
    })();
  """;

  @override
  void initState() {
    super.initState();
    _setupWatchListeners();
  }

  void _setupWatchListeners() {
    _watchService.watchEventStream.listen((event) {
      if (!_isSyncing || _webViewController == null) return;
      switch (event.type) {
        case WatchEventType.play:
          _webViewController!.evaluateJavascript(source: "window.hsExecuteRemote('play', ${event.position.inMilliseconds / 1000.0});");
          break;
        case WatchEventType.pause:
          _webViewController!.evaluateJavascript(source: "window.hsExecuteRemote('pause', ${event.position.inMilliseconds / 1000.0});");
          break;
        case WatchEventType.seek:
          _webViewController!.evaluateJavascript(source: "window.hsExecuteRemote('seek', ${event.position.inMilliseconds / 1000.0});");
          break;
        case WatchEventType.changeVideo:
          if (event.videoUrl != null && _urlController.text != event.videoUrl) {
            _webViewController!.evaluateJavascript(source: "window.hsExecuteRemote('changeUrl', 0, '${event.videoUrl}');");
            setState(() {
              _urlController.text = event.videoUrl!;
            });
          }
          break;
        case WatchEventType.buffer:
          _webViewController!.evaluateJavascript(source: "window.hsExecuteRemote('pause', 0);");
          SyncNotification.show(context, message: 'Partner bağlantısı bekleniyor...', icon: Icons.wifi_protected_setup_rounded, type: NotificationType.urgent);
          break;
      }
    });
  }

  void _loadUrl(String url) {
    String finalUrl = url.trim();
    if (finalUrl.isEmpty) return;
    
    // Check if it looks like a URL or a search query
    bool isUrl = RegExp(r"^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$").hasMatch(finalUrl);
    
    if (isUrl) {
      if (!finalUrl.startsWith('http')) finalUrl = 'https://$finalUrl';
    } else {
      // Treat as search query
      finalUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(finalUrl)}';
    }
    
    _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(finalUrl)));
    setState(() {
      _showLaunchpad = false;
      _urlController.text = finalUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SyncColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildBrowserToolbar(),
                if (_progress < 1.0 && !_showLaunchpad)
                  LinearProgressIndicator(value: _progress, backgroundColor: Colors.transparent, color: SyncColors.coral, minHeight: 2),

                Expanded(
                  child: Stack(
                    children: [
                      // Browser Launchpad (Shown when empty)
                      if (_showLaunchpad)
                        _buildLaunchpad(),

                      // WebView (Shown when a URL is loaded)
                      Offstage(
                        offstage: _showLaunchpad,
                        child: InAppWebView(
                          initialUrlRequest: URLRequest(url: WebUri('about:blank')),
                          onWebViewCreated: (controller) {
                            _webViewController = controller;
                            _setupJSHandlers(controller);
                          },
                          onLoadStop: (controller, url) {
                            if (url != null && url.toString() != 'about:blank') {
                              setState(() {
                                _urlController.text = url.toString();
                                _showLaunchpad = false;
                              });
                            }
                            controller.evaluateJavascript(source: _syncJS);
                          },
                          onProgressChanged: (controller, progress) {
                            setState(() => _progress = progress / 100);
                          },
                        ),
                      ),
                      
                      if (!_showLaunchpad)
                        Positioned(bottom: 24, right: 24, child: _buildSyncFloatingButton()),
                    ],
                  ),
                ),
              ],
            ),
            const VideoCallOverlay(), // Floating camera heads over the browser
            if (_isSyncing) const AICoWatchOverlay(), // AI Co-Pilot
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchpad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Ne İzlemek İstersin?', style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Birlikte izlemek için bir platform seçin veya arama yapın.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              itemCount: _quickLinks.length,
              itemBuilder: (context, index) {
                final link = _quickLinks[index];
                return GestureDetector(
                  onTap: () => _loadUrl(link['url']!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -5),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNativeLogo(link['id']!),
                        const SizedBox(height: 16),
                        Text(link['name']!, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                      ],
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms).scale(begin: const Offset(0.9, 0.9)).shimmer(delay: 1000.ms, duration: 1000.ms, color: Colors.white12),
                );
              },
            ),
          ),
          // Home button to reset
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showLaunchpad = true),
              icon: const Icon(Icons.home_rounded, color: SyncColors.textSecondary, size: 16),
              label: const Text('Reset to Launchpad', style: TextStyle(color: SyncColors.textSecondary, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeLogo(String id) {
    switch (id) {
      case 'youtube':
        return Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF0000), Color(0xFFCC0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)],
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
        );
      case 'netflix':
        return Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent, width: 2),
            boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
          ),
          child: const Center(child: Text('N', style: TextStyle(color: Colors.redAccent, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Arial'))),
        );
      case 'disney':
        return Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF113CCF), Color(0xFF001140)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)],
          ),
          child: const Center(child: Text('Disney+', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))),
        );
      case 'prime':
        return Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF00A8E1).withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00A8E1), width: 1.5),
          ),
          child: const Center(child: Text('prime', style: TextStyle(color: Color(0xFF00A8E1), fontSize: 14, fontWeight: FontWeight.bold))),
        );
      default:
        return Container(
          width: 56, height: 56,
          decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
          child: const Icon(Icons.movie_rounded, color: Colors.white54, size: 28),
        );
    }
  }

  void _setupJSHandlers(InAppWebViewController controller) {
    controller.addJavaScriptHandler(handlerName: 'onVideoPlay', callback: (args) {
      if (_isSyncing) _watchService.sendCommand(WatchEventType.play, Duration(seconds: args[0].toInt()));
    });
    controller.addJavaScriptHandler(handlerName: 'onVideoPause', callback: (args) {
      if (_isSyncing) _watchService.sendCommand(WatchEventType.pause, Duration(seconds: args[0].toInt()));
    });
    controller.addJavaScriptHandler(handlerName: 'onVideoSeek', callback: (args) {
      if (_isSyncing) _watchService.sendCommand(WatchEventType.seek, Duration(seconds: args[0].toInt()));
    });
    controller.addJavaScriptHandler(handlerName: 'onVideoBuffer', callback: (args) {
      if (_isSyncing) _watchService.sendCommand(WatchEventType.buffer, Duration(seconds: args[0].toInt()));
    });
    controller.addJavaScriptHandler(handlerName: 'onUrlChange', callback: (args) {
      if (_isSyncing) _watchService.sendCommand(WatchEventType.changeVideo, Duration.zero, videoUrl: args[0].toString());
      setState(() { _urlController.text = args[0].toString(); });
    });
  }

  Widget _buildBrowserToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SyncColors.surface,
        border: Border(bottom: BorderSide(color: SyncColors.glassBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            onPressed: () async {
              if (_showLaunchpad) {
                Navigator.pop(context);
              } else {
                bool canGoBack = await _webViewController?.canGoBack() ?? false;
                if (canGoBack) {
                  _webViewController?.goBack();
                } else {
                  setState(() => _showLaunchpad = true);
                }
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: SyncColors.coral.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 1)
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
              ),
              child: TextField(
                controller: _urlController,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Arama yap veya URL gir...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _loadUrl(val),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildSyncFloatingButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _isSyncing = !_isSyncing);
        SyncNotification.show(
          context,
          message: _isSyncing ? 'Cinema Sync Active' : 'Sync Paused',
          icon: _isSyncing ? Icons.sync_rounded : Icons.sync_disabled_rounded,
          type: _isSyncing ? NotificationType.success : NotificationType.urgent,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _isSyncing ? SyncColors.coral : SyncColors.glassSurface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_isSyncing ? Icons.favorite : Icons.sync_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(_isSyncing ? 'WATCHING WITH PARTNER' : 'START SYNC', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ).animate(target: _isSyncing ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
    );
  }
}
