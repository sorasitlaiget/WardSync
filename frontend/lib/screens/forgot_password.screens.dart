import 'package:flutter/material.dart';
import 'login.screens.dart' as login;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg = Color(0xFF0D0F0E);
  static const Color _fieldBg = Color(0xFF1C2120);
  static const Color _border = Color(0xFF2A3230);
  static const Color _green = Color(0xFF8CBF3F);
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
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      ForgotPasswordConfirmationScreen.routeName,
      arguments: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'Forgot Password',
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
                            Text(
                              'Reset your passcode',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter your registered email and we will send a reset link.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _textDim,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 34),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'EMAIL',
                                style: TextStyle(
                                  color: _textDim,
                                  fontSize: 10,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'email@hospital.org',
                                hintStyle: TextStyle(
                                  color: _textDim,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: _fieldBg,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                      color: _border, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                      color: _border, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                      color: _green.withOpacity(0.6),
                                      width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      color: Colors.redAccent, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      color: Colors.redAccent, width: 1.5),
                                ),
                                errorStyle: const TextStyle(
                                    color: Colors.redAccent, fontSize: 11),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 36),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _sendResetLink,
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
                                        'SEND RESET EMAIL',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
}

class ForgotPasswordConfirmationScreen extends StatelessWidget {
  const ForgotPasswordConfirmationScreen({super.key});

  static const routeName = '/forgot-password-confirmation';

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF8A9B93), size: 16),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Reset Sent',
                    style: TextStyle(
                      color: Color(0xFF8A9B93),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 84,
                        color: Color(0xFF8CBF3F),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Password Reset Requested',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        email != null
                            ? 'A reset link will be sent to $email if it is registered with WardSync.'
                            : 'A reset link will be sent to your account if it is registered with WardSync.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8A9B93),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              login.LoginScreen.routeName,
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8CBF3F),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'BACK TO LOGIN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
