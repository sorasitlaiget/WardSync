import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/patient_model.dart';
import '../../widgets/wardsync_app_bar.dart';
import 'patient_detail_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedNavIndex = 0;

  final String _operatorName = 'Doctor J.';
  final String _assignedRoom = 'Red Room';
  final TriageColor _roomColor = TriageColor.red;
  final int _totalBeds = 10;
  final int _occupiedBeds = 8;

  final List<_PatientCardData> _patients = [
    _PatientCardData(
      wristbandNumber: '048',
      sex: PatientSex.male,
      ageRange: AgeRange.adult,
      triageColor: TriageColor.red,
      arrivedAt: DateTime.now().subtract(const Duration(seconds: 30)),
      status: PatientStatus.inTreatment,
    ),
    _PatientCardData(
      wristbandNumber: '034',
      sex: PatientSex.male,
      ageRange: AgeRange.child,
      triageColor: TriageColor.red,
      arrivedAt: DateTime.now().subtract(const Duration(minutes: 7)),
      status: PatientStatus.waiting,
    ),
    _PatientCardData(
      wristbandNumber: '030',
      sex: PatientSex.female,
      ageRange: AgeRange.senior,
      triageColor: TriageColor.red,
      arrivedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      status: PatientStatus.waiting,
    ),
  ];

  Color get _roomAccentColor {
    switch (_roomColor) {
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

  double get _occupancyRatio => _occupiedBeds / _totalBeds;
  int get _freeBeds => _totalBeds - _occupiedBeds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WardSyncAppBar(
        title: 'DOCTOR',
        badge: BadgeVariant.redRoom,
        subtitle: 'Operator: $_operatorName',
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRoomCapacityCard(),
                  const SizedBox(height: 20),
                  _buildPatientListHeader(),
                  const SizedBox(height: 10),
                  ..._patients.map(_buildPatientCard),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildRoomCapacityCard() {
    final occupancyPercent = (_occupancyRatio * 100).round();
    final Color barColor = occupancyPercent >= 95
        ? AppColors.dotRed
        : occupancyPercent >= 80
            ? AppColors.dotYellow
            : AppColors.dotGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _roomAccentColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _assignedRoom.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$_occupiedBeds/$_totalBeds BEDS',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _occupancyRatio,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$occupancyPercent% OCCUPIED',
                style: GoogleFonts.rajdhani(
                  color: barColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$_freeBeds FREE',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'PATIENT',
          style: GoogleFonts.rajdhani(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${_patients.length} ACTIVE',
          style: GoogleFonts.rajdhani(
            color: AppColors.textMuted,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(_PatientCardData patient) {
    final Color borderColor;
    switch (patient.triageColor) {
      case TriageColor.red:
        borderColor = AppColors.dotRed;
        break;
      case TriageColor.yellow:
        borderColor = AppColors.dotYellow;
        break;
      case TriageColor.green:
        borderColor = AppColors.dotGreen;
        break;
      case TriageColor.black:
        borderColor = AppColors.dotBlack;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailScreen(
                  wristbandNumber: patient.wristbandNumber,
                  sex: patient.sex,
                  ageRange: patient.ageRange,
                  triageColor: patient.triageColor,
                  arrivedAt: patient.arrivedAt,
                  status: patient.status,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${patient.wristbandNumber}',
                            style: GoogleFonts.rajdhani(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            patient.sex == PatientSex.male
                                ? Icons.male
                                : Icons.female,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            patient.ageRangeLabel,
                            style: GoogleFonts.rajdhani(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatArrivalTime(patient.arrivedAt),
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (patient.status == PatientStatus.inTreatment)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.triageGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'TREAT',
                      style: GoogleFonts.rajdhani(
                        color: AppColors.lime,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatArrivalTime(DateTime arrivedAt) {
    final diff = DateTime.now().difference(arrivedAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} hr ago';
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, Icons.home, 0),
              _navItem(Icons.assignment_outlined, Icons.assignment, 1),
              _navItem(Icons.settings_outlined, Icons.settings, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, int index) {
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.lime : AppColors.textMuted,
              size: 24,
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PatientCardData {
  final String wristbandNumber;
  final PatientSex sex;
  final AgeRange ageRange;
  final TriageColor triageColor;
  final DateTime arrivedAt;
  final PatientStatus status;

  _PatientCardData({
    required this.wristbandNumber,
    required this.sex,
    required this.ageRange,
    required this.triageColor,
    required this.arrivedAt,
    required this.status,
  });

  String get ageRangeLabel {
    switch (ageRange) {
      case AgeRange.infant:
        return 'INFANT';
      case AgeRange.child:
        return 'CHILD';
      case AgeRange.adult:
        return 'ADULT';
      case AgeRange.senior:
        return 'SENIOR';
    }
  }
}
