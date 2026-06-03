import 'package:flutter/material.dart';
import '../../widgets/wardsync_logo.dart';
import '../../../../features/rooms/repositories/room_repository.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class RoomConfigScreen extends StatefulWidget {
  const RoomConfigScreen({super.key});

  static const routeName = '/admin-roomconfig';

  @override
  State<RoomConfigScreen> createState() => _RoomConfigScreenState();
}

class _RoomConfigScreenState extends State<RoomConfigScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 2;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg      = Color(0xFF0D0F0E);
  static const Color _card    = Color(0xFF161A19);
  static const Color _border  = Color(0xFF2A3230);
  static const Color _green   = Color(0xFF8CBF3F);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);
  static const Color _fieldBg = Color(0xFF1C2120);

  List<RoomCapacity> _rooms = [];
  bool _isLoading = true;
  final _repo = RoomRepository();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await _repo.getAllRoomCapacity();
      if (!mounted) return;
      for (final r in rooms) {
        _controllers[r.room] = TextEditingController(text: '${r.capacity}');
      }
      setState(() { _rooms = rooms; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _onCapacityChanged(String room, String value) async {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) return;
    try {
      await _repo.setRoomCapacity(room, parsed);
      await _loadRooms();
    } catch (_) {}
  }

  Color _roomColor(String room) {
    switch (room) {
      case 'red':    return const Color(0xFFD94040);
      case 'yellow': return const Color(0xFFE8B840);
      case 'green':  return const Color(0xFF4CAF50);
      case 'black':  return const Color(0xFF6B7280);
      default:       return const Color(0xFF8CBF3F);
    }
  }

  // สีตาม occupancy threshold: ปกติ = room color, 80%+ = เหลือง, 95%+ = แดง
  Color _occupancyColor(double ratio, String room) {
    if (ratio >= 0.95) return const Color(0xFFD94040);
    if (ratio >= 0.80) return const Color(0xFFE8B840);
    return _roomColor(room);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              _buildTopBar(),
              const SizedBox(height: 4),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      children: [
                        if (_rooms.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No rooms yet. Tap ADD ROOM to add one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _textDim, fontSize: 13),
                              ),
                            ),
                          ),
                        if (_isLoading)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ))
                        else
                          ..._rooms.map(_buildRoomCard),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page title ────────────────────────────────────────────────────────────

  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text('ROOM CONFIG',
          style: TextStyle(color: _textMid, fontSize: 13,
              fontWeight: FontWeight.w600, letterSpacing: 2.0)),
    );
  }

  // ── Header card ───────────────────────────────────────────────────────────

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
              Text('ROOM CONFIG',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, letterSpacing: 2.0)),
              Text('SET CAPACITY PER ROOM',
                  style: TextStyle(color: _textDim, fontSize: 10, letterSpacing: 0.5)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.15),
              border: Border.all(color: _green, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('ADMIN',
                style: TextStyle(color: _green, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  // ── Room card ─────────────────────────────────────────────────────────────

  Widget _buildRoomCard(RoomCapacity room) {
    final color = _roomColor(room.room);
    final occupancyColor = _occupancyColor(room.occupancyRatio, room.room);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with left accent
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 14, 10),
            child: Row(
              children: [
                // Left color accent bar
                Container(
                  width: 4,
                  height: 22,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
                Text(room.room.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 15,
                        fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const Spacer(),
                Text('${(room.occupancyRatio * 100).round()} % FULL',
                    style: TextStyle(color: occupancyColor, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ],
            ),
          ),

          // Capacity input
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAPACITY (BEDS)',
                    style: TextStyle(color: _textDim, fontSize: 9,
                        letterSpacing: 1.8, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _controllers[room.room],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700),
                  onSubmitted: (v) => _onCapacityChanged(room.room, v),
                  onEditingComplete: () {
                    final v = _controllers[room.room]?.text ?? '';
                    _onCapacityChanged(room.room, v);
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _fieldBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: color.withOpacity(0.6), width: 1.5)),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: room.occupancyRatio,
                minHeight: 6,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
              ),
            ),
          ),

          // Occupied label
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Text('${room.occupied} OCCUPIED',
                style: TextStyle(color: _textDim, fontSize: 9,
                    letterSpacing: 1.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }


  // ── Bottom nav ────────────────────────────────────────────────────────────

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
                case 2: break;
                case 3: Navigator.pushReplacementNamed(context, '/admin-patients'); break;
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

