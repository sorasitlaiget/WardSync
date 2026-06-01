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
      home: const AllPatientsScreen(),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

enum TriageColor { red, yellow, green, black }
enum PatientAge { adult, child, senior, infant }
enum PatientGender { male, female }
enum PatientStatus { inTreatment, waiting, discharged }

class Patient {
  final String id;
  final TriageColor triage;
  final PatientAge age;
  final PatientGender gender;
  final String room;
  final PatientStatus status;

  const Patient({
    required this.id,
    required this.triage,
    required this.age,
    required this.gender,
    required this.room,
    required this.status,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AllPatientsScreen extends StatefulWidget {
  const AllPatientsScreen({super.key});

  static const routeName = '/admin-patients';

  @override
  State<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 1;
  TriageColor? _filterColor; // null = ALL
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const Color _bg      = Color(0xFF0D0F0E);
  static const Color _card    = Color(0xFF161A19);
  static const Color _border  = Color(0xFF2A3230);
  static const Color _green   = Color(0xFF8CBF3F);
  static const Color _red     = Color(0xFFD94040);
  static const Color _yellow  = Color(0xFFE8B840);
  static const Color _grn     = Color(0xFF4CAF50);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);
  static const Color _fieldBg = Color(0xFF1C2120);

  final List<Patient> _allPatients = const [
    Patient(id: '#048', triage: TriageColor.red,    age: PatientAge.adult,  gender: PatientGender.male,   room: 'RED ROOM',    status: PatientStatus.inTreatment),
    Patient(id: '#047', triage: TriageColor.yellow, age: PatientAge.child,  gender: PatientGender.male,   room: 'YELLOW ROOM', status: PatientStatus.waiting),
    Patient(id: '#046', triage: TriageColor.green,  age: PatientAge.senior, gender: PatientGender.female, room: 'GREEN',       status: PatientStatus.discharged),
    Patient(id: '#045', triage: TriageColor.red,    age: PatientAge.child,  gender: PatientGender.male,   room: 'RED ROOM',    status: PatientStatus.inTreatment),
    Patient(id: '#044', triage: TriageColor.yellow, age: PatientAge.child,  gender: PatientGender.male,   room: 'YELLOW ROOM', status: PatientStatus.inTreatment),
    Patient(id: '#043', triage: TriageColor.green,  age: PatientAge.adult,  gender: PatientGender.female, room: 'GREEN',       status: PatientStatus.discharged),
    Patient(id: '#042', triage: TriageColor.red,    age: PatientAge.adult,  gender: PatientGender.male,   room: 'RED ROOM',    status: PatientStatus.waiting),
    Patient(id: '#041', triage: TriageColor.green,  age: PatientAge.child,  gender: PatientGender.female, room: 'GREEN',       status: PatientStatus.inTreatment),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> get _filtered {
    return _allPatients.where((p) {
      final matchColor = _filterColor == null || p.triage == _filterColor;
      final matchSearch = _searchQuery.isEmpty ||
          p.id.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchColor && matchSearch;
    }).toList();
  }

  int _countByColor(TriageColor c) => _allPatients.where((p) => p.triage == c).length;

  Color _triageColor(TriageColor c) {
    switch (c) {
      case TriageColor.red:    return _red;
      case TriageColor.yellow: return _yellow;
      case TriageColor.green:  return _grn;
      case TriageColor.black:  return const Color(0xFF6B7280);
    }
  }

  String _ageLabel(PatientAge a) {
    switch (a) {
      case PatientAge.adult:  return 'ADULT';
      case PatientAge.child:  return 'CHILD';
      case PatientAge.senior: return 'SENIOR';
      case PatientAge.infant: return 'INFANT';
    }
  }

  String _statusLabel(PatientStatus s) {
    switch (s) {
      case PatientStatus.inTreatment: return 'In treatment';
      case PatientStatus.waiting:     return 'Waiting';
      case PatientStatus.discharged:  return 'Discharged';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              _buildTopBar(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _buildPatientCard(_filtered[i]),
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
      child: Text('ALL PATIENT',
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
          Text('PATIENT',
              style: const TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800, letterSpacing: 2.0)),
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

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search by wristband #...',
        hintStyle: TextStyle(color: _textDim, fontSize: 12),
        prefixIcon: Icon(Icons.search, color: _textDim, size: 18),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _border, width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _border, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _green.withOpacity(0.5), width: 1.5)),
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(null, 'ALL • ${_allPatients.length}', _textMid),
          const SizedBox(width: 8),
          _filterChip(TriageColor.red,    '• ${_countByColor(TriageColor.red)} RED',       _red),
          const SizedBox(width: 8),
          _filterChip(TriageColor.yellow, '• ${_countByColor(TriageColor.yellow)} YELLOW',  _yellow),
          const SizedBox(width: 8),
          _filterChip(TriageColor.green,  '• ${_countByColor(TriageColor.green)} GREEN',    _grn),
        ],
      ),
    );
  }

  Widget _filterChip(TriageColor? color, String label, Color chipColor) {
    final active = _filterColor == color;
    return GestureDetector(
      onTap: () => setState(() => _filterColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? chipColor.withOpacity(0.18) : _fieldBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? chipColor : _border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? chipColor : _textDim,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
      ),
    );
  }

  // ── Patient card ──────────────────────────────────────────────────────────

  Widget _buildPatientCard(Patient p) {
    final color = _triageColor(p.triage);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          // Left triage accent bar
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: color,
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
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1),
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
                    Text(p.id,
                        style: const TextStyle(color: Colors.white, fontSize: 14,
                            fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    const SizedBox(width: 6),
                    Icon(_genderIcon(p.gender), color: _textMid, size: 14),
                    const SizedBox(width: 4),
                    Text(_ageLabel(p.age),
                        style: TextStyle(color: _textMid, fontSize: 12,
                            fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${p.room} : ${_statusLabel(p.status)}',
                    style: TextStyle(color: _textDim, fontSize: 11)),
              ],
            ),
          ),
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
                case 1: break; // Already here
                case 2: Navigator.pushReplacementNamed(context, '/admin-inventory'); break;
                case 3: Navigator.pushReplacementNamed(context, '/admin-roomconfig'); break;
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