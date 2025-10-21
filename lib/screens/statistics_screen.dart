import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/category_style.dart';
import '../utils/currency_utils.dart';
import 'dart:math';

// Enum sekarang hanya punya 2 pilihan
enum ChartView { bulanan, tahunan }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  ChartView _selectedView = ChartView.bulanan;

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Statistik Pengeluaran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: svc,
        builder: (context, _) {
          final allExpenses = svc.expenses;
          final totalExpense = svc.totalAll;

          final highestExpenses = List.of(allExpenses);
          highestExpenses.sort((a, b) => b.amount.compareTo(a.amount));

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 20),
              _buildTotalCard(totalExpense),
              const SizedBox(height: 30),
              _buildFilterButtons(),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: _buildChart(svc),
              ),
              const SizedBox(height: 40),
              const Text('Pengeluaran Tertinggi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (highestExpenses.isEmpty)
                const Center(child: Text('Belum ada data.'))
              else
                ListView.builder(
                  itemCount: highestExpenses.take(5).length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final expense = highestExpenses[index];
                    return _buildExpenseListItem(expense);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFilterChip('Bulanan', ChartView.bulanan),
        const SizedBox(width: 12),
        _buildFilterChip('Tahunan', ChartView.tahunan),
      ],
    );
  }

  Widget _buildFilterChip(String label, ChartView view) {
    final bool isSelected = _selectedView == view;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedView = view);
      },
      selectedColor: Colors.pinkAccent.withOpacity(0.1),
      labelStyle: TextStyle(color: isSelected ? Colors.pinkAccent : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.pinkAccent : Colors.grey.shade300),
      ),
      backgroundColor: Colors.white,
    );
  }

  // [DIUBAH] Switch sekarang ditambahkan 'default'
  Widget _buildChart(ExpenseService svc) {
    switch (_selectedView) {
      case ChartView.bulanan:
        final data = svc.totalPerMonth;
        final spots = List.generate(12, (i) => FlSpot((i + 1).toDouble(), data[i + 1] ?? 0));
        return LineChart(_buildChartData(spots, data.values, _bottomTitlesMonthly));
        
      case ChartView.tahunan:
        final data = svc.totalPerYear;
        if (data.keys.isEmpty) return const Center(child: Text('Tidak ada data tahunan.'));
        
        final sortedYears = data.keys.toList()..sort();
        final minYear = sortedYears.first;
        final maxYear = sortedYears.last;

        final spots = <FlSpot>[];
        for (int year = minYear; year <= maxYear; year++) {
          spots.add(FlSpot(year.toDouble(), data[year] ?? 0));
        }
        return LineChart(_buildChartData(spots, data.values, _bottomTitlesYearly));
    }
  }

  // [DILENGKAPI] Bagian dalam LineChartBarData ditambahkan
  LineChartData _buildChartData(List<FlSpot> spots, Iterable<double> values, SideTitles bottomTitles) {
    final chartColor = Colors.pinkAccent;
    double maxY = 0;
    if (values.isNotEmpty) maxY = values.reduce(max);
    maxY = maxY == 0 ? 1000 : maxY * 1.2;

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: bottomTitles),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: chartColor,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [chartColor.withOpacity(0.5), chartColor.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  SideTitles get _bottomTitlesMonthly => SideTitles(
    showTitles: true,
    reservedSize: 30,
    interval: 1,
    getTitlesWidget: (value, meta) {
      const style = TextStyle(color: Colors.grey, fontSize: 12);
      String text = '';
      switch (value.toInt()) {
        case 1: text = 'Jan'; break; case 2: text = 'Feb'; break;
        case 3: text = 'Mar'; break; case 4: text = 'Apr'; break;
        case 5: text = 'Mei'; break; case 6: text = 'Jun'; break;
        case 7: text = 'Jul'; break; case 8: text = 'Agu'; break;
        case 9: text = 'Sep'; break; case 10: text = 'Okt'; break;
        case 11: text = 'Nov'; break; case 12: text = 'Des'; break;
        default: text = ''; break;
      }
      return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
    },
  );
  
  SideTitles get _bottomTitlesYearly => SideTitles(
    showTitles: true,
    reservedSize: 30,
    interval: 1,
    getTitlesWidget: (value, meta) {
      const style = TextStyle(color: Colors.grey, fontSize: 12);
      return SideTitleWidget(axisSide: meta.axisSide, child: Text(value.toInt().toString().substring(2), style: style));
    },
  );

  // [DILENGKAPI] Widget-widget helper ditambahkan kembali
  Widget _buildTotalCard(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Semua Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                rp(total, context),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wallet, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseListItem(Expense expense) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          categoryAvatar(expense.category, size: 45),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(expense.formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text('- ${rp(expense.amount, context)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }
}