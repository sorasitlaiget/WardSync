import 'package:flutter/material.dart';

void main() {
  runApp(const WardSyncApp());
}

class WardSyncApp extends StatelessWidget {
  const WardSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WardSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const InventoryScreen(),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

enum StockStatus { inStock, lowStock, critical }

class Medication {
  final String name;
  final String detail;
  final int quantity;
  final StockStatus status;

  const Medication({
    required this.name,
    required this.detail,
    required this.quantity,
    required this.status,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  static const routeName = '/admin-inventory';

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg      = Color(0xFF0D0F0E);
  static const Color _card    = Color(0xFF161A19);
  static const Color _border  = Color(0xFF2A3230);
  static const Color _green   = Color(0xFF8CBF3F);
  static const Color _red     = Color(0xFFD94040);
  static const Color _yellow  = Color(0xFFE8B840);
  static const Color _textDim = Color(0xFF5A6B65);
  static const Color _textMid = Color(0xFF8A9B93);
  static const Color _fieldBg = Color(0xFF1C2120);

  final List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Medication> get _filtered => _medications
      .where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  List<Medication> get _lowItems =>
      _medications.where((m) => m.status != StockStatus.inStock).toList();

  int get _totalCount => _medications.length;
  int get _lowCount   => _lowItems.length;

  Color _statusColor(StockStatus s) {
    switch (s) {
      case StockStatus.inStock:  return const Color(0xFF8CBF3F);
      case StockStatus.lowStock: return const Color(0xFFE8B840);
      case StockStatus.critical: return const Color(0xFFD94040);
    }
  }

  String _statusLabel(StockStatus s) {
    switch (s) {
      case StockStatus.inStock:  return 'IN STOCK';
      case StockStatus.lowStock: return 'LOW STOCK';
      case StockStatus.critical: return 'CRITICAL';
    }
  }

  StockStatus _statusForQuantity(int quantity) {
    if (quantity <= 0) return StockStatus.critical;
    if (quantity <= 10) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  Color _cardBorderColor(StockStatus s) {
    switch (s) {
      case StockStatus.inStock:  return _border;
      case StockStatus.lowStock: return _yellow.withOpacity(0.35);
      case StockStatus.critical: return _red.withOpacity(0.45);
    }
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
              const SizedBox(height: 16),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_lowItems.isNotEmpty) ...[
                          _buildLowStockBanner(),
                          const SizedBox(height: 12),
                        ],
                        _buildSearchBar(),
                        const SizedBox(height: 14),
                        if (_filtered.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _border, width: 1),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, color: _textDim, size: 40),
                                const SizedBox(height: 12),
                                Text('No medication yet',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text('Tap ADD MEDICATION to create inventory items.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: _textDim, fontSize: 12)),
                              ],
                            ),
                          )
                        else ..._filtered.map(_buildMedCard),
                        const SizedBox(height: 8),
                        _buildAddButton(),
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
      child: Text('Inventory',
          style: TextStyle(color: _textMid, fontSize: 13,
              fontWeight: FontWeight.w500, letterSpacing: 0.5)),
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
          SizedBox(width: 32, height: 36, child: CustomPaint(painter: _HexLogoPainter())),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INVENTORY',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, letterSpacing: 2.0)),
              Text('$_totalCount MEDICATION : $_lowCount LOW',
                  style: TextStyle(color: _textDim, fontSize: 10, letterSpacing: 0.4)),
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

  // ── Low stock banner ──────────────────────────────────────────────────────

  Widget _buildLowStockBanner() {
    final names = _lowItems.map((m) => m.name).join(', ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _yellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _yellow.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _yellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.warning_amber_rounded, color: _yellow, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_lowItems.length} ITEMS LOW STOCK',
                    style: TextStyle(color: _yellow, fontSize: 12,
                        fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(names,
                    style: TextStyle(color: _textDim, fontSize: 10),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search medication...',
        hintStyle: TextStyle(color: _textDim, fontSize: 12),
        prefixIcon: Icon(Icons.search, color: _textDim, size: 18),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _border, width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _border, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _green.withOpacity(0.5), width: 1.5)),
      ),
    );
  }

