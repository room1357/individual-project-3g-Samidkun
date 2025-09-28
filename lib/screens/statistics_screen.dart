import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;
    final perCat = svc.totalPerCategory;   // Map<String, double>
    final perMonth = svc.totalPerMonth;    // Map<int, double>

    final double maxCat =
        perCat.values.isEmpty ? 0.0 : perCat.values.reduce((a, b) => a > b ? a : b);
    final double maxMonth =
        perMonth.values.isEmpty ? 0.0 : perMonth.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Total Semua: ${rp(svc.totalAll)}',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),

          const Text('Per Kategori', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8.0),

          if (perCat.isEmpty)
            const Text('Tidak ada data')
          else
            ...perCat.entries.map((e) {
              final double ratio = maxCat == 0.0 ? 0.0 : (e.value / maxCat);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(width: 100.0, child: Text(e.key)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: LinearProgressIndicator(
                          value: ratio,      // sudah double
                          minHeight: 14.0,   // << perbaikan: pakai double
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    SizedBox(width: 90.0, child: Text(rp(e.value))),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24.0),
          const Text('Per Bulan', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8.0),

          SizedBox(
            height: 160.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final m = i + 1;
                final double v = (perMonth[m] ?? 0).toDouble();
                final double h = maxMonth == 0.0 ? 0.0 : (v / maxMonth) * 150.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: h,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(_month(m), style: const TextStyle(fontSize: 10.0)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const names = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return names[m - 1];
  }
}
