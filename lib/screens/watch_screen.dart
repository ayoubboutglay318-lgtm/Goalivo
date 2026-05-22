import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _Channel {
  const _Channel({required this.name, required this.color, this.logoUrl});
  final String name;
  final Color color;
  final String? logoUrl;
}

class _LeagueChannels {
  const _LeagueChannels({
    required this.league,
    required this.leagueLogo,
    required this.channels,
    required this.color,
  });
  final String league;
  final String leagueLogo;
  final List<_Channel> channels;
  final Color color;
}

// ── Static channel guide data ─────────────────────────────────────────────────

const _guide = [
  _LeagueChannels(
    league: 'Premier League',
    leagueLogo: 'https://media.api-sports.io/football/leagues/39.png',
    color: Color(0xFF3D195B),
    channels: [
      _Channel(name: 'Sky Sports', color: Color(0xFF0099E8), logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9b/Sky_Sports_logo_2020.svg/120px-Sky_Sports_logo_2020.svg.png'),
      _Channel(name: 'TNT Sports', color: Color(0xFFFF5F00), logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/55/TNT_Sports_logo_2023.svg/120px-TNT_Sports_logo_2023.svg.png'),
      _Channel(name: 'DAZN', color: Color(0xFF000000), logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/DAZN_Brand_Mark.svg/120px-DAZN_Brand_Mark.svg.png'),
      _Channel(name: 'beIN Sports', color: Color(0xFFD50000)),
    ],
  ),
  _LeagueChannels(
    league: 'La Liga',
    leagueLogo: 'https://media.api-sports.io/football/leagues/140.png',
    color: Color(0xFFEE8207),
    channels: [
      _Channel(name: 'DAZN', color: Color(0xFF000000)),
      _Channel(name: 'ESPN', color: Color(0xFFC41230), logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/ESPN_wordmark.svg/120px-ESPN_wordmark.svg.png'),
      _Channel(name: 'beIN Sports', color: Color(0xFFD50000)),
      _Channel(name: 'Premier Sports', color: Color(0xFF1B4B7A)),
    ],
  ),
  _LeagueChannels(
    league: 'Serie A',
    leagueLogo: 'https://media.api-sports.io/football/leagues/135.png',
    color: Color(0xFF024494),
    channels: [
      _Channel(name: 'DAZN', color: Color(0xFF000000)),
      _Channel(name: 'Sky Sport', color: Color(0xFF0099E8)),
      _Channel(name: 'Mediaset', color: Color(0xFF003580)),
      _Channel(name: 'beIN Sports', color: Color(0xFFD50000)),
    ],
  ),
  _LeagueChannels(
    league: 'Bundesliga',
    leagueLogo: 'https://media.api-sports.io/football/leagues/78.png',
    color: Color(0xFFD20515),
    channels: [
      _Channel(name: 'Sky Sports', color: Color(0xFF0099E8)),
      _Channel(name: 'TNT Sports', color: Color(0xFFFF5F00)),
      _Channel(name: 'DAZN', color: Color(0xFF000000)),
      _Channel(name: 'Sport1', color: Color(0xFFE30613)),
    ],
  ),
  _LeagueChannels(
    league: 'Ligue 1',
    leagueLogo: 'https://media.api-sports.io/football/leagues/61.png',
    color: Color(0xFF091C3E),
    channels: [
      _Channel(name: 'Canal+', color: Color(0xFF000000)),
      _Channel(name: 'beIN Sports', color: Color(0xFFD50000)),
      _Channel(name: 'DAZN', color: Color(0xFF000000)),
      _Channel(name: 'Free Ligue 1', color: Color(0xFF1A1A1A)),
    ],
  ),
  _LeagueChannels(
    league: 'Champions League',
    leagueLogo: 'https://media.api-sports.io/football/leagues/2.png',
    color: Color(0xFF001489),
    channels: [
      _Channel(name: 'TNT Sports', color: Color(0xFFFF5F00)),
      _Channel(name: 'CBS Sports', color: Color(0xFF0058A5)),
      _Channel(name: 'beIN Sports', color: Color(0xFFD50000)),
      _Channel(name: 'DAZN', color: Color(0xFF000000)),
    ],
  ),
  _LeagueChannels(
    league: 'Europa League',
    leagueLogo: 'https://media.api-sports.io/football/leagues/3.png',
    color: Color(0xFFFF6900),
    channels: [
      _Channel(name: 'TNT Sports', color: Color(0xFFFF5F00)),
      _Channel(name: 'CBS Sports', color: Color(0xFF0058A5)),
      _Channel(name: 'beIN Sports', color: Color(0xFFD50000)),
      _Channel(name: 'DAZN', color: Color(0xFF000000)),
    ],
  ),
  _LeagueChannels(
    league: 'Arab Nations',
    leagueLogo: 'https://media.api-sports.io/football/leagues/29.png',
    color: Color(0xFF006600),
    channels: [
      _Channel(name: 'beIN Sports', color: Color(0xFFD50000)),
      _Channel(name: 'SSC Sport', color: Color(0xFF1A237E)),
      _Channel(name: 'Abu Dhabi TV', color: Color(0xFF00695C)),
      _Channel(name: 'Al Jazeera Sport', color: Color(0xFF1565C0)),
    ],
  ),
];

// ── Main widget ───────────────────────────────────────────────────────────────

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

class _WatchScreenState extends State<WatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _showWebView = false;
  String _webViewUrl = '';
  String _webViewTitle = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openYoutube() => _openSearch('live full match', 'YouTube');

  void _openChannel(String channelName) => _openSearch('$channelName live stream', channelName);

  void _openLeague(String leagueName) => _openSearch('$leagueName live stream', leagueName);

  void _openSearch(String suffix, String title) {
    HapticFeedback.lightImpact();
    final q = Uri.encodeComponent('${widget.homeName} vs ${widget.awayName} $suffix');
    setState(() {
      _webViewUrl = 'https://www.youtube.com/results?search_query=$q';
      _webViewTitle = title;
      _showWebView = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebView) {
      return _WebViewPage(
        url: _webViewUrl,
        title: _webViewTitle,
        onBack: () => setState(() => _showWebView = false),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _Header(
            homeName: widget.homeName,
            awayName: widget.awayName,
            onYoutube: _openYoutube,
          )),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabDelegate(
              TabBar(
                controller: _tabCtrl,
                tabs: const [Tab(text: 'TV Guide'), Tab(text: 'Leagues')],
                indicatorColor: const Color(0xFF00C853),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                dividerColor: Colors.white10,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _GuideView(guide: _guide, onWatch: _openChannel),
            _LeagueListView(guide: _guide, onLeague: _openLeague),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.homeName, required this.awayName, required this.onYoutube});
  final String homeName;
  final String awayName;
  final VoidCallback onYoutube;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0A0A), Color(0xFF111111)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FOOTBALL TV',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
              const Text('TV Live · Streaming',
                  style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w500)),
            ]),
          ),
          const Icon(Icons.live_tv, color: Color(0xFF00C853), size: 22),
        ]),
        const SizedBox(height: 20),
        // Match banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$homeName vs $awayName',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onYoutube,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('YouTube', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── TV Guide (channels per league) ────────────────────────────────────────────

class _GuideView extends StatelessWidget {
  const _GuideView({required this.guide, required this.onWatch});
  final List<_LeagueChannels> guide;
  final void Function(String channelName) onWatch;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: guide.length,
      itemBuilder: (context, i) {
        final item = guide[i];
        return _LeagueSection(item: item, onWatch: onWatch);
      },
    );
  }
}

class _LeagueSection extends StatelessWidget {
  const _LeagueSection({required this.item, required this.onWatch});
  final _LeagueChannels item;
  final void Function(String channelName) onWatch;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // League header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Image.network(item.leagueLogo, width: 24, height: 24,
              errorBuilder: (_, _, _) => const Icon(Icons.sports_soccer, size: 20, color: Colors.white38)),
          const SizedBox(width: 8),
          Text(item.league,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
        ]),
      ),
      // Channel cards horizontal scroll
      SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: item.channels.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _ChannelCard(
            channel: item.channels[i],
            leagueColor: item.color,
            onTap: () => onWatch(item.channels[i].name),
          ),
        ),
      ),
    ]);
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.channel, required this.leagueColor, required this.onTap});
  final _Channel channel;
  final Color leagueColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 100,
      decoration: BoxDecoration(
        color: channel.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: channel.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if ((channel.logoUrl ?? '').isNotEmpty)
          Image.network(
            channel.logoUrl!,
            width: 48, height: 48, fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _colorIcon(channel),
          )
        else
          _colorIcon(channel),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            channel.name,
            style: TextStyle(
              color: channel.color == Colors.black ? Colors.white70 : channel.color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    ),
    );
  }

  Widget _colorIcon(_Channel ch) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ch.color == Colors.black ? Colors.white10 : ch.color.withValues(alpha: 0.2),
      ),
      alignment: Alignment.center,
      child: Text(
        ch.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: ch.color == Colors.black ? Colors.white : ch.color,
        ),
      ),
    );
  }
}

// ── Leagues list view ─────────────────────────────────────────────────────────

class _LeagueListView extends StatelessWidget {
  const _LeagueListView({required this.guide, required this.onLeague});
  final List<_LeagueChannels> guide;
  final void Function(String leagueName) onLeague;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: guide.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = guide[i];
        return GestureDetector(
          onTap: () => onLeague(item.league),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(children: [
              Image.network(item.leagueLogo, width: 36, height: 36,
                  errorBuilder: (_, _, _) => Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: item.color.withValues(alpha: 0.2), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(item.league[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  )),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.league, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(item.channels.map((c) => c.name).join(' · '),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              const Icon(Icons.play_circle_outline, color: Colors.white24, size: 20),
            ]),
          ),
        );
      },
    );
  }
}

// ── WebView page ──────────────────────────────────────────────────────────────

class _WebViewPage extends StatefulWidget {
  const _WebViewPage({required this.url, required this.title, required this.onBack});
  final String url;
  final String title;
  final VoidCallback onBack;

  @override
  State<_WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<_WebViewPage> {
  late WebViewController _ctrl;
  bool _loading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onProgress: (p) => setState(() => _progress = p / 100),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Text(widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _ctrl.reload())],
        bottom: _loading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: Colors.white12,
                  color: const Color(0xFF00C853),
                  minHeight: 2,
                ))
            : null,
      ),
      body: WebViewWidget(controller: _ctrl),
    );
  }
}

// ── Sliver tab bar delegate ───────────────────────────────────────────────────

class _TabDelegate extends SliverPersistentHeaderDelegate {
  const _TabDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabDelegate oldDelegate) => false;
}
