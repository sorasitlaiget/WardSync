import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  _FormVitals()
      : systolic = 80,
        diastolic = 50,
        pulse = 130,
        temp = 38.2,
        spo2 = 94;

  bool get bpCritical => systolic < 90 || diastolic < 60;
  bool get pulseCritical => pulse > 120 || pulse < 50;
  bool get tempCritical => temp > 38.5 || temp < 35.0;
  bool get spo2Critical => spo2 < 95;
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

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PatientStatus _currentStatus;
  final _repo = PatientRepository();

  // Vitals
  final _FormVitals _vitals = _FormVitals();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();

  // Medications
  final List<MedicationItem> _medications = [
    MedicationItem(
        name: 'Normal Saline', dosage: '500ml IV bolus', administered: true),
    MedicationItem(
        name: 'Ceftriaxone', dosage: '2g IV stat', administered: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentStatus = widget.patient.status;
    _sysCtrl.text = _vitals.systolic.toString();
    _diaCtrl.text = _vitals.diastolic.toString();
    _pulseCtrl.text = _vitals.pulse.toString();
    _tempCtrl.text = _vitals.temp.toString();
    _spo2Ctrl.text = _vitals.spo2.toString();
    _diagnosisCtrl.text =
        'Suspected sepsis Hypotensive, tachy cardic Start fluidresuscitation';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _pulseCtrl.dispose();
    _tempCtrl.dispose();
    _spo2Ctrl.dispose();
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
                  onStatusChange: (s) => setState(() => _currentStatus = s),
                ),
                _VitalTab(
                  vitals: _vitals,
                  sysCtrl: _sysCtrl,
                  diaCtrl: _diaCtrl,
                  pulseCtrl: _pulseCtrl,
                  tempCtrl: _tempCtrl,
                  spo2Ctrl: _spo2Ctrl,
                  onSave: _saveVitals,
                ),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_outline,
                color: AppColors.textSecondary, size: 32),
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
        tabs: const [
          Tab(text: 'OVERVIEW'),
          Tab(text: 'VITAL'),
          Tab(text: 'TREATMENT'),
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
    });
    try {
      await _repo.addVitalSigns(widget.patient.id, {
        'systolic': _vitals.systolic,
        'diastolic': _vitals.diastolic,
        'pulse': _vitals.pulse,
        'temperature': _vitals.temp,
        'spo2': _vitals.spo2,
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
        'medication': _medications.map((m) => '${m.name} ${m.dosage}').join(', '),
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

  void _showAddMedicationDialog() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'ADD MEDICATION',
          style: GoogleFonts.rajdhani(
            color: AppColors.lime,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Drug name'),
            const SizedBox(height: 12),
            _dialogField(doseCtrl, 'Dosage (e.g. 500ml IV bolus)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL',
                style: GoogleFonts.rajdhani(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _medications.add(MedicationItem(
                    name: nameCtrl.text,
                    dosage: doseCtrl.text,
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'ADD',
              style: GoogleFonts.rajdhani(
                color: AppColors.lime,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.rajdhani(
          color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.rajdhani(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.lime),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  const _OverviewTab({
    required this.vitals,
    required this.status,
    required this.onStatusChange,
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
          const SizedBox(height: 24),
          _sectionLabel('CHANGE STATUS'),
          const SizedBox(height: 10),
          _buildStatusButtons(context),
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
  final VoidCallback onSave;

  const _VitalTab({
    required this.vitals,
    required this.sysCtrl,
    required this.diaCtrl,
    required this.pulseCtrl,
    required this.tempCtrl,
    required this.spo2Ctrl,
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
