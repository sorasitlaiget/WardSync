import 'package:flutter/material.dart';
import '../../widgets/wardsync_logo.dart';
import '../../../../features/patients/repositories/patient_repository.dart';
import '../../../../shared/models/patient.dart';

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

  List<Patient> _allPatients = [];
  bool _isLoading = true;
  final _repo = PatientRepository();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _repo.getPatients();
      if (!mounted) return;
      setState(() { _allPatients = patients; _isLoading = false; });
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

  int _countByColor(TriageColor c) => _allPatients.where((p) => p.triageColor == c).length;

  Color _triageColor(TriageColor c) {
    switch (c) {
      case TriageColor.red:    return _red;
      case TriageColor.yellow: return _yellow;
      case TriageColor.green:  return _grn;
      case TriageColor.black:  return const Color(0xFF6B7280);
    }
  }

  String _triageLabel(TriageColor t) {
    switch (t) {
      case TriageColor.red:    return 'Red';
      case TriageColor.yellow: return 'Yellow';
      case TriageColor.green:  return 'Green';
      case TriageColor.black:  return 'Black';
    }
  }

  String _ageLabel(AgeRange a) {
    switch (a) {
      case AgeRange.adult:  return 'ADULT';
      case AgeRange.child:  return 'CHILD';
      case AgeRange.elder: return 'SENIOR';
      case AgeRange.infant: return 'INFANT';
    }
  }

  String _statusLabel(PatientStatus s) {
    switch (s) {
      case PatientStatus.inTreatment: return 'In treatment';
      case PatientStatus.waiting:     return 'Waiting';
      case PatientStatus.discharged:  return 'Discharged';
      case PatientStatus.deceased:    return 'Deceased';
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
                    const SizedBox(height: 12),
                    _buildAddButton(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No patients found.'
                                : 'No patients match your search.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _textDim, fontSize: 13),
                          ),
                        ),
                      )
                    : ListView.builder(
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
          const WardSyncLogo(size: 32),
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
    final color = _triageColor(p.triageColor);
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
                    Text(p.wristbandNumber,
                        style: const TextStyle(color: Colors.white, fontSize: 14,
                            fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    const SizedBox(width: 6),
                    Icon(_genderIcon(p.sex), color: _textMid, size: 14),
                    const SizedBox(width: 4),
                    Text(_ageLabel(p.ageRange),
                        style: TextStyle(color: _textMid, fontSize: 12,
                            fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${p.room.name.toUpperCase()} ROOM : ${_statusLabel(p.status)}',
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
  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _showAddPatientDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('ADD PATIENT',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2.2)),
      ),
    );
  }

  void _showAddPatientDialog() {
    final idCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    TriageColor selectedTriage = TriageColor.red;
    AgeRange selectedAge = AgeRange.adult;
    Sex selectedGender = Sex.male;
    PatientStatus selectedStatus = PatientStatus.waiting;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: _border)),
          title: Text('ADD PATIENT',
              style: TextStyle(color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(idCtrl, 'Wristband # (e.g. #001)'),
                const SizedBox(height: 12),
                _dialogField(roomCtrl, 'Room name (e.g. RED ROOM)'),
                const SizedBox(height: 14),
                _dialogDropdown<TriageColor>(
                  label: 'Triage',
                  value: selectedTriage,
                  items: TriageColor.values,
                  itemLabel: _triageLabel,
                  onChanged: (v) => setDialogState(() => selectedTriage = v!),
                ),
                const SizedBox(height: 12),
                _dialogDropdown<AgeRange>(
                  label: 'Age',
                  value: selectedAge,
                  items: AgeRange.values,
                  itemLabel: _ageLabel,
                  onChanged: (v) => setDialogState(() => selectedAge = v!),
                ),
                const SizedBox(height: 12),
                _dialogDropdown<Sex>(
                  label: 'Gender',
                  value: selectedGender,
                  items: Sex.values,
                  itemLabel: (g) => g == Sex.male ? 'Male' : 'Female',
                  onChanged: (v) => setDialogState(() => selectedGender = v!),
                ),
                const SizedBox(height: 12),
                _dialogDropdown<PatientStatus>(
                  label: 'Status',
                  value: selectedStatus,
                  items: PatientStatus.values,
                  itemLabel: _statusLabel,
                  onChanged: (v) => setDialogState(() => selectedStatus = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: TextStyle(color: _textDim, fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.black),
              onPressed: () async {
                final id = idCtrl.text.trim();
                if (id.isNotEmpty) {
                  Navigator.pop(ctx);
                  try {
                    await _repo.createPatient(data: {
                      'wristbandNumber': id,
                      'sex': selectedGender.name,
                      'ageRange': selectedAge == AgeRange.elder ? 'elder' : selectedAge.name,
                      'triageColor': selectedTriage.name,
                    });
                    await _loadPatients();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  }
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
        filled: true,
        fillColor: _fieldBg,
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

  Widget _dialogDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item),
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ))
          .toList(),
      onChanged: onChanged,
      dropdownColor: _card,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textDim, fontSize: 12),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _green.withOpacity(0.6), width: 1.5)),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 13),
    );
  }
  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final outlined = [Icons.home_outlined, Icons.person_outline, Icons.work_outline, Icons.settings_outlined];
    final filled   = [Icons.home,          Icons.person,         Icons.work,          Icons.settings];
    const labels   = ['Home', 'Patient', 'Inventory', 'Room Config'];
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(active ? filled[i] : outlined[i],
                      color: active ? _green : _textDim, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: TextStyle(color: active ? _green : _textDim, fontSize: 10),
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

