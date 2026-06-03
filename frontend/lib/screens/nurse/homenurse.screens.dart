import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/patients/repositories/patient_repository.dart';
import '../../../shared/models/patient.dart';
import 'new_patient_screen.dart';
import '../doctor/patient_detail_screen.dart';

// ── Main screen ───────────────────────────────────────────────────────────────

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  static const routeName = '/nurse-home';

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const Color _bg = Color(0xFF0D0F0E);
  static const Color _card = Color(0xFF161A19);
  static const Color _green = Color(0xFF8CBF3F);
  static const Color _border = Color(0xFF2A3230);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);

  static const Color _red = Color(0xFFD94040);
  static const Color _yellow = Color(0xFFE8B840);
  static const Color _grn = Color(0xFF4CAF50);
  static const Color _blk = Color(0xFF6B7280);

  List<Patient> _patients = [];
  bool _isLoading = true;
  final _repo = PatientRepository();

  // Filters
  TriageColor? _filterColor;
  String? _filterStatus;
  bool _filterToday = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _repo.getPatients(
        triageColor: _filterColor?.name,
        status: _filterStatus,
        wristband: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        today: _filterToday ? true : null,
      );
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _triageColor(TriageColor c) {
    switch (c) {
      case TriageColor.red:
        return _red;
      case TriageColor.yellow:
        return _yellow;
      case TriageColor.green:
        return _grn;
      case TriageColor.black:
        return _blk;
    }
  }

  String _triageLabel(TriageColor c) {
    switch (c) {
      case TriageColor.red:
        return 'RED';
      case TriageColor.yellow:
        return 'YEL';
      case TriageColor.green:
        return 'GRN';
      case TriageColor.black:
        return 'BLK';
    }
  }

  String _ageLabel(AgeRange a) {
    switch (a) {
      case AgeRange.adult:
        return 'ADULT';
      case AgeRange.child:
        return 'CHILD';
      case AgeRange.elder:
        return 'SENIOR';
      case AgeRange.infant:
        return 'INFANT';
    }
  }

  IconData _genderIcon(Sex g) =>
      g == Sex.male ? Icons.male : Icons.female;

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildCountCards(),
                      const SizedBox(height: 20),
                      _buildFilterBar(),
                      const SizedBox(height: 16),
                      _buildSectionLabel('RECENT TRIAGE'),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (_patients.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No patients yet',
                              style: TextStyle(color: _textDim, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ..._patients.map(_buildPatientCard),
                      const SizedBox(height: 20),
                      _buildNewPatientButton(),
                    ],
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

  // ── Filter bar ────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    final colors = [
      (TriageColor.red, _red, 'RED'),
      (TriageColor.yellow, _yellow, 'YEL'),
      (TriageColor.green, _grn, 'GRN'),
      (TriageColor.black, _blk, 'BLK'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        SizedBox(
          height: 40,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => _loadPatients(),
            style: TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search wristband...',
              hintStyle: TextStyle(color: _textDim, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: _textDim, size: 18),
              filled: true,
              fillColor: const Color(0xFF161A19),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _green),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Triage color chips + TODAY toggle
        Row(
          children: [
            ...colors.map((c) {
              final (color, hex, label) = c;
              final selected = _filterColor == color;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _filterColor = selected ? null : color);
                    _loadPatients();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected ? hex.withValues(alpha: 0.2) : const Color(0xFF161A19),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected ? hex : _border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(label,
                        style: TextStyle(
                          color: selected ? hex : _textDim,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        )),
                  ),
                ),
              );
            }),
            const Spacer(),
            // TODAY toggle
            GestureDetector(
              onTap: () {
                setState(() => _filterToday = !_filterToday);
                _loadPatients();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _filterToday ? _green.withValues(alpha: 0.15) : const Color(0xFF161A19),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _filterToday ? _green : _border,
                    width: _filterToday ? 1.5 : 1,
                  ),
                ),
                child: Text('TODAY',
                    style: TextStyle(
                      color: _filterToday ? _green : _textDim,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    )),
              ),
            ),
          ],
        ),
      ],
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
          // Hex logo mini
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
                'TRIAGE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                'Operator: Nurse K.',
                style: TextStyle(
                  color: _textDim,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // NURSE badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: _green, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'NURSE',
              style: TextStyle(
                color: _green,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Count cards ───────────────────────────────────────────────────────────

  Widget _buildCountCards() {
    final counts = [
      (_patients.where((p) => p.triageColor == TriageColor.red).length, 'Red', _red),
      (_patients.where((p) => p.triageColor == TriageColor.yellow).length, 'YEL', _yellow),
      (_patients.where((p) => p.triageColor == TriageColor.green).length, 'GRN', _grn),
      (_patients.where((p) => p.triageColor == TriageColor.black).length, 'BLK', _blk),
    ];
    return Row(
      children: counts
          .map((c) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: c.$2 == 'BLK' ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${c.$1}',
                        style: TextStyle(
                          color: c.$3,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.$2,
                        style: TextStyle(
                          color: _textDim,
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
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
    final color = _triageColor(p.triageColor);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patient: p, isDoctor: false),
        ),
      ).then((_) => _loadPatients()),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          // Colored left accent bar
          Container(
            width: 4,
            height: 62,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar circle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4), width: 1),
            ),
            child: Icon(Icons.person_outline, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${p.wristbandNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(_genderIcon(p.sex),
                        color: _textMid, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _ageLabel(p.ageRange),
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
                  _timeAgo(p.arrivedAt),
                  style: TextStyle(
                    color: _textDim,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Triage color badge
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
            ),
            child: Text(
              _triageLabel(p.triageColor),
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ── New patient button ────────────────────────────────────────────────────

  Widget _buildNewPatientButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewPatientScreen()),
        ).then((_) => _loadPatients()),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'NEW PATIENT',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.assignment_outlined, Icons.assignment, 'Patients'),
      (Icons.settings_outlined, Icons.settings, 'Settings'),
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
            onTap: () async {
              if (i == 2) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: _card,
                    title: const Text('Logout', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure?', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                }
                return;
              }
              setState(() => _navIndex = i);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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

// ── Hex logo painter (shared across screens) ──────────────────────────────────

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
    canvas.drawLine(
      Offset(cx - arm, cy),
      Offset(cx + arm, cy),
      Paint()
        ..color = const Color(0xFF8CBF3F)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx, cy - arm),
      Offset(cx, cy + arm),
      Paint()
        ..color = const Color(0xFF8CBF3F)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

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