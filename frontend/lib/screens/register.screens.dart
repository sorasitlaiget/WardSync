import 'package:flutter/material.dart';
import '../../features/auth/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePasscode = true;
  bool _obscureConfirm = true;
  final _authRepo = AuthRepository();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg = Color(0xFF0D0F0E);
  static const Color _fieldBg = Color(0xFF1C2120);
  static const Color _border = Color(0xFF2A3230);
  static const Color _green = Color(0xFF8CBF3F);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);

  final List<String> _roles = [
    'Nurse',
    'Doctor',
    'Admin',
  ];
  String? _selectedRole;

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
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _passcodeController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authRepo.register(
        _emailController.text.trim(),
        _passcodeController.text,
        _nameController.text.trim(),
        (_selectedRole ?? 'Nurse').toLowerCase(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _green,
          content: const Text(
            'Operator Registered',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
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
            // Top bar with back arrow + "Register"
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: _textMid, size: 16),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Text(
                    'Register',
                    style: TextStyle(
                      color: _textMid,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
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
                          const SizedBox(height: 20),

                          // Hex Logo
                          _WardSyncHexLogo(),

                          const SizedBox(height: 18),

                          Text(
                            'WARDSYNC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
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

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'NEW OPERATOR REGISTRATION',
                            style: TextStyle(
                              color: _textDim,
                              fontSize: 9,
                              letterSpacing: 2.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // FULL NAME
                          _buildFieldLabel('FULL NAME'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration:
                                _inputDecoration('e.g. Dr. Sarah Malik', null),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Name required' : null,
                          ),

                          const SizedBox(height: 18),

                          // OPERATOR ID (email)
                          _buildFieldLabel('OPERATOR ID'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration:
                                _inputDecoration('email@hospital.org', null),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Operator ID required';
                              }
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // ROLE / UNIT
                          _buildFieldLabel('ROLE / UNIT'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            dropdownColor: const Color(0xFF1C2120),
                            iconEnabledColor: _textDim,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: _inputDecoration('Select role', null),
                            items: _roles
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedRole = v),
                            validator: (v) =>
                                v == null ? 'Role required' : null,
                          ),

                          const SizedBox(height: 18),

                          // PASSCODE
                          _buildFieldLabel('PASSCODE'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passcodeController,
                            obscureText: _obscurePasscode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 4),
                            decoration: _inputDecoration(
                              '••••••••',
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
                              if (v.length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // CONFIRM PASSCODE
                          _buildFieldLabel('CONFIRM PASSCODE'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 4),
                            decoration: _inputDecoration(
                              '••••••••',
                              IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _textDim,
                                  size: 18,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm passcode';
                              }
                              if (v != _passcodeController.text) {
                                return 'Passcodes do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // REGISTER button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
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
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : const Text(
                                      'REGISTER OPERATOR',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.2,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already registered? ',
                                style: TextStyle(
                                    color: _textDim, fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.maybePop(context),
                                child: Text(
                                  'Login',
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

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom version tag
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
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

  InputDecoration _inputDecoration(String hint, Widget? suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _textDim, fontSize: 13),
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

// ── Shared hex logo (identical to login screen) ──────────────────────────────

class _WardSyncHexLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 90,
      child: CustomPaint(painter: _HexLogoPainter()),
    );
  }
}

class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.48;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * (3.14159265 / 180);
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      i == 0 ? hexPath.moveTo(x, y) : hexPath.lineTo(x, y);
    }
    hexPath.close();

    canvas.drawPath(
      hexPath,
      Paint()
        ..color = const Color(0xFF8CBF3F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round,
    );

    final crossPaint = Paint()
      ..color = const Color(0xFF8CBF3F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final arm = size.width * 0.22;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), crossPaint);

    final dotColors = [
      const Color(0xFFE05050),
      const Color(0xFFF5C842),
      const Color(0xFF50E070),
    ];
    for (int i = 0; i < 3; i++) {
      final angle = (i * 60 + 90) * (3.14159265 / 180);
      canvas.drawCircle(
        Offset(cx + (r + 5) * _cos(angle), cy + (r + 5) * _sin(angle)),
        4,
        Paint()..color = dotColors[i],
      );
    }
  }

  double _cos(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    double result = 1, term = 1;
    for (int n = 1; n <= 8; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  double _sin(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    double result = x, term = x;
    for (int n = 1; n <= 8; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}