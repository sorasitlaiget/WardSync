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
      home: const RoomConfigScreen(),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class RoomConfig {
  final String name;
  final Color color;
  int capacity;
  final int occupied;

  RoomConfig({
    required this.name,
    required this.color,
    required this.capacity,
    required this.occupied,
  });

  double get occupancyRatio => capacity > 0 ? (occupied / capacity).clamp(0.0, 1.0) : 0;
  int get occupancyPct => (occupancyRatio * 100).round();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class RoomConfigScreen extends StatefulWidget {
  const RoomConfigScreen({super.key});

  static const routeName = '/admin-roomconfig';

  @override
  State<RoomConfigScreen> createState() => _RoomConfigScreenState();
}

class _RoomConfigScreenState extends State<RoomConfigScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 3;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg      = Color(0xFF0D0F0E);
  static const Color _card    = Color(0xFF161A19);
  static const Color _border  = Color(0xFF2A3230);
  static const Color _green   = Color(0xFF8CBF3F);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);
  static const Color _fieldBg = Color(0xFF1C2120);

  final List<RoomConfig> _rooms = [];

  // Controllers per room
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _rooms.map((r) => TextEditingController(text: '${r.capacity}')).toList();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _onCapacityChanged(int index, String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      setState(() => _rooms[index].capacity = parsed);
    }
  }

  void _showAddRoomDialog() {
    final nameCtrl = TextEditingController();
    final capCtrl  = TextEditingController();
    Color selectedColor = const Color(0xFF8CBF3F);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: _border)),
          title: Text('ADD ROOM',
              style: TextStyle(color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Room name (e.g. BLUE ROOM)'),
              const SizedBox(height: 12),
              _dialogField(capCtrl, 'Capacity (beds)', isNumber: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Color:', style: TextStyle(color: _textDim, fontSize: 11)),
                  const SizedBox(width: 12),
                  ...[
                    const Color(0xFF4CAF50),
                    const Color(0xFF2196F3),
                    const Color(0xFF9C27B0),
                    const Color(0xFFFF9800),
                  ].map((c) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      width: 24, height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == c ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: TextStyle(color: _textDim, fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.black),
              onPressed: () {
                final name = nameCtrl.text.trim().toUpperCase();
                final cap  = int.tryParse(capCtrl.text) ?? 0;
                if (name.isNotEmpty && cap > 0) {
                  setState(() {
                    _rooms.add(RoomConfig(
                        name: name, color: selectedColor,
                        capacity: cap, occupied: 0));
                    _controllers.add(TextEditingController(text: '$cap'));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textDim, fontSize: 12),
        filled: true, fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _green.withOpacity(0.6), width: 1.5)),
      ),
    );
  }

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
              _buildTopBar(),
              const SizedBox(height: 4),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      children: [
                        if (_rooms.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No rooms yet. Tap ADD ROOM to add one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _textDim, fontSize: 13),
                              ),
                            ),
                          ),
                        ..._rooms.asMap().entries.map((e) => _buildRoomCard(e.key, e.value)),
                        const SizedBox(height: 8),
                        _buildAddButton(),
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

  // ── Page title ────────────────────────────────────────────────────────────

  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text('ROOM CONFIG',
          style: TextStyle(color: _textMid, fontSize: 13,
              fontWeight: FontWeight.w600, letterSpacing: 2.0)),
    );
  }

  // ── Header card ───────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Text('ROOM CONFIG',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, letterSpacing: 2.0)),
              Text('SET CAPACITY PER ROOM',
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

  // ── Room card ─────────────────────────────────────────────────────────────

  Widget _buildRoomCard(int index, RoomConfig room) {
    final color = room.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with left accent
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 14, 10),
            child: Row(
              children: [
                // Left color accent bar
                Container(
                  width: 4,
                  height: 22,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
                Text(room.name,
                    style: TextStyle(color: color, fontSize: 15,
                        fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const Spacer(),
                Text('${room.occupancyPct} % FULL',
                    style: TextStyle(color: color, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ],
            ),
          ),

          // Capacity input
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAPACITY (BEDS)',
                    style: TextStyle(color: _textDim, fontSize: 9,
                        letterSpacing: 1.8, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _controllers[index],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700),
                  onChanged: (v) => _onCapacityChanged(index, v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _fieldBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: color.withOpacity(0.6), width: 1.5)),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: room.occupancyRatio,
                minHeight: 6,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),

          // Occupied label
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Text('${room.occupied} OCCUPIED',
                style: TextStyle(color: _textDim, fontSize: 9,
                    letterSpacing: 1.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── Add room button ───────────────────────────────────────────────────────

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _showAddRoomDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('ADD ROOM',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2.2)),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final outlined = [Icons.home_outlined, Icons.person_outline, Icons.work_outline, Icons.settings_outlined];
    final filled   = [Icons.home,          Icons.person,         Icons.work,          Icons.settings];
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (i) {
          final active = _navIndex == i;
          return GestureDetector(
            onTap: () {
              switch (i) {
                case 0: Navigator.pushReplacementNamed(context, '/admin-home'); break;
                case 1: Navigator.pushReplacementNamed(context, '/admin-patients'); break;
                case 2: Navigator.pushReplacementNamed(context, '/admin-inventory'); break;
                case 3: break; // Already here
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Icon(active ? filled[i] : outlined[i],
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
    final cx = size.width / 2, cy = size.height / 2, r = size.width * 0.48;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 30) * (3.14159265 / 180);
      final x = cx + r * _cos(a), y = cy + r * _sin(a);
      i == 0 ? hexPath.moveTo(x, y) : hexPath.lineTo(x, y);
    }
    hexPath.close();
    canvas.drawPath(hexPath, Paint()
      ..color = const Color(0xFF8CBF3F)..style = PaintingStyle.stroke
      ..strokeWidth = 2.5..strokeJoin = StrokeJoin.round);
    final arm = size.width * 0.22;
    final cp = Paint()..color = const Color(0xFF8CBF3F)..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), cp);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), cp);
    final dots = [const Color(0xFFE05050), const Color(0xFFF5C842), const Color(0xFF50E070)];
    for (int i = 0; i < 3; i++) {
      final a = (i * 60 + 90) * (3.14159265 / 180);
      canvas.drawCircle(Offset(cx + (r + 4) * _cos(a), cy + (r + 4) * _sin(a)), 3, Paint()..color = dots[i]);
    }
  }

  double _cos(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi; while (x < -pi) x += 2 * pi;
    double r = 1, t = 1;
    for (int n = 1; n <= 8; n++) { t *= -x * x / ((2*n-1)*(2*n)); r += t; }
    return r;
  }

  double _sin(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi; while (x < -pi) x += 2 * pi;
    double r = x, t = x;
    for (int n = 1; n <= 8; n++) { t *= -x * x / ((2*n)*(2*n+1)); r += t; }
    return r;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}