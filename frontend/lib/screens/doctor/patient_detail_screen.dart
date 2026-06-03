import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/medications/repositories/medication_repository.dart';
import '../../../features/patients/repositories/patient_repository.dart';
import '../../../shared/models/patient.dart';
import '../../../shared/models/enums.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wardsync_app_bar.dart';

// ── Local editable vitals form model ─────────────────────────────────────────
class _FormVitals {
  int systolic;
  int diastolic;
  int pulse;
  double temp;
  int spo2;
  int rr;
  bool hasData;

  _FormVitals()
      : systolic = 0,
        diastolic = 0,
        pulse = 0,
        temp = 0,
        spo2 = 0,
        rr = 0,
        hasData = false;

  // Thresholds match backend vitals-threshold.ts exactly
  bool get bpCritical => hasData && (systolic < 90 || systolic > 180 || diastolic < 60 || diastolic > 120);
  bool get pulseCritical => hasData && (pulse < 40 || pulse > 150);
  bool get tempCritical => hasData && (temp < 35.0 || temp > 39.5);
  bool get spo2Critical => hasData && spo2 < 90;
  bool get rrCritical => hasData && (rr < 8 || rr > 30);
}

// ── Medication item ───────────────────────────────────────────────────────────
class MedicationItem {
  final String name;
  final String dosage;
  bool administered;

  MedicationItem({
    required this.name,
    required this.dosage,
    this.administered = false,
  });
}

// ── Main screen ───────────────────────────────────────────────────────────────
class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  final bool isDoctor;

  const PatientDetailScreen({super.key, required this.patient, this.isDoctor = true});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PatientStatus _currentStatus;
  final _repo = PatientRepository();
  final _medRepo = MedicationRepository();

  // Vitals
  final _FormVitals _vitals = _FormVitals();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _rrCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();

  final List<MedicationItem> _medications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.isDoctor ? 3 : 2, vsync: this);
    _currentStatus = widget.patient.status;
    _sysCtrl.text = '';
    _diaCtrl.text = '';
    _pulseCtrl.text = '';
    _tempCtrl.text = '';
    _spo2Ctrl.text = '';
    _rrCtrl.text = '';
    _diagnosisCtrl.text = '';
    _loadLatestVitals();
  }

  Future<void> _loadLatestVitals() async {
    try {
      final list = await _repo.getVitalSigns(widget.patient.id);
      if (list.isEmpty || !mounted) return;
      final latest = list.first;
      final bp = (latest['bloodPressure'] as String? ?? '0/0').split('/');
      setState(() {
        _vitals.systolic = int.tryParse(bp.isNotEmpty ? bp[0] : '0') ?? 0;
        _vitals.diastolic = int.tryParse(bp.length > 1 ? bp[1] : '0') ?? 0;
        _vitals.pulse = (latest['heartRate'] as num?)?.toInt() ?? 0;
        _vitals.temp = (latest['temperature'] as num?)?.toDouble() ?? 0;
        _vitals.spo2 = (latest['oxygenSaturation'] as num?)?.toInt() ?? 0;
        _vitals.rr = (latest['respiratoryRate'] as num?)?.toInt() ?? 0;
        _vitals.hasData = true;
        _sysCtrl.text = _vitals.systolic.toString();
        _diaCtrl.text = _vitals.diastolic.toString();
        _pulseCtrl.text = _vitals.pulse.toString();
        _tempCtrl.text = _vitals.temp.toString();
        _spo2Ctrl.text = _vitals.spo2.toString();
        _rrCtrl.text = _vitals.rr.toString();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _pulseCtrl.dispose();
    _tempCtrl.dispose();
    _spo2Ctrl.dispose();
    _rrCtrl.dispose();
    _diagnosisCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Color get _triageDotColor {
    switch (widget.patient.triageColor) {
      case TriageColor.red:
        return AppColors.dotRed;
      case TriageColor.yellow:
        return AppColors.dotYellow;
      case TriageColor.green:
        return AppColors.dotGreen;
      case TriageColor.black:
        return AppColors.dotBlack;
    }
  }

  String get _triageLabel {
    switch (widget.patient.triageColor) {
      case TriageColor.red:
        return 'RED';
      case TriageColor.yellow:
        return 'YELLOW';
      case TriageColor.green:
        return 'GREEN';
      case TriageColor.black:
        return 'BLACK';
    }
  }

  String get _ageRangeLabel {
    switch (widget.patient.ageRange) {
      case AgeRange.infant:
        return 'INFANT';
      case AgeRange.child:
        return 'CHILD';
      case AgeRange.adult:
        return 'ADULT';
      case AgeRange.elder:
        return 'SENIOR';
    }
  }

  String get _arrivedTimeLabel {
    final h = widget.patient.arrivedAt.hour.toString().padLeft(2, '0');
    final m = widget.patient.arrivedAt.minute.toString().padLeft(2, '0');
    return '${widget.patient.triageColor.name.toUpperCase()} ROOM : ARRIVED $h:$m';
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.person_outline,
          color: AppColors.textSecondary, size: 32),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WardSyncAppBar(
        title: '#${widget.patient.wristbandNumber} VITALS',
        badge: BadgeVariant.nurse,
        subtitle: _arrivedTimeLabel,
      ),
      body: Column(
        children: [
          _buildPatientCard(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  vitals: _vitals,
                  status: _currentStatus,
                  canChangeStatus: widget.isDoctor,
                  onStatusChange: (s) async {
                    setState(() => _currentStatus = s);
                    try {
                      await _repo.updateStatus(widget.patient.id, s);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  },
                ),
                _VitalTab(
                  vitals: _vitals,
                  sysCtrl: _sysCtrl,
                  diaCtrl: _diaCtrl,
                  pulseCtrl: _pulseCtrl,
                  tempCtrl: _tempCtrl,
                  spo2Ctrl: _spo2Ctrl,
                  rrCtrl: _rrCtrl,
                  onSave: _saveVitals,
                ),
                if (widget.isDoctor)
                  _TreatmentTab(
                    diagnosisCtrl: _diagnosisCtrl,
                    medications: _medications,
                    onAddMedication: _showAddMedicationDialog,
                    onSave: _saveTreatment,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: _triageDotColor, width: 4),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.patient.photoUrl != null
                ? Image.network(
                    widget.patient.photoUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _photoPlaceholder(),
                  )
                : _photoPlaceholder(),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${widget.patient.wristbandNumber}',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Triage color pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _triageDotColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _triageDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _triageLabel,
                          style: GoogleFonts.rajdhani(
                            color: _triageDotColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    widget.patient.sex == Sex.male ? Icons.male : Icons.female,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.patient.sex == Sex.male ? 'MALE' : 'FEMALE',
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                _ageRangeLabel,
                style: GoogleFonts.rajdhani(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.lime,
        indicatorWeight: 2,
        labelColor: AppColors.lime,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.rajdhani(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        tabs: [
          const Tab(text: 'OVERVIEW'),
          const Tab(text: 'VITAL'),
          if (widget.isDoctor) const Tab(text: 'TREATMENT'),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Future<void> _saveVitals() async {
    setState(() {
      _vitals.systolic = int.tryParse(_sysCtrl.text) ?? _vitals.systolic;
      _vitals.diastolic = int.tryParse(_diaCtrl.text) ?? _vitals.diastolic;
      _vitals.pulse = int.tryParse(_pulseCtrl.text) ?? _vitals.pulse;
      _vitals.temp = double.tryParse(_tempCtrl.text) ?? _vitals.temp;
      _vitals.spo2 = int.tryParse(_spo2Ctrl.text) ?? _vitals.spo2;
      _vitals.rr = int.tryParse(_rrCtrl.text) ?? _vitals.rr;
    });
    try {
      await _repo.addVitalSigns(widget.patient.id, {
        'bloodPressure': '${_vitals.systolic}/${_vitals.diastolic}',
        'heartRate': _vitals.pulse,
        'temperature': _vitals.temp,
        'oxygenSaturation': _vitals.spo2,
        'respiratoryRate': _vitals.rr,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vitals saved'),
        backgroundColor: AppColors.surface,
        duration: Duration(seconds: 1),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Future<void> _saveTreatment() async {
    try {
      await _repo.addTreatment(widget.patient.id, {
        'diagnosis': _diagnosisCtrl.text,
        'treatment': _medications.map((m) => '${m.name} ${m.dosage}').join(', '),
        'notes': '',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Treatment saved'),
        backgroundColor: AppColors.surface,
        duration: Duration(seconds: 1),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Future<void> _showAddMedicationDialog() async {
    List<Medication> inventory = [];
    bool isLoadingMeds = true;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          if (isLoadingMeds) {
            () async {
              try {
                final list = await _medRepo.getMedications();
                setModal(() {
                  inventory = list.where((m) => m.quantity > 0).toList();
                  isLoadingMeds = false;
                });
              } catch (_) {
                setModal(() => isLoadingMeds = false);
              }
            }();
          }
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (_, scrollCtrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text('SELECT MEDICATION',
                          style: GoogleFonts.rajdhani(
                            color: AppColors.lime,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          )),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.cardBorder, height: 1),
                Expanded(
                  child: isLoadingMeds
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.lime, strokeWidth: 2))
                      : inventory.isEmpty
                          ? Center(
                              child: Text('No medications available',
                                  style: GoogleFonts.rajdhani(
                                      color: AppColors.textSecondary)))
                          : ListView.separated(
                              controller: scrollCtrl,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: inventory.length,
                              separatorBuilder: (_, __) => const Divider(
                                  color: AppColors.cardBorder, height: 1),
                              itemBuilder: (_, i) {
                                final med = inventory[i];
                                final alreadyAdded = _medications
                                    .any((m) => m.name == med.name);
                                return ListTile(
                                  title: Text(med.name,
                                      style: GoogleFonts.rajdhani(
                                        color: alreadyAdded
                                            ? AppColors.textMuted
                                            : AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  subtitle: Text(
                                      '${med.dosage}  ·  stock: ${med.quantity}',
                                      style: GoogleFonts.rajdhani(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                  trailing: alreadyAdded
                                      ? const Icon(Icons.check,
                                          color: AppColors.lime, size: 18)
                                      : const Icon(Icons.add,
                                          color: AppColors.lime, size: 20),
                                  onTap: alreadyAdded
                                      ? null
                                      : () {
                                          setState(() {
                                            _medications.add(MedicationItem(
                                              name: med.name,
                                              dosage: med.dosage,
                                            ));
                                          });
                                          Navigator.pop(ctx);
                                        },
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ═══════════════════════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final _FormVitals vitals;
  final PatientStatus status;
  final ValueChanged<PatientStatus> onStatusChange;
  final bool canChangeStatus;

  const _OverviewTab({
    required this.vitals,
    required this.status,
    required this.onStatusChange,
    this.canChangeStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('LATEST VITALS'),
          const SizedBox(height: 10),
          _buildVitalsGrid(),
          if (canChangeStatus) ...[
            const SizedBox(height: 24),
            _sectionLabel('CHANGE STATUS'),
            const SizedBox(height: 10),
            _buildStatusButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.rajdhani(
        color: AppColors.textSecondary,
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _vitalCard(
              label: 'BP',
              value: '${vitals.systolic}/${vitals.diastolic}',
              unit: 'mmHg',
              critical: vitals.bpCritical,
              showAlert: vitals.bpCritical,
            )),
            const SizedBox(width: 10),
            Expanded(child: _vitalCard(
              label: 'PULSE',
              value: vitals.pulse.toString(),
              unit: 'bpm',
              critical: vitals.pulseCritical,
            )),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _vitalCard(
              label: 'TEMP',
              value: vitals.temp.toString(),
              unit: '°C',
              critical: vitals.tempCritical,
            )),
            const SizedBox(width: 10),
            Expanded(child: _vitalCard(
              label: 'SPO2',
              value: vitals.spo2.toString(),
              unit: '%',
              critical: vitals.spo2Critical,
            )),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _vitalCard(
              label: 'RESP RATE',
              value: vitals.rr.toString(),
              unit: '/min',
              critical: vitals.rrCritical,
            )),
            const SizedBox(width: 10),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _vitalCard({
    required String label,
    required String value,
    required String unit,
    required bool critical,
    bool showAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: critical
            ? const Color(0xFF3A1010)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: critical
              ? AppColors.dotRed.withOpacity(0.4)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: critical
                      ? AppColors.dotRed.withOpacity(0.8)
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              if (showAlert)
                const Icon(Icons.error_outline,
                    color: AppColors.dotRed, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.rajdhani(
                  color: critical ? AppColors.dotRed : AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(BuildContext context) {
    return Row(
      children: [
        _statusBtn(
          context,
          label: '·TREAT',
          color: const Color(0xFF0077AA),
          active: status == PatientStatus.inTreatment,
          onTap: () => onStatusChange(PatientStatus.inTreatment),
        ),
        const SizedBox(width: 8),
        _statusBtn(
          context,
          label: '·DISCH',
          color: AppColors.triageGreenActive,
          active: status == PatientStatus.discharged,
          onTap: () => onStatusChange(PatientStatus.discharged),
        ),
        const SizedBox(width: 8),
        _statusBtn(
          context,
          label: '·DEC',
          color: AppColors.textMuted,
          active: status == PatientStatus.deceased,
          onTap: () => onStatusChange(PatientStatus.deceased),
        ),
      ],
    );
  }

  Widget _statusBtn(
    BuildContext context, {
    required String label,
    required Color color,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(active ? 0.9 : 0.35)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: active ? color : color.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VITAL TAB
// ═══════════════════════════════════════════════════════════════════════════════
class _VitalTab extends StatelessWidget {
  final _FormVitals vitals;
  final TextEditingController sysCtrl;
  final TextEditingController diaCtrl;
  final TextEditingController pulseCtrl;
  final TextEditingController tempCtrl;
  final TextEditingController spo2Ctrl;
  final TextEditingController rrCtrl;
  final VoidCallback onSave;

  const _VitalTab({
    required this.vitals,
    required this.sysCtrl,
    required this.diaCtrl,
    required this.pulseCtrl,
    required this.tempCtrl,
    required this.spo2Ctrl,
    required this.rrCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('BLOOD PRESSURE (mmHgh)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _numField(sysCtrl)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '/',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(child: _numField(diaCtrl)),
                  ],
                ),
                const SizedBox(height: 16),
                _fieldLabel('PULSE (BPM)'),
                const SizedBox(height: 8),
                _numField(pulseCtrl, fullWidth: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('TEMP (°C)'),
                          const SizedBox(height: 8),
                          _numField(tempCtrl, fullWidth: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('SPO2 (%)'),
                          const SizedBox(height: 8),
                          _numField(spo2Ctrl, fullWidth: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _fieldLabel('RESPIRATORY RATE (breaths/min)'),
                const SizedBox(height: 8),
                _numField(rrCtrl, fullWidth: true),
              ],
            ),
          ),
        ),
        // Alert + save button — pinned at bottom, close together
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vitals.bpCritical)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _buildAlertBanner(),
              ),
            _buildSaveButton(onSave),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.rajdhani(
        color: AppColors.textSecondary,
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: GoogleFonts.rajdhani(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.lime),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dotRed.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.dotRed, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'BP BELOW THRESHOLD  Doctor will be notified',
              style: GoogleFonts.rajdhani(
                color: AppColors.dotRed,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TREATMENT TAB
// ═══════════════════════════════════════════════════════════════════════════════
class _TreatmentTab extends StatelessWidget {
  final TextEditingController diagnosisCtrl;
  final List<MedicationItem> medications;
  final VoidCallback onAddMedication;
  final VoidCallback onSave;

  const _TreatmentTab({
    required this.diagnosisCtrl,
    required this.medications,
    required this.onAddMedication,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('DIAGNOSIS'),
                const SizedBox(height: 10),
                _buildDiagnosisField(),
                const SizedBox(height: 20),
                _sectionLabel('MEDICATION ORDER'),
                const SizedBox(height: 10),
                ...(medications.map(_buildMedCard)),
              ],
            ),
          ),
        ),
        // ADD MEDICATION + SAVE VITALS — pinned at bottom, close together
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          color: AppColors.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onAddMedication,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lime.withOpacity(0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+ ADD MEDICATION',
                    style: GoogleFonts.rajdhani(
                      color: AppColors.lime,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onSave,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'SAVE VITALS',
                    style: GoogleFonts.rajdhani(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.rajdhani(
        color: AppColors.textSecondary,
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDiagnosisField() {
    return TextField(
      controller: diagnosisCtrl,
      maxLines: 3,
      style: GoogleFonts.rajdhani(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.lime),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMedCard(MedicationItem med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  med.dosage,
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (med.administered)
            const Icon(Icons.check, color: AppColors.lime, size: 20),
        ],
      ),
    );
  }

}

// ── Shared save button ────────────────────────────────────────────────────────
Widget _buildSaveButton(VoidCallback onSave) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
    color: AppColors.background,
    child: GestureDetector(
      onTap: onSave,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          'SAVE VITALS',
          style: GoogleFonts.rajdhani(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    ),
  );
}
