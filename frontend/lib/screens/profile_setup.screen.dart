import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../shared/models/user_profile.dart';
import 'nurse/homenurse.screens.dart';
import 'doctor/homedoctor.screens.dart' as doctor;
import 'admin/adminhomepage.screens.dart' as admin;

class ProfileSetupScreen extends StatefulWidget {
  final UserProfile profile;
  const ProfileSetupScreen({super.key, required this.profile});

  static const routeName = '/profile-setup';

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const Color _bg = Color(0xFF0D0F0E);
  static const Color _green = Color(0xFF8CBF3F);
  static const Color _fieldBg = Color(0xFF1C2120);
  static const Color _border = Color(0xFF2A3230);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);

  final _authRepo = AuthRepository();
  late final TextEditingController _nameCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _nameCtrl.text.trim().isNotEmpty && !_isLoading;

  Future<void> _onSave() async {
    if (!_canSubmit) return;
    setState(() => _isLoading = true);
    try {
      await _authRepo.updateProfile({
        'name': _nameCtrl.text.trim(),
        'isProfileComplete': true,
      });
      if (!mounted) return;
      final nextRoute = widget.profile.role == UserRole.doctor
          ? doctor.DoctorHomeScreen.routeName
          : widget.profile.role == UserRole.admin
              ? admin.AdminOverviewScreen.routeName
              : NurseHomeScreen.routeName;
      Navigator.pushReplacementNamed(context, nextRoute);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(e.toString().replaceFirst('Exception: ', '')),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text('Complete Profile',
                  style: TextStyle(color: _textMid, fontSize: 15,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('SETUP',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    height: 1.0,
                  )),
              const SizedBox(height: 4),
              Text('Fill in your details before continuing',
                  style: TextStyle(color: _textDim, fontSize: 13)),
              const SizedBox(height: 36),

              // Name
              _fieldLabel('YOUR NAME'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: _inputDecoration('Full name'),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: _canSubmit ? _onSave : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _canSubmit ? _green : const Color(0xFF1C2120),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : Text('SAVE & CONTINUE',
                          style: GoogleFonts.rajdhani(
                            color: _canSubmit ? Colors.black : _textDim,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          )),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(label,
      style: TextStyle(color: _textDim, fontSize: 11,
          fontWeight: FontWeight.w600, letterSpacing: 1.5));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textDim, fontSize: 14),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF8CBF3F))),
      );

}
