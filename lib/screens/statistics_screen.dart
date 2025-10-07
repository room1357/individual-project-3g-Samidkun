import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import '../utils/category_style.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;

    final total = svc.totalAll;
    final perCat = svc.totalPerCategory;
    final perMonth = svc.totalPerMonth;

    final maxCat = perCat.values.isEmpty
        ? 0.0
        : perCat.values.reduce((a, b) => a > b ? a : b);
    final maxMonth = perMonth.values.isEmpty
        ? 0.0
        : perMonth.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: AnimatedBuilder(
        animation: svc,
        builder: (_, __) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: _TotalCard(total: total),
                ),
              ),

              if (perCat.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _SectionTitle(
                      icon: Icons.category_rounded,
                      title: 'Per Kategori',
                    ),
                  ),
                ),

              SliverList.builder(
                itemCount: perCat.length,
                itemBuilder: (context, i) {
                  final entry = perCat.entries.elementAt(i);
                  final name = entry.key;
                  final ratio = maxCat == 0 ? 0.0 : entry.value / maxCat;
                  final color = categoryColor(name);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProgressTile(
                      label: name,
                      valueText: rp(entry.value),
                      value: ratio,
                      color: color,
                      leading: _leadingFor(name), // <<— pakai gambar kalau ada
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: _SectionTitle(
                    icon: Icons.bar_chart_rounded,
                    title: 'Trend Bulanan',
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _MonthBarChart(
                  perMonth: perMonth,
                  maxMonth: maxMonth,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  /// Bikin leading untuk setiap baris kategori.
  /// - Kalau kategori punya imageUrl -> tampilkan foto.
  /// - Kalau tidak -> fallback ke ikon + warna.
  Widget _leadingFor(String name) {
    final svc = ExpenseService.instance;
    final cat = svc.findCategoryByName(name);
    final color = categoryColor(name);

    final imageUrl = cat?.imageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        categoryIcon(name),
        color: color,
        size: 20,
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Total Semua Pengeluaran',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 30),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rp(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          )
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        const SizedBox(width: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.label,
    required this.valueText,
    required this.value,
    required this.color,
    required this.leading,
  });

  final String label;
  final String valueText;
  final double value;
  final Color color;
  final Widget leading; // <<— bisa gambar atau icon

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valueText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: color.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withOpacity(0.1),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBarChart extends StatelessWidget {
  const _MonthBarChart({required this.perMonth, required this.maxMonth});

  final Map<int, double> perMonth;
  final double maxMonth;

  String _getShortenedAmount(double v) {
    if (v >= 1000000) return 'Rp${(v / 1000000).toStringAsFixed(1)}Jt';
    if (v >= 1000) return 'Rp${(v / 1000).toStringAsFixed(0)}K';
    return rp(v);
  }

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (i) => i + 1);
    const barMaxHeight = 180.0;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (maxMonth > 0)
            Positioned.fill(
              bottom: 40,
              child: CustomPaint(painter: _GridPainter(barMaxHeight)),
            ),
          if (maxMonth > 0)
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                _getShortenedAmount(maxMonth),
                style: TextStyle(
                  color: primaryColor.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(
            height: barMaxHeight + 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: months.map((m) {
                final v = perMonth[m] ?? 0.0;
                final h = maxMonth == 0 ? 0.0 : (v / maxMonth) * barMaxHeight;
                final isMax = v == maxMonth && maxMonth > 0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (v > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            _getShortenedAmount(v),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isMax ? primaryColor : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      Tooltip(
                        message: '${_month(m)}: ${rp(v)}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          height: h,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isMax
                                ? primaryColor
                                : primaryColor.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            boxShadow: [
                              if (h > 0)
                                BoxShadow(
                                  color: primaryColor.withOpacity(.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _month(m),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight:
                              isMax ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[m - 1];
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.height);
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, height), Offset(size.width, height), paint);
    canvas.drawLine(Offset(0, height * 0.75), Offset(size.width, height * 0.75), paint);
    canvas.drawLine(Offset(0, height * 0.5), Offset(size.width, height * 0.5), paint);
    canvas.drawLine(Offset(0, height * 0.25), Offset(size.width, height * 0.25), paint);

    paint
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
