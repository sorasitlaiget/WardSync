import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wardsync_app_bar.dart';
import 'triage_detail_screen.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  String _wristbandNumber = '047';
  bool _hasPhoto = false;

  void _showNumberPad() {
    final controller = TextEditingController(text: _wristbandNumber);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'ENTER WRISTBAND #',
          style: GoogleFonts.rajdhani(
            color: AppColors.lime,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 3,
          autofocus: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.rajdhani(
            color: AppColors.textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: 10,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.lime),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.rajdhani(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _wristbandNumber = controller.text.padLeft(3, '0');
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'CONFIRM',
              style: GoogleFonts.rajdhani(
                color: AppColors.lime,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _takePhoto() {
    setState(() => _hasPhoto = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo captured'),
        backgroundColor: AppColors.surface,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onNext() {
    if (_wristbandNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter wristband number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TriageDetailScreen(
          wristbandNumber: _wristbandNumber,
          hasPhoto: _hasPhoto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WardSyncAppBar(
        title: 'NEW PATIENT',
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
                  _buildStepLabel(),
                  const SizedBox(height: 16),
                  _buildWristbandDisplay(),
                  const SizedBox(height: 8),
                  _buildWristbandHint(),
                  const SizedBox(height: 28),
                  _buildPhotoSection(),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
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
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel() {
    return Text(
      'STEP 1 OF 2  •  WRISTBAND',
      style: GoogleFonts.rajdhani(
        color: AppColors.textSecondary,
        fontSize: 13,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildWristbandDisplay() {
    final digits = _wristbandNumber.padLeft(3, '0').split('');
    return GestureDetector(
      onTap: _showNumberPad,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: digits.map((d) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                d,
                style: GoogleFonts.rajdhani(
                  color: AppColors.textPrimary,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWristbandHint() {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded,
            size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          'Read number printed on wristband',
          style: GoogleFonts.rajdhani(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PATIENT PHOTO',
          style: GoogleFonts.rajdhani(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: _hasPhoto
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.lime, size: 60),
                      const SizedBox(height: 10),
                      Text(
                        'PHOTO CAPTURED',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.lime,
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'TAP TO CAPTURE',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // RETAKE — top
          GestureDetector(
            onTap: () => setState(() => _hasPhoto = false),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              alignment: Alignment.center,
              child: Text(
                'RETAKE',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // NEXT → — bottom
          GestureDetector(
            onTap: _onNext,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT',
                    style: GoogleFonts.rajdhani(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward,
                      color: Colors.black, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
