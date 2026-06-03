import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/patients/repositories/patient_repository.dart';
import '../../../features/rooms/repositories/room_repository.dart';
import '../../../shared/models/patient.dart';
import '../../../shared/models/user_profile.dart';
import 'patient_detail_screen.dart';

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

  static const Color _bg    = Color(0xFF0D0F0E);
  static const Color _card  = Color(0xFF161A19);
  static const Color _border = Color(0xFF2A3230);
  static const Color _green = Color(0xFF8CBF3F);
  static const Color _red   = Color(0xFFD94040);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);

  final _authRepo   = AuthRepository();
  final _patientRepo = PatientRepository();
  final _roomRepo   = RoomRepository();

  UserProfile? _profile;
  List<Patient> _patients = [];
  RoomCapacity? _roomCapacity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _authRepo.getProfile();
      final room = profile.assignedRoom?.name ?? 'red';
      final results = await Future.wait([
        _patientRepo.getPatients(room: room),
        _roomRepo.getRoomCapacity(room),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _patients = results[0] as List<Patient>;
        _roomCapacity = results[1] as RoomCapacity;
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

  String _ageLabel(AgeRange a) {
    switch (a) {
      case AgeRange.adult:  return 'ADULT';
      case AgeRange.child:  return 'CHILD';
      case AgeRange.elder:  return 'SENIOR';
      case AgeRange.infant: return 'INFANT';
    }
  }

  IconData _genderIcon(Sex g) => g == Sex.male ? Icons.male : Icons.female;

  String get _roomLabel => '${(_profile?.assignedRoom?.name ?? 'red').toUpperCase()} ROOM';

  Color _triageColor(TriageColor c) {
    switch (c) {
      case TriageColor.red:    return const Color(0xFFD94040);
      case TriageColor.yellow: return const Color(0xFFE8B840);
      case TriageColor.green:  return const Color(0xFF4CAF50);
      case TriageColor.black:  return const Color(0xFF6B7280);
    }
  }

  Color get _roomColor {
    switch (_profile?.assignedRoom) {
      case TriageRoom.yellow: return const Color(0xFFE8B840);
      case TriageRoom.green:  return const Color(0xFF4CAF50);
      case TriageRoom.black:  return const Color(0xFF6B7280);
      default:                return _red;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : SlideTransition(
                        position: _slideAnim,
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_roomCapacity != null) _buildRoomCard(),
                                const SizedBox(height: 28),
                                _buildSectionLabel('PATIENT'),
                                const SizedBox(height: 12),
                                if (_patients.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text('No patients in this room',
                                          style: TextStyle(color: _textDim, fontSize: 13)),
                                    ),
                                  )
                                else
                                  ..._patients.map(_buildPatientCard),
                              ],
                            ),
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _border, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(width: 32, height: 36, child: CustomPaint(painter: _HexLogoPainter())),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DOCTOR',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w800, letterSpacing: 2.5)),
              Text('Dr. ${_profile?.name ?? '...'}',
                  style: TextStyle(color: _textDim, fontSize: 10, letterSpacing: 0.3)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _roomColor.withAlpha(38),
              border: Border.all(color: _roomColor, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(_roomLabel,
                style: TextStyle(color: _roomColor, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard() {
    final rc = _roomCapacity!;
    final occupancy = rc.occupancyRatio;
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
              Container(width: 4, height: 20, margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(color: _roomColor, borderRadius: BorderRadius.circular(2))),
              Text(_roomLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const Spacer(),
              Text('${rc.occupied}/${rc.capacity} BEDS',
                  style: TextStyle(color: _roomColor, fontSize: 11,
                      fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: occupancy,
              minHeight: 6,
              backgroundColor: _border,
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancy >= 0.95 ? _red : occupancy >= 0.80 ? Colors.orange : _green,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${(occupancy * 100).round()}% OCCUPIED',
                  style: TextStyle(color: _textDim, fontSize: 10,
                      letterSpacing: 1.2, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('${rc.free} FREE',
                  style: TextStyle(color: _roomColor, fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Text(label,
      style: TextStyle(color: _textMid, fontSize: 10,
          letterSpacing: 2.2, fontWeight: FontWeight.w600));

  Widget _avatarPlaceholder(Color tc) => Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: tc.withAlpha(31), shape: BoxShape.circle,
          border: Border.all(color: tc.withAlpha(77), width: 1),
        ),
        child: Icon(Icons.person_outline, color: _textMid, size: 20),
      );

  Widget _buildPatientCard(Patient p) {
    final tc = _triageColor(p.triageColor);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patient: p, isDoctor: true),
        ),
      ).then((_) => _loadData()),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4, height: 62,
            decoration: BoxDecoration(
              color: tc,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
          p.photoUrl != null
              ? ClipOval(
                  child: Image.network(p.photoUrl!,
                      width: 34, height: 34, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarPlaceholder(tc)),
                )
              : _avatarPlaceholder(tc),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('#${p.wristbandNumber}',
                      style: const TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(width: 6),
                  Icon(_genderIcon(p.sex), color: _textMid, size: 14),
                  const SizedBox(width: 4),
                  Text(_ageLabel(p.ageRange),
                      style: TextStyle(color: _textMid, fontSize: 12,
                          fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                ]),
                const SizedBox(height: 3),
                Text(_timeAgo(p.arrivedAt),
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
    ),
    );
  }

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
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (i == 2) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: _card,
                    title: const Text('Logout', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure?',
                        style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                  }
                }
                return;
              }
              setState(() => _navIndex = i);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Icon(active ? items[i].$2 : items[i].$1,
                  color: active ? _green : _textDim, size: 24),
            ),
          );
        }),
      ),
    );
  }
}

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
    canvas.drawPath(hexPath,
        Paint()..color = const Color(0xFF8CBF3F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round);
    final arm = size.width * 0.22;
    final p = Paint()..color = const Color(0xFF8CBF3F)..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), p);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), p);
    final dots = [const Color(0xFFE05050), const Color(0xFFF5C842), const Color(0xFF50E070)];
    for (int i = 0; i < 3; i++) {
      final angle = (i * 60 + 90) * (3.14159265 / 180);
      canvas.drawCircle(Offset(cx + (r + 4) * _cos(angle), cy + (r + 4) * _sin(angle)),
          3, Paint()..color = dots[i]);
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
