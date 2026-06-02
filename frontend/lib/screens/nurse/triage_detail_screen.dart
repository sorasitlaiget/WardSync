import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/patients/repositories/patient_repository.dart';
import '../../theme/app_theme.dart';
import '../../models/patient_model.dart';
import '../../widgets/wardsync_app_bar.dart';

class TriageDetailScreen extends StatefulWidget {
  final String wristbandNumber;
  final bool hasPhoto;

  const TriageDetailScreen({
    super.key,
    required this.wristbandNumber,
    required this.hasPhoto,
  });

  @override
  State<TriageDetailScreen> createState() => _TriageDetailScreenState();
}

class _TriageDetailScreenState extends State<TriageDetailScreen> {
  PatientSex? _selectedSex;
  AgeRange? _selectedAgeRange;
  TriageColor? _selectedColor;

  bool _isSubmitting = false;
  final _repo = PatientRepository();

  bool get _canSubmit =>
      _selectedSex != null &&
      _selectedAgeRange != null &&
      _selectedColor != null &&
      !_isSubmitting;

  String get _admitButtonLabel {
    if (_selectedColor == null) return 'SELECT TRIAGE COLOR';
    switch (_selectedColor!) {
      case TriageColor.red:
        return 'ADMIT  →  RED ROOM';
      case TriageColor.yellow:
        return 'ADMIT  →  YELLOW ROOM';
      case TriageColor.green:
        return 'ADMIT  →  GREEN ROOM';
      case TriageColor.black:
        return 'ADMIT  →  BLACK ROOM';
    }
  }

  Color get _admitButtonColor {
    if (_selectedColor == null) return AppColors.surfaceVariant;
    switch (_selectedColor!) {
      case TriageColor.red:
        return AppColors.admitButton;
      case TriageColor.yellow:
        return AppColors.triageYellowActive;
      case TriageColor.green:
        return AppColors.triageGreenActive;
      case TriageColor.black:
        return AppColors.triageBlackActive;
    }
  }

  Future<void> _onAdmit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    try {
      await _repo.createPatient({
        'wristbandNumber': widget.wristbandNumber,
        'sex': _selectedSex!.name,
        'ageRange': _selectedAgeRange == AgeRange.senior ? 'elder' : _selectedAgeRange!.name,
        'triageColor': _selectedColor!.name,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Patient #${widget.wristbandNumber} admitted to ${_selectedColor!.name.toUpperCase()} ROOM',
          ),
          backgroundColor: AppColors.surface,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WardSyncAppBar(
        title: 'TRIAGE #${widget.wristbandNumber}',
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('SEX'),
                  const SizedBox(height: 12),
                  _buildSexSelector(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('AGE RANGE'),
                  const SizedBox(height: 12),
                  _buildAgeRangeSelector(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('TRIAGE COLOR (START)'),
                  const SizedBox(height: 12),
                  _buildColorSelector(),
                ],
              ),
            ),
          ),
          _buildAdmitButton(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
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

  Widget _buildSexSelector() {
    return Row(
      children: [
        _sexButton(PatientSex.male, Icons.male, 'MALE'),
        const SizedBox(width: 12),
        _sexButton(PatientSex.female, Icons.female, 'FEMALE'),
      ],
    );
  }

  Widget _sexButton(PatientSex sex, IconData icon, String label) {
    final isSelected = _selectedSex == sex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSex = sex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.triageGreen : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.lime.withOpacity(0.5) : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.lime : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: isSelected ? AppColors.lime : AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeRangeSelector() {
    // (range, icon, label) — use Material icons for consistent look
    final ranges = [
      (AgeRange.infant,  Icons.child_care,      '0-5'),
      (AgeRange.child,   Icons.face_retouching_natural, '6-17'),
      (AgeRange.adult,   Icons.person,           '18-60'),
      (AgeRange.senior,  Icons.elderly,          '60+'),
    ];
    return Row(
      children: ranges.map((r) {
        final (range, icon, label) = r;
        final isSelected = _selectedAgeRange == range;
        final isLast = range == AgeRange.senior;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedAgeRange = range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.triageGreen
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.lime.withOpacity(0.5)
                      : AppColors.cardBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 26,
                    color: isSelected
                        ? AppColors.lime
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      color: isSelected
                          ? AppColors.lime
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      children: [
        Row(
          children: [
            _colorButton(TriageColor.red, AppColors.triageRed,
                AppColors.dotRed, 'RED'),
            const SizedBox(width: 12),
            _colorButton(TriageColor.yellow, AppColors.triageYellow,
                AppColors.dotYellow, 'YELLOW'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _colorButton(TriageColor.green, AppColors.triageGreen,
                AppColors.dotGreen, 'GREEN'),
            const SizedBox(width: 12),
            _colorButton(TriageColor.black, AppColors.triageBlack,
                AppColors.dotBlack, 'BLACK'),
          ],
        ),
      ],
    );
  }

  Widget _colorButton(
    TriageColor color,
    Color bgColor,
    Color dotColor,
    String label,
  ) {
    final isSelected = _selectedColor == color;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedColor = color),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? bgColor.withOpacity(0.9) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? dotColor.withOpacity(0.6)
                  : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? dotColor : dotColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: GestureDetector(
        onTap: _canSubmit ? _onAdmit : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _canSubmit ? _admitButtonColor : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            _admitButtonLabel,
            style: GoogleFonts.rajdhani(
              color: _canSubmit ? Colors.white : AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
