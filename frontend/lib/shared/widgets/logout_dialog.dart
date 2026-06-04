import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> showLogoutDialog(BuildContext context) async {
  const _card   = Color(0xFF161A19);
  const _border = Color(0xFF2A3230);
  const _red    = Color(0xFFD94040);
  const _textMid = Color(0xFF8A9B93);
  const _textDim = Color(0xFF5A6B65);

  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _red.withAlpha(80)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _red.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: _red.withAlpha(80)),
              ),
              child: const Icon(Icons.logout, color: _red, size: 24),
            ),
            const SizedBox(height: 16),
            const Text('LOGOUT', style: TextStyle(color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w800, letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text('Are you sure you want to sign out?',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textDim, fontSize: 12)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(ctx, false),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2120),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border),
                  ),
                  alignment: Alignment.center,
                  child: const Text('CANCEL', style: TextStyle(color: _textMid,
                      fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(ctx, true),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _red.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _red),
                  ),
                  alignment: Alignment.center,
                  child: const Text('LOGOUT', style: TextStyle(color: _red,
                      fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              )),
            ]),
          ],
        ),
      ),
    ),
  );

  if (confirm == true) {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }
}
