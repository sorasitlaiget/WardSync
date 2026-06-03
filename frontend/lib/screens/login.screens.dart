import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/notifications/repositories/notification_repository.dart';
import '../../../shared/models/enums.dart';
import 'forgot_password.screens.dart';
import 'register.screens.dart';
import 'nurse/homenurse.screens.dart';
import 'doctor/homedoctor.screens.dart' as doctor;
import 'admin/adminhomepage.screens.dart' as admin;
import 'profile_setup.screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passcodeController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePasscode = true;
  final _authRepo = AuthRepository();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg = Color(0xFF0D0F0E);
  static const Color _green = Color(0xFF8CBF3F);
  static const Color _fieldBg = Color(0xFF1C2120);
  static const Color _border = Color(0xFF2A3230);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _saveFcmToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await NotificationRepository().registerFcmToken(token);
      }
    } catch (_) {}
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final profile = await _authRepo.signIn(
        _emailController.text.trim(),
        _passcodeController.text,
      );
      if (!mounted) return;
      _saveFcmToken();
      if (profile.name.trim().isEmpty && profile.role != UserRole.admin) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ProfileSetupScreen(profile: profile)));
        return;
      }
      final nextRoute = profile.role == UserRole.doctor
          ? doctor.DoctorHomeScreen.routeName
          : profile.role == UserRole.admin
              ? admin.AdminOverviewScreen.routeName
              : NurseHomeScreen.routeName;
      Navigator.pushReplacementNamed(context, nextRoute);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top "Login" label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                'Login',
                style: TextStyle(
                  color: _textMid,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),

                            // Hexagon Logo
                            _WardSyncHexLogo(),

                            const SizedBox(height: 22),

                            // WARDSYNC title
                            Text(
                              'WARDSYNC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'FIELD HOSPITAL OS',
                              style: TextStyle(
                                color: _green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.8,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // OPERATOR ID field
                            _buildFieldLabel('OPERATOR ID'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: _inputDecoration(
                                  'email@hospital.org', false, null),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Operator ID required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // PASSCODE field
                            _buildFieldLabel('PASSCODE'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passcodeController,
                              obscureText: _obscurePasscode,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16,
                                  letterSpacing: 4),
                              decoration: _inputDecoration(
                                '••••••••',
                                true,
                                IconButton(
                                  icon: Icon(
                                    _obscurePasscode
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _textDim,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePasscode = !_obscurePasscode),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Passcode required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // LOGIN button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _authenticate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _green,
                                  disabledBackgroundColor:
                                      _green.withOpacity(0.6),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.black54,
                                        ),
                                      )
                                    : const Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Forgot passcode link
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                ForgotPasswordScreen.routeName,
                              ),
                              child: Text(
                                'Forgot passcode?',
                                style: TextStyle(
                                  color: _textDim,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New operator? ',
                                  style: TextStyle(
                                      color: _textDim, fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, RegisterScreen.routeName),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: _green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom version tag
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'v2.4.1 — SECURE CHANNEL',
                  style: TextStyle(
                    color: _textDim,
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: _textDim,
          fontSize: 10,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String hint, bool isPassword, Widget? suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: _textDim,
        fontSize: isPassword ? 14 : 13,
        letterSpacing: isPassword ? 3 : 0,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: _border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: _border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: _green.withOpacity(0.6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }
}

/// Custom hexagon logo painter matching the WardSync brand
class _WardSyncHexLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 90,
      child: CustomPaint(
        painter: _HexLogoPainter(),
      ),
    );
  }
}

class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.48;

    // Hexagon outline
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * (3.14159265 / 180);
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();

    final hexPaint = Paint()
      ..color = const Color(0xFF8CBF3F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(hexPath, hexPaint);

    // Inner cross / plus sign
    final crossPaint = Paint()
      ..color = const Color(0xFF8CBF3F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final armLen = size.width * 0.22;
    // Horizontal
    canvas.drawLine(
        Offset(cx - armLen, cy), Offset(cx + armLen, cy), crossPaint);
    // Vertical
    canvas.drawLine(
        Offset(cx, cy - armLen), Offset(cx, cy + armLen), crossPaint);

    // Corner dots (red, yellow, green — top 3 vertices)
    final dotColors = [
      const Color(0xFFE05050), // red
      const Color(0xFFF5C842), // yellow
      const Color(0xFF50E070), // green
    ];
    for (int i = 0; i < 3; i++) {
      final angle = (i * 60 + 90) * (3.14159265 / 180);
      final x = cx + (r + 5) * _cos(angle);
      final y = cy + (r + 5) * _sin(angle);
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = dotColors[i],
      );
    }
  }

  double _cos(double rad) => _mathCos(rad);
  double _sin(double rad) => _mathSin(rad);

  double _mathCos(double x) {
    // Taylor series approximation sufficient for hex angles
    return _dartCos(x);
  }

  double _mathSin(double x) {
    return _dartSin(x);
  }

  // Use dart:math
  double _dartCos(double x) => _cosSin(x, true);
  double _dartSin(double x) => _cosSin(x, false);

  double _cosSin(double x, bool isCos) {
    // Normalize x to [-pi, pi]
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    if (isCos) {
      double result = 1;
      double term = 1;
      for (int n = 1; n <= 8; n++) {
        term *= -x * x / ((2 * n - 1) * (2 * n));
        result += term;
      }
      return result;
    } else {
      double result = x;
      double term = x;
      for (int n = 1; n <= 8; n++) {
        term *= -x * x / ((2 * n) * (2 * n + 1));
        result += term;
      }
      return result;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}