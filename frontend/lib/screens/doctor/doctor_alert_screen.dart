import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/wardsync_logo.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/patients/repositories/patient_repository.dart';
import '../../../shared/models/patient.dart';
import '../../../shared/models/user_profile.dart';

enum _AlertType { newPatient, vitalAlert, vitalUpdated }

class _AlertItem {
  final _AlertType type;
  final String patientNumber;
  final String subtitle;
  final DateTime timestamp;
  final TriageColor triageColor;

  const _AlertItem({
    required this.type,
    required this.patientNumber,
    required this.subtitle,
    required this.timestamp,
    required this.triageColor,
  });
}

class DoctorAlertScreen extends StatefulWidget {
  const DoctorAlertScreen({super.key});
  static const routeName = '/doctor-alert';

  @override
  State<DoctorAlertScreen> createState() => _DoctorAlertScreenState();
}

class _DoctorAlertScreenState extends State<DoctorAlertScreen> {
  static const Color _bg      = Color(0xFF0D0F0E);
  static const Color _card    = Color(0xFF161A19);
  static const Color _border  = Color(0xFF2A3230);
  static const Color _green   = Color(0xFF8CBF3F);
  static const Color _red     = Color(0xFFD94040);
  static const Color _textDim = Color(0xFF5A6B65);

  final _authRepo    = AuthRepository();
  final _patientRepo = PatientRepository();

  UserProfile? _profile;
  List<_AlertItem> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _authRepo.getProfile();
      final room = profile.assignedRoom?.name ?? 'red';
      final patients = await _patientRepo.getPatients(room: room);

      final alerts = <_AlertItem>[];

      for (final p in patients) {
        alerts.add(_AlertItem(
          type: _AlertType.newPatient,
          patientNumber: p.wristbandNumber,
          subtitle:
              '${_colorLabel(p.triageColor)} · ${_sexLabel(p.sex)} · ${_ageLabel(p.ageRange)} · ${_timeAgo(p.arrivedAt)}',
          timestamp: p.arrivedAt,
          triageColor: p.triageColor,
        ));

        for (final v in p.vitalSigns) {
          final sys = v.systolic;
          final dia = v.diastolic;
          if ((sys != null && sys < 90) || (dia != null && dia < 60)) {
            alerts.add(_AlertItem(
              type: _AlertType.vitalAlert,
              patientNumber: p.wristbandNumber,
              subtitle:
                  'BP ${sys ?? '?'}/${dia ?? '?'} · below threshold · ${_timeAgo(v.recordedAt)}',
              timestamp: v.recordedAt,
              triageColor: p.triageColor,
            ));
          } else {
            alerts.add(_AlertItem(
              type: _AlertType.vitalUpdated,
              patientNumber: p.wristbandNumber,
              subtitle: 'By ${v.recordedBy} · ${_timeAgo(v.recordedAt)}',
              timestamp: v.recordedAt,
              triageColor: p.triageColor,
            ));
          }
        }
      }

      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (!mounted) return;
      setState(() {
        _profile  = profile;
        _alerts   = alerts;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  String _colorLabel(TriageColor c) {
    switch (c) {
      case TriageColor.red:    return 'Red';
      case TriageColor.yellow: return 'Yellow';
      case TriageColor.green:  return 'Green';
      case TriageColor.black:  return 'Black';
    }
  }

  String _sexLabel(Sex s) => s == Sex.male ? 'Male' : 'Female';

  String _ageLabel(AgeRange a) {
    switch (a) {
      case AgeRange.adult:  return 'Adult';
      case AgeRange.child:  return 'Child';
      case AgeRange.elder:  return 'Senior';
      case AgeRange.infant: return 'Infant';
    }
  }

  Color _triageColor(TriageColor c) {
    switch (c) {
      case TriageColor.red:    return const Color(0xFFD94040);
      case TriageColor.yellow: return const Color(0xFFE8B840);
      case TriageColor.green:  return const Color(0xFF4CAF50);
      case TriageColor.black:  return const Color(0xFF6B7280);
    }
  }

  String get _roomLabel =>
      '${(_profile?.assignedRoom?.name ?? 'red').toUpperCase()} ROOM';

  Color get _roomColor {
    switch (_profile?.assignedRoom) {
      case TriageRoom.yellow: return const Color(0xFFE8B840);
      case TriageRoom.green:  return const Color(0xFF4CAF50);
      case TriageRoom.black:  return const Color(0xFF6B7280);
      default:                return _red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: _alerts.isEmpty
                          ? Center(
                              child: Text('No alerts',
                                  style: TextStyle(
                                      color: _textDim, fontSize: 14)),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              itemCount: _alerts.length,
                              itemBuilder: (_, i) =>
                                  _buildAlertCard(_alerts[i]),
                            ),
                    ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _border, width: 0.5)),
      ),
      child: Row(
        children: [
          const WardSyncLogo(size: 32),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DOCTOR',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5)),
              Text('Dr. ${_profile?.name ?? '...'}',
                  style: TextStyle(
                      color: _textDim, fontSize: 10, letterSpacing: 0.3)),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _roomColor.withAlpha(38),
              border: Border.all(color: _roomColor, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(_roomLabel,
                style: TextStyle(
                    color: _roomColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(_AlertItem item) {
    final Color iconBg;
    final IconData iconData;
    final String label;

    switch (item.type) {
      case _AlertType.newPatient:
        iconBg   = _triageColor(item.triageColor);
        iconData = Icons.add;
        label    = 'New Patient';
      case _AlertType.vitalAlert:
        iconBg   = const Color(0xFFE8B840);
        iconData = Icons.warning_amber_rounded;
        label    = 'Vital Alert';
      case _AlertType.vitalUpdated:
        iconBg   = const Color(0xFF2196F3);
        iconData = Icons.check;
        label    = 'Vital Updated';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 62,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(iconData, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label #${item.patientNumber}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(item.subtitle,
                    style:
                        TextStyle(color: _textDim, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.notifications_outlined, Icons.notifications, 'Alert'),
      (Icons.settings_outlined, Icons.settings, 'Setting'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == 1;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (i == 0) {
                Navigator.pushReplacementNamed(
                    context, '/doctor-home');
                return;
              }
              if (i == 2) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: _card,
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure?',
                        style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text('Logout',
                              style:
                                  TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (_) => false);
                  }
                }
                return;
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(active ? items[i].$2 : items[i].$1,
                      color: active ? _green : _textDim, size: 24),
                  const SizedBox(height: 2),
                  Text(items[i].$3,
                      style: TextStyle(
                          color: active ? _green : _textDim,
                          fontSize: 10)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
