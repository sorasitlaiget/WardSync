import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'widgets/wardsync_logo.dart';
import 'screens/nurse/new_patient_screen.dart';
import 'screens/nurse/triage_detail_screen.dart';
import 'screens/doctor/doctor_home_screen.dart';

void main() {
import 'screens/login.screens.dart' as login;
import 'screens/register.screens.dart';
import 'screens/forgot_password.screens.dart';
import 'screens/nurse/homenurse.screens.dart';
import 'screens/doctor/homedoctor.screens.dart' as doctor;
import 'screens/admin/adminhomepage.screens.dart' as admin;
import 'screens/admin/allpatient.screens.dart' as admin_patients;
import 'screens/admin/inventory.screens.dart' as admin_inventory;
import 'screens/admin/roomconfig.screens.dart' as admin_roomconfig;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WardSyncApp());
}

class WardSyncApp extends StatelessWidget {
  const WardSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WardSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _DevRoleSelector(),
      routes: {
        '/nurse/new-patient': (_) => const NewPatientScreen(),
        '/doctor/home': (_) => const DoctorHomeScreen(),
      },
    );
  }
}

/// Dev launcher — remove when integrating with nurse home screen.
class _DevRoleSelector extends StatelessWidget {
  const _DevRoleSelector();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo + wordmark
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const WardSyncLogo(size: 52),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WARDSYNC',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.lime,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        'FIELD HOSPITAL OS',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEV LAUNCHER',
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _launchButton(
                context,
                label: 'NURSE — NEW PATIENT',
                subtitle: 'Triage Step 1 + Step 2',
                color: AppColors.dotGreen,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewPatientScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _launchButton(
                context,
                label: 'TRIAGE DETAIL #047',
                subtitle: 'Step 2 only (direct)',
                color: AppColors.dotYellow,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TriageDetailScreen(
                      wristbandNumber: '047',
                      hasPhoto: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _launchButton(
                context,
                label: 'DOCTOR HOME',
                subtitle: 'Red Room dashboard',
                color: AppColors.dotRed,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _launchButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.rajdhani(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      initialRoute: login.LoginScreen.routeName,
      routes: {
        login.LoginScreen.routeName: (context) => const login.LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        NurseHomeScreen.routeName: (context) => const NurseHomeScreen(),
        doctor.DoctorHomeScreen.routeName: (context) => const doctor.DoctorHomeScreen(),
        admin.AdminOverviewScreen.routeName: (context) => const admin.AdminOverviewScreen(),
        admin_patients.AllPatientsScreen.routeName: (context) => const admin_patients.AllPatientsScreen(),
        admin_inventory.InventoryScreen.routeName: (context) => const admin_inventory.InventoryScreen(),
        admin_roomconfig.RoomConfigScreen.routeName: (context) => const admin_roomconfig.RoomConfigScreen(),
        ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
