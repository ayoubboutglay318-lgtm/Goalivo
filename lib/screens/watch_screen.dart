import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({
    super.key,
    required this.homeName,
    required this.awayName,
  });

  final String homeName;
  final String awayName;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  int _selectedServer = 0;
  double _progress = 0;

  late final List<_StreamServer> _servers;

  @override
  void initState() {
    super.initState();
    final q = Uri.encodeComponent('${widget.homeName} vs ${widget.awayName}');
    _servers = [
      _StreamServer(
        name: 'StreamEast',
        icon: Icons.sports_soccer,
        color: Colors.green,
        url: 'https://www.streameast.app/search?q=$q',
      ),
      _StreamServer(
        name: 'YouTube',
        icon: Icons.play_circle_fill,
        color: Colors.red,
        url: 'https://www.youtube.com/results?search_query=${Uri.encodeComponent("${widget.homeName} vs ${widget.awayName} live")}',
      ),
      _StreamServer(
        name: 'CrackStreams',
        icon: Icons.live_tv,
        color: Colors.blue,
        url: 'https://crackstreams.app/search?q=$q',
      ),
      _StreamServer(
        name: 'Hesgoal',
        icon: Icons.sports,
        color: Colors.orange,
        url: 'https://www.hesgoal.tv/search/${Uri.encodeComponent("${widget.homeName} ${widget.awayName}")}',
      ),
      _StreamServer(
        name: 'LiveTV',
        icon: Icons.tv,
        color: Colors.purple,
        url: 'https://livetv.sx/en/search/?query=$q',
      ),
    ];

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onProgress: (p) => setState(() => _progress = p / 100),
        ),
      )
      ..loadRequest(Uri.parse(_servers[0].url));
  }

  void _loadServer(int index) {
    setState(() {
      _selectedServer = index;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(_servers[index].url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.homeName} vs ${widget.awayName}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _servers[_selectedServer].name,
              style: TextStyle(
                fontSize: 11,
                color: _servers[_selectedServer].color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _isLoading
              ? LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: Colors.white12,
                  color: theme.colorScheme.primary,
                  minHeight: 2,
                )
              : const SizedBox(height: 2),
        ),
      ),
      body: Column(
        children: [
          // Server selector
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                const Text(
                  'Servers:',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_servers.length, (i) {
                        final s = _servers[i];
                        final selected = i == _selectedServer;
                        return GestureDetector(
                          onTap: () => _loadServer(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? s.color.withValues(alpha: 0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selected ? s.color : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(s.icon,
                                    size: 14,
                                    color: selected
                                        ? s.color
                                        : Colors.white54),
                                const SizedBox(width: 5),
                                Text(
                                  s.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: selected
                                        ? s.color
                                        : Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // WebView
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class _StreamServer {
  const _StreamServer({
    required this.name,
    required this.icon,
    required this.color,
    required this.url,
  });
  final String name;
  final IconData icon;
  final Color color;
  final String url;
}
