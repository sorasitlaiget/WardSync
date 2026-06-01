import 'package:flutter/material.dart';

void main() {
  runApp(const WardSyncApp());
}

class WardSyncApp extends StatelessWidget {
  const WardSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WardSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AdminOverviewScreen(),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class RoomCapacity {
  final String label;
  final Color color;
  final int current;
  final int? total; // null = unknown (?)
  RoomCapacity({required this.label, required this.color, required this.current, this.total});
  double get ratio => total != null ? (current / total!).clamp(0.0, 1.0) : 0.1;
  String get capacityText => total != null ? '$current/$total' : '$current/?';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  static const routeName = '/admin-home';

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg       = Color(0xFF0D0F0E);
  static const Color _card     = Color(0xFF161A19);
  static const Color _border   = Color(0xFF2A3230);
  static const Color _green    = Color(0xFF8CBF3F);
  static const Color _red      = Color(0xFFD94040);
  static const Color _yellow   = Color(0xFFE8B840);
  static const Color _grn      = Color(0xFF4CAF50);
  static const Color _blk      = Color(0xFF6B7280);
  static const Color _textDim  = Color(0xFF5A6B65);
  static const Color _textMid  = Color(0xFF8A9B93);

  final List<RoomCapacity> _rooms = [
    RoomCapacity(label: 'RED',    color: Color(0xFFD94040), current: 3,  total: 10),
    RoomCapacity(label: 'YELLOW', color: Color(0xFFE8B840), current: 12, total: 20),
    RoomCapacity(label: 'GREEN',  color: Color(0xFF4CAF50), current: 23, total: 50),
    RoomCapacity(label: 'BLACK',  color: Color(0xFF6B7280), current: 2,  total: null),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 20),
                        _buildStatCards(),
                        const SizedBox(height: 24),
                        _buildSectionLabel('BY TRIAGE COLOR'),
                        const SizedBox(height: 12),
                        _buildTriageColorCards(),
                        const SizedBox(height: 24),
                        _buildSectionLabel('ROOM CAPACITY'),
                        const SizedBox(height: 14),
                        _buildRoomCapacity(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page title (outside card) ─────────────────────────────────────────────

  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(
        'ADMIN OVER VIEW',
        style: TextStyle(
          color: _textMid,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  // ── Header card (logo + OPERATION + ADMIN badge) ──────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 32, height: 36, child: CustomPaint(painter: _HexLogoPainter())),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OPERATION',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, letterSpacing: 2.0)),
              Text('FIELD HOSPITAL : LIVE',
                  style: TextStyle(color: _textDim, fontSize: 10, letterSpacing: 0.5)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.15),
              border: Border.all(color: _green, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('ADMIN',
                style: TextStyle(color: _green, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  // ── Stat cards (45 total / 12 active) ────────────────────────────────────

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(child: _statCard('45', 'TOTAL  TODAY')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('12', 'ACTIVE  NOW')),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(color: _textMid, fontSize: 32,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(color: _textDim, fontSize: 9,
                  letterSpacing: 1.8, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: TextStyle(color: _textMid, fontSize: 10,
            letterSpacing: 2.2, fontWeight: FontWeight.w600));
  }

  // ── Triage color count cards ──────────────────────────────────────────────

  Widget _buildTriageColorCards() {
    final data = [
      (3, 'Red', _red),
      (12, 'YEL', _yellow),
      (23, 'GRN', _grn),
      (2, 'BLK', _blk),
    ];
    return Row(
      children: data.asMap().entries.map((e) {
        final i = e.key;
        final d = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border, width: 1),
            ),
            child: Column(
              children: [
                Text('${d.$1}',
                    style: TextStyle(color: d.$3, fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(d.$2,
                    style: TextStyle(color: _textDim, fontSize: 9,
                        letterSpacing: 1.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Room capacity bars ────────────────────────────────────────────────────

  Widget _buildRoomCapacity() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: _rooms.map((r) => _roomRow(r)).toList(),
      ),
    );
  }

  Widget _roomRow(RoomCapacity r) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 52,
            child: Text(r.label,
                style: TextStyle(color: _textDim, fontSize: 10,
                    letterSpacing: 1.2, fontWeight: FontWeight.w600)),
          ),
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: r.ratio,
                minHeight: 7,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation<Color>(r.color),
              ),
            ),
          ),
          // Capacity text
          SizedBox(
            width: 44,
            child: Text(
              r.capacityText,
              textAlign: TextAlign.right,
              style: TextStyle(color: _textMid, fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      Icons.home_outlined,
      Icons.person_outline,
      Icons.work_outline,
      Icons.settings_outlined,
    ];
    final activeItems = [
      Icons.home,
      Icons.person,
      Icons.work,
      Icons.settings,
    ];
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = _navIndex == i;
          return GestureDetector(
      onTap: () {
            switch (i) {
              case 0: break; // Home stays here
              case 1: Navigator.pushReplacementNamed(context, '/admin-patients'); break;
              case 2: Navigator.pushReplacementNamed(context, '/admin-inventory'); break;
              case 3: Navigator.pushReplacementNamed(context, '/admin-roomconfig'); break;
            }
          },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Icon(active ? activeItems[i] : items[i],
                  color: active ? _green : _textDim, size: 24),
            ),
          );
        }),
      ),
    );
  }
}

// ── Shared hex logo painter ───────────────────────────────────────────────────

class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.48;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * (3.14159265 / 180);
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      i == 0 ? hexPath.moveTo(x, y) : hexPath.lineTo(x, y);
    }
    hexPath.close();

    canvas.drawPath(hexPath, Paint()
      ..color = const Color(0xFF8CBF3F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round);

    final arm = size.width * 0.22;
    final cp = Paint()..color = const Color(0xFF8CBF3F)..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), cp);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), cp);

    final dotColors = [const Color(0xFFE05050), const Color(0xFFF5C842), const Color(0xFF50E070)];
    for (int i = 0; i < 3; i++) {
      final angle = (i * 60 + 90) * (3.14159265 / 180);
      canvas.drawCircle(Offset(cx + (r + 4) * _cos(angle), cy + (r + 4) * _sin(angle)),
          3, Paint()..color = dotColors[i]);
    }
  }

  double _cos(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    double result = 1, term = 1;
    for (int n = 1; n <= 8; n++) { term *= -x * x / ((2 * n - 1) * (2 * n)); result += term; }
    return result;
  }

  double _sin(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    double result = x, term = x;
    for (int n = 1; n <= 8; n++) { term *= -x * x / ((2 * n) * (2 * n + 1)); result += term; }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}