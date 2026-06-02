import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'wardsync_logo.dart';

enum BadgeVariant { nurse, doctor, redRoom, yellowRoom, greenRoom, admin }

/// Reusable AppBar that matches the WardSync Figma design:
/// Logo (hexagon) + title in Rajdhani Bold + optional role/room badge.
class WardSyncAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BadgeVariant? badge;
  final String? subtitle; // operator name line
  final List<Widget>? extraActions;
  final bool showBack;

  const WardSyncAppBar({
    super.key,
    required this.title,
    this.badge,
    this.subtitle,
    this.extraActions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        subtitle != null ? kToolbarHeight + 22 : kToolbarHeight,
      );

  Color get _badgeBg {
    switch (badge) {
      case BadgeVariant.nurse:
        return const Color(0xFF1E3A1E);
      case BadgeVariant.doctor:
        return const Color(0xFF3A1E1E);
      case BadgeVariant.redRoom:
        return const Color(0xFFCC2200);
      case BadgeVariant.yellowRoom:
        return const Color(0xFF7A5500);
      case BadgeVariant.greenRoom:
        return const Color(0xFF1A5C1A);
      case BadgeVariant.admin:
        return const Color(0xFF1E1E3A);
      default:
        return AppColors.surfaceVariant;
    }
  }

  String get _badgeLabel {
    switch (badge) {
      case BadgeVariant.nurse:
        return 'NURSE';
      case BadgeVariant.doctor:
        return 'DOCTOR';
      case BadgeVariant.redRoom:
        return 'Red Room';
      case BadgeVariant.yellowRoom:
        return 'Yellow Room';
      case BadgeVariant.greenRoom:
        return 'Green Room';
      case BadgeVariant.admin:
        return 'ADMIN';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Row(
        children: [
          const WardSyncLogo(size: 32),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: AppColors.lime,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        if (badge != null)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: badge == BadgeVariant.nurse
                    ? AppColors.lime.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              _badgeLabel,
              style: GoogleFonts.rajdhani(
                color: badge == BadgeVariant.nurse
                    ? AppColors.lime
                    : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        if (extraActions != null) ...extraActions!,
      ],
      bottom: subtitle != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 6),
                  child: Text(
                    subtitle!,
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.cardBorder),
            ),
    );
  }
}
