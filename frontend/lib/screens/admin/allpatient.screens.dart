import 'package:flutter/material.dart';
import '../../widgets/wardsync_logo.dart';
import '../../../../features/patients/repositories/patient_repository.dart';
import '../../../../shared/models/patient.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
import '../../../../features/auth/repositories/auth_repository.dart';

class AllPatientsScreen extends StatefulWidget {
  const AllPatientsScreen({super.key});
  static const routeName = '/admin-patients';

  @override
  State<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen> {
  int _navIndex = 3;
  String _searchQuery = '';
  String? _filterRole; // null = ALL

  static const Color _bg      = Color(0xFF0D0F0E);
  static const Color _card    = Color(0xFF161A19);
  static const Color _border  = Color(0xFF2A3230);
  static const Color _green   = Color(0xFF8CBF3F);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);
  static const Color _fieldBg = Color(0xFF1C2120);

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  final _authRepo = AuthRepository();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text));
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _authRepo.getUsers();
      if (!mounted) return;
      setState(() { _users = users; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Load failed: $e'),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _users.where((u) {
      final name = ((u['displayName'] ?? u['name'] ?? u['email'] ?? '') as String).toLowerCase();
      final email = ((u['email'] ?? '') as String).toLowerCase();
      final role = (u['role'] ?? '') as String;
      final matchSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
      final matchRole = _filterRole == null || role == _filterRole;
      return matchSearch && matchRole;
    }).toList();
  }

  int _countByRole(String role) => _users.where((u) => u['role'] == role).length;

  Color _roleColor(String role) {
    switch (role) {
      case 'doctor': return const Color(0xFF4A9EFF);
      case 'admin':  return _green;
      case 'nurse':  return const Color(0xFFE87DBF);
      default:       return _textMid;
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
            _buildPageTitle(),
            _buildTopBar(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _filtered.isEmpty
                  ? Center(child: Text('No accounts found.',
                      style: TextStyle(color: _textDim, fontSize: 13)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _buildUserCard(_filtered[i]),
                    ),
            ),
            _buildAddAccountButton(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text('ALL USERS',
          style: TextStyle(color: _textMid, fontSize: 13,
              fontWeight: FontWeight.w600, letterSpacing: 2.0)),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          const WardSyncLogo(size: 32),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('USERS', style: TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800, letterSpacing: 2.0)),
              Text('TOTAL ${_users.length} ACCOUNTS',
                  style: TextStyle(color: _textDim, fontSize: 10, letterSpacing: 0.5)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green.withAlpha(38),
              border: Border.all(color: _green, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('ADMIN', style: TextStyle(color: _green, fontSize: 10,
                fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          hintStyle: TextStyle(color: _textDim, fontSize: 12),
          prefixIcon: Icon(Icons.search, color: _textDim, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = [
      (null, 'ALL • ${_users.length}'),
      ('nurse', 'NURSE • ${_countByRole('nurse')}'),
      ('doctor', 'DOCTOR • ${_countByRole('doctor')}'),
      ('admin', 'ADMIN • ${_countByRole('admin')}'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) {
          final active = _filterRole == c.$1;
          return GestureDetector(
            onTap: () => setState(() => _filterRole = c.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: active ? _green : _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _green : _border),
              ),
              child: Text(c.$2,
                  style: TextStyle(
                      color: active ? Colors.black : _textMid,
                      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> u) {
    final role  = (u['role'] ?? 'nurse') as String;
    final name  = (u['displayName'] ?? u['name'] ?? 'Unknown') as String;
    final email = (u['email'] ?? '') as String;
    final room  = u['assignedRoom'] as String?;
    final color = _roleColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(30), shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(80)),
            ),
            child: Icon(Icons.person_outline, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white,
                    fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: _textDim, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withAlpha(80)),
                ),
                child: Text(role.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 9,
                        fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              ),
              if (room != null) ...[
                const SizedBox(height: 4),
                Text(room.toUpperCase(),
                    style: TextStyle(color: _textDim, fontSize: 10, letterSpacing: 0.8)),
              ],
            ],
          ),
        ],
      ),
    );
  }


  void _showAddAccountDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    String selectedRole = 'nurse';
    String selectedRoom = 'red';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), side: BorderSide(color: _border)),
          title: const Text('ADD ACCOUNT',
              style: TextStyle(color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(emailCtrl, 'Email'),
                const SizedBox(height: 10),
                _dialogField(passCtrl, 'Password', obscure: true),
                const SizedBox(height: 14),
                _dialogDropdown<String>(
                  label: 'Role',
                  value: selectedRole,
                  items: const ['nurse', 'doctor', 'admin'],
                  itemLabel: (r) => r[0].toUpperCase() + r.substring(1),
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
                if (selectedRole != 'nurse') ...[
                  const SizedBox(height: 10),
                  _dialogDropdown<String>(
                    label: 'Assigned Room',
                    value: selectedRoom,
                    items: const ['red', 'yellow', 'green', 'black'],
                    itemLabel: (r) => r[0].toUpperCase() + r.substring(1),
                    onChanged: (v) => setDialogState(() => selectedRoom = v!),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: TextStyle(color: _textDim, fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.black),
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final pass  = passCtrl.text.trim();
                if (email.isEmpty || pass.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await _authRepo.createAccount(
                    email: email, password: pass, displayName: '',
                    role: selectedRole,
                    assignedRoom: selectedRole != 'nurse' ? selectedRoom : null,
                  );
                  await _loadUsers();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: _green,
                      content: Text('Account created: $email',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString().replaceFirst('Exception: ', '')),
                      backgroundColor: Colors.redAccent,
                    ));
                  }
                }
              },
              child: const Text('CREATE', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textDim, fontSize: 12),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _green, width: 1.5)),
      ),
    );
  }

  Widget _dialogDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _textDim, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _fieldBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: _card,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: items.map((i) => DropdownMenuItem(
                value: i,
                child: Text(itemLabel(i)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddAccountButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _showAddAccountDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green, foregroundColor: Colors.black, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.person_add, size: 20),
          label: const Text('ADD ACCOUNT',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2.2)),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final outlined = [Icons.home_outlined, Icons.person_outline, Icons.work_outline, Icons.settings_outlined];
    final filled   = [Icons.home,          Icons.person,         Icons.work,          Icons.settings];
    const labels   = ['Home', 'Patient', 'Inventory', 'Room Config'];
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (i) {
          final active = _navIndex == i;
          return GestureDetector(
            onTap: () {
              switch (i) {
                case 0: Navigator.pushReplacementNamed(context, '/admin-home'); break;
                case 1: Navigator.pushReplacementNamed(context, '/admin-inventory'); break;
                case 2: Navigator.pushReplacementNamed(context, '/admin-roomconfig'); break;
                case 3: break;
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(active ? filled[i] : outlined[i],
                      color: active ? _green : _textDim, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: TextStyle(color: active ? _green : _textDim, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