  // ── Medication card ───────────────────────────────────────────────────────

  Widget _buildMedCard(Medication m) {
    final color = _statusColor(m.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorderColor(m.status), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(m.detail,
                    style: TextStyle(color: _textDim, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${m.quantity}',
                  style: TextStyle(color: color, fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(_statusLabel(m.status),
                  style: TextStyle(color: color, fontSize: 9,
                      fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Add medication button ─────────────────────────────────────────────────

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _showAddMedicationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('ADD MEDICATION',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2.2)),
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final detailController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'ADD MEDICATION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Medication Name',
                  hintStyle: TextStyle(color: _textDim, fontSize: 13),
                  filled: true,
                  fillColor: _fieldBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    borderSide: BorderSide(color: _green, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Detail / Dosage',
                  hintStyle: TextStyle(color: _textDim, fontSize: 13),
                  filled: true,
                  fillColor: _fieldBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    borderSide: BorderSide(color: _green, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  hintStyle: TextStyle(color: _textDim, fontSize: 13),
                  filled: true,
                  fillColor: _fieldBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    borderSide: BorderSide(color: _green, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: _textDim, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final detail = detailController.text.trim();
              final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

              if (name.isNotEmpty && detail.isNotEmpty && quantityController.text.isNotEmpty) {
                setState(() {
                  _medications.add(Medication(
                    name: name,
                    detail: detail,
                    quantity: quantity,
                    status: _statusForQuantity(quantity),
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _green,
                    content: Text(
                      'Added: $name',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'ADD',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final outlined = [Icons.home_outlined, Icons.person_outline, Icons.work_outline, Icons.settings_outlined];
    final filled   = [Icons.home,          Icons.person,         Icons.work,          Icons.settings];
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
                case 1: Navigator.pushReplacementNamed(context, '/admin-patients'); break;
                case 2: break; // Already here
                case 3: Navigator.pushReplacementNamed(context, '/admin-roomconfig'); break;
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Icon(active ? filled[i] : outlined[i],
                  color: active ? _green : _textDim, size: 24),
            ),
          );
        }),
      ),
    );
  }
}

// ── Shared hex logo painter ───────────────────────────────────────────────────

class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width * 0.48;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 30) * (3.14159265 / 180);
      final x = cx + r * _cos(a), y = cy + r * _sin(a);
      i == 0 ? hexPath.moveTo(x, y) : hexPath.lineTo(x, y);
    }
    hexPath.close();
    canvas.drawPath(hexPath, Paint()
      ..color = const Color(0xFF8CBF3F)..style = PaintingStyle.stroke
      ..strokeWidth = 2.5..strokeJoin = StrokeJoin.round);
    final arm = size.width * 0.22;
    final cp = Paint()..color = const Color(0xFF8CBF3F)..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), cp);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), cp);
    final dots = [const Color(0xFFE05050), const Color(0xFFF5C842), const Color(0xFF50E070)];
    for (int i = 0; i < 3; i++) {
      final a = (i * 60 + 90) * (3.14159265 / 180);
      canvas.drawCircle(Offset(cx + (r + 4) * _cos(a), cy + (r + 4) * _sin(a)), 3, Paint()..color = dots[i]);
    }
  }

  double _cos(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi; while (x < -pi) x += 2 * pi;
    double r = 1, t = 1;
    for (int n = 1; n <= 8; n++) { t *= -x * x / ((2*n-1)*(2*n)); r += t; }
    return r;
  }

  double _sin(double x) {
    const pi = 3.14159265358979;
    while (x > pi) x -= 2 * pi; while (x < -pi) x += 2 * pi;
    double r = x, t = x;
    for (int n = 1; n <= 8; n++) { t *= -x * x / ((2*n)*(2*n+1)); r += t; }
    return r;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}