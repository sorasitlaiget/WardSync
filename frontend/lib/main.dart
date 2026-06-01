import 'package:flutter/material.dart';
import 'screens/login.screens.dart' as login;
import 'screens/register.screens.dart';
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
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4A7C59),
          secondary: const Color(0xFF8B4513),
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
      },
    );
  }
}
