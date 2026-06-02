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
      home: const DoctorHomeScreen(),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

enum PatientAge { adult, child, senior, infant }
enum PatientGender { male, female }

class RoomInfo {
  final String name;
  final int totalBeds;
  final int occupied;
  final Color color;

  const RoomInfo({
    required this.name,
    required this.totalBeds,
    required this.occupied,
    required this.color,
  });

  int get free => totalBeds - occupied;
  double get occupancy => occupied / totalBeds;
  int get occupancyPct => (occupancy * 100).round();
}

class Patient {
  final String id;
  final PatientAge age;
  final PatientGender gender;
  final String timeAgo;

  const Patient({
    required this.id,
    required this.age,
    required this.gender,
    required this.timeAgo,
  });
}

// ── Main screen ───────────────────────────────────────────────────────────────

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  static const routeName = '/doctor-home';

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg = Color(0xFF0D0F0E);
  static const Color _card = Color(0xFF161A19);
  static const Color _border = Color(0xFF2A3230);
  static const Color _green = Color(0xFF8CBF3F);
  static const Color _red = Color(0xFFD94040);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);

  // Active room — Red Room shown per screenshot
  final RoomInfo _activeRoom = const RoomInfo(
    name: 'RED ROOM',
    totalBeds: 10,
    occupied: 8,
    color: Color(0xFFD94040),
  );

  final List<Patient> _patients = const [
    Patient(id: '#048', age: PatientAge.adult, gender: PatientGender.male, timeAgo: 'Just now'),
    Patient(id: '#034', age: PatientAge.child, gender: PatientGender.male, timeAgo: '7 min ago'),
    Patient(id: '#030', age: PatientAge.senior, gender: PatientGender.female, timeAgo: '10 min ago'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _ageLabel(PatientAge a) {
    switch (a) {
      case PatientAge.adult: return 'ADULT';
      case PatientAge.child: return 'CHILD';
      case PatientAge.senior: return 'SENIOR';
      case PatientAge.infant: return 'INFANT';
    }
  }

  IconData _genderIcon(PatientGender g) =>
      g == PatientGender.male ? Icons.male : Icons.female;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRoomCard(),
                        const SizedBox(height: 28),
                        _buildSectionLabel('PATIENT'),
                        const SizedBox(height: 12),
                        ..._patients.map(_buildPatientCard),
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

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _border, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 36,
            child: CustomPaint(painter: _HexLogoPainter()),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOCTOR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                'Operator: Doctor V.',
                style: TextStyle(
                  color: _textDim,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Red Room badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _red.withOpacity(0.15),
              border: Border.all(color: _red, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Red Room',
              style: TextStyle(
                color: _red,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Room card ─────────────────────────────────────────────────────────────

  Widget _buildRoomCard() {
    final room = _activeRoom;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Red left accent
              Container(
                width: 4,
                height: 20,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: room.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                room.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                '${room.occupied}/${room.totalBeds} BEDS',
                style: TextStyle(
                  color: room.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: room.occupancy,
              minHeight: 6,
              backgroundColor: _border,
              valueColor: AlwaysStoppedAnimation<Color>(room.color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${room.occupancyPct}% OCCUPIED',
                style: TextStyle(
                  color: _textDim,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${room.free} FREE',
                style: TextStyle(
                  color: room.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: _textMid,
        fontSize: 10,
        letterSpacing: 2.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Patient card ──────────────────────────────────────────────────────────

  Widget _buildPatientCard(Patient p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          // Red left accent bar
          Container(
            width: 4,
            height: 62,
            decoration: BoxDecoration(
              color: _red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _red.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _red.withOpacity(0.3), width: 1),
            ),
            child: Icon(Icons.person_outline, color: _textMid, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      p.id,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(_genderIcon(p.gender), color: _textMid, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _ageLabel(p.age),
                      style: TextStyle(
                        color: _textMid,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  p.timeAgo,
                  style: TextStyle(color: _textDim, fontSize: 11),
                ),
              ],
            ),
          ),
          // Chevron
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(Icons.chevron_right, color: _textDim, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, Icons.home),
      (Icons.assignment_outlined, Icons.assignment),
      (Icons.settings_outlined, Icons.settings),
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
            onTap: () => setState(() => _navIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Icon(
                active ? items[i].$2 : items[i].$1,
                color: active ? _green : _textDim,
                size: 24,
              ),
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

    canvas.drawPath(
      hexPath,
      Paint()
        ..color = const Color(0xFF8CBF3F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    final arm = size.width * 0.22;
    final crossPaint = Paint()
      ..color = const Color(0xFF8CBF3F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), crossPaint);

    final dotColors = [
      const Color(0xFFE05050),
      const Color(0xFFF5C842),
      const Color(0xFF50E070),
    ];
    for (int i = 0; i < 3; i++) {
      final angle = (i * 60 + 90) * (3.14159265 / 180);
      canvas.drawCircle(
        Offset(cx + (r + 4) * _cos(angle), cy + (r + 4) * _sin(angle)),
        3,
        Paint()..color = dotColors[i],
      );
    }
  }

  double _cos(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    double result = 1, term = 1;
    for (int n = 1; n <= 8; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  double _sin(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    double result = x, term = x;
    for (int n = 1; n <= 8; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}