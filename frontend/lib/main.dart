import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/nurse/new_patient_screen.dart';
import 'screens/doctor/doctor_home_screen.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // เชื่อม Firebase Emulator
  await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);

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
      initialRoute: login.LoginScreen.routeName,
      routes: {
        '/nurse/new-patient': (_) => const NewPatientScreen(),
        '/doctor/home': (_) => const DoctorHomeScreen(),
        login.LoginScreen.routeName: (context) => const login.LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        NurseHomeScreen.routeName: (context) => const NurseHomeScreen(),
        doctor.DoctorHomeScreen.routeName: (context) =>
            const doctor.DoctorHomeScreen(),
        admin.AdminOverviewScreen.routeName: (context) =>
            const admin.AdminOverviewScreen(),
        admin_patients.AllPatientsScreen.routeName: (context) =>
            const admin_patients.AllPatientsScreen(),
        admin_inventory.InventoryScreen.routeName: (context) =>
            const admin_inventory.InventoryScreen(),
        admin_roomconfig.RoomConfigScreen.routeName: (context) =>
            const admin_roomconfig.RoomConfigScreen(),
        ForgotPasswordScreen.routeName: (context) =>
            const ForgotPasswordScreen(),
      },
    );
  }
}
