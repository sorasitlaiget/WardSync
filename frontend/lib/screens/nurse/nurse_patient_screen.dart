import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/wardsync_logo.dart';
import '../../../features/patients/repositories/patient_repository.dart';
import '../../../shared/models/patient.dart';
import '../doctor/patient_detail_screen.dart';

class NursePatientScreen extends StatefulWidget {
  const NursePatientScreen({super.key});

  static const routeName = '/nurse-patients';

  @override
  State<NursePatientScreen> createState() => _NursePatientScreenState();
}

class _NursePatientScreenState extends State<NursePatientScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFF0D0F0E);
  static const Color _card = Color(0xFF161A19);
  static const Color _border = Color(0xFF2A3230);
  static const Color _green = Color(0xFF8CBF3F);
  static const Color _red = Color(0xFFD94040);
  static const Color _yellow = Color(0xFFE8B840);
  static const Color _grn = Color(0xFF4CAF50);
  static const Color _blk = Color(0xFF6B7280);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);
  static const Color _fieldBg = Color(0xFF1C2120);

  final int _navIndex = 1;
  TriageColor? _filterColor;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  List<Patient> _allPatients = [];
  bool _isLoading = true;
  final _repo = PatientRepository();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _searchController
        .addListener(() => setState(() => _searchQuery = _searchController.text));
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _repo.getPatients();
      if (!mounted) return;
      setState(() {
        _allPatients = patients;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> get _filtered {
    return _allPatients.where((p) {
      final matchColor = _filterColor == null || p.triageColor == _filterColor;
      final matchSearch = _searchQuery.isEmpty ||
          p.wristbandNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchColor && matchSearch;
    }).toList();
  }

  int _countByColor(TriageColor c) =>
      _allPatients.where((p) => p.triageColor == c).length;

  Color _triageColor(TriageColor c) {
    switch (c) {
      case TriageColor.red:
        return _red;
      case TriageColor.yellow:
        return _yellow;
      case TriageColor.green:
        return _grn;
      case TriageColor.black:
        return const Color(0xFF6B7280);
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

  String _statusLabel(PatientStatus s) {
    switch (s) {
      case PatientStatus.inTreatment:
        return 'In treatment';
      case PatientStatus.waiting:
        return 'Waiting';
      case PatientStatus.discharged:
        return 'Discharged';
      case PatientStatus.deceased:
        return 'Deceased';
    }
  }

  IconData _genderIcon(Sex g) => g == Sex.male ? Icons.male : Icons.female;

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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : _filtered.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No patients found.'
                                  : 'No patients match your search.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: _textDim, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) =>
                                _buildPatientCard(_filtered[i]),
                          ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(
        'Nurse Patient',
        style: TextStyle(
          color: _textMid,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

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
          const WardSyncLogo(size: 32),
          const SizedBox(width: 10),
          const Text(
            'PATIENT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.15),
              border: Border.all(color: _green, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'NURSE',
              style: TextStyle(
                color: _green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _green.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(null, 'ALL • ${_allPatients.length}', _textMid),
          const SizedBox(width: 8),
          _filterChip(
              TriageColor.red, '• ${_countByColor(TriageColor.red)} RED', _red),
          const SizedBox(width: 8),
          _filterChip(TriageColor.yellow,
              '• ${_countByColor(TriageColor.yellow)} YELLOW', _yellow),
          const SizedBox(width: 8),
          _filterChip(TriageColor.green,
              '• ${_countByColor(TriageColor.green)} GREEN', _grn),
          const SizedBox(width: 8),
          _filterChip(TriageColor.black,
              '• ${_countByColor(TriageColor.black)} BLACK', _blk),
        ],
      ),
    );
  }

  Widget _filterChip(TriageColor? color, String label, Color chipColor) {
    final active = _filterColor == color;
    return GestureDetector(
      onTap: () => setState(() => _filterColor = color),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? chipColor.withValues(alpha: 0.18) : _fieldBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? chipColor : _border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? chipColor : _textDim,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

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
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _border, width: 1),
        ),
        child: Row(
          children: [
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
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
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
                        '#${p.wristbandNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(_genderIcon(p.sex), color: _textMid, size: 14),
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
                    '${p.room.name.toUpperCase()} ROOM : ${_statusLabel(p.status)}',
                    style: TextStyle(color: _textDim, fontSize: 11),
                  ),
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
    final outlined = [Icons.home_outlined, Icons.assignment_outlined, Icons.settings_outlined];
    final filled = [Icons.home, Icons.assignment, Icons.settings];
    const labels = ['Home', 'Patient', 'Setting'];

    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (i) {
          final active = _navIndex == i;
          return GestureDetector(
            onTap: () async {
              if (i == 0) {
                Navigator.pushReplacementNamed(context, '/nurse-home');
              } else if (i == 2) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: _card,
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.white)),
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
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (_) => false);
                  }
                }
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? filled[i] : outlined[i],
                    color: active ? _green : _textDim,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: active ? _green : _textDim,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
