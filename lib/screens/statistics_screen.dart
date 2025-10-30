import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../utils/category_style.dart';
import '../utils/currency_utils.dart';

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
    final expSvc = ExpenseService.instance;
    final incSvc = IncomeService.instance;

   return Scaffold(
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFCBF1FF), // biru muda
          Color(0xFFD9CFFF), // ungu muda
        ],
      ),
    ),
    child: SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black,
            centerTitle: true,
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([expSvc, incSvc]),
              builder: (context, _) {
                final allExpenses = expSvc.expenses;
                final totalExpense = expSvc.totalAll;
                final highestExpenses = List.of(allExpenses)
                  ..sort((a, b) => b.amount.compareTo(a.amount));

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 20),
                    _buildTotalExpenseCard(totalExpense),
                    const SizedBox(height: 24),
                    _buildFilterButtons(),
                    const SizedBox(height: 10),
                    SizedBox(height: 260, child: _buildChartCard(expSvc, incSvc)),
                    const SizedBox(height: 28),
                    const Text(
                      'Highest Expenses',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (highestExpenses.isEmpty)
                      const Center(child: Text('No data yet.'))
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
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
);

  }

  // ---------------- UI kecil ----------------

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _filterChip('Monthly', ChartView.bulanan),
        const SizedBox(width: 12),
        _filterChip('Yearly', ChartView.tahunan),
      ],
    );
  }

  Widget _filterChip(String label, ChartView view) {
    final bool isSelected = _selectedView == view;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (sel) {
        if (sel) setState(() => _selectedView = view);
      },
      selectedColor: Colors.pinkAccent.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.pinkAccent : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.pinkAccent : Colors.grey.shade300,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // ---------------- Chart Card + Legend ----------------

  Widget _buildChartCard(ExpenseService expSvc, IncomeService incSvc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: _buildChart(expSvc, incSvc)),
          Positioned(
            right: 8,
            top: 6,
            child: _legendInline(),
          ),
        ],
      ),
    );
  }

  Widget _legendInline() {
    Widget item(Color c, String t) => Row(
          children: [
            Container(
              width: 14,
              height: 3,
              decoration:
                  BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 6),
            Text(t, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(Colors.blue, 'Income'),
        const SizedBox(width: 12),
        item(Colors.orange, 'Expenses'),
      ],
    );
  }

  // ---------------- Chart core ----------------

  Widget _buildChart(ExpenseService expSvc, IncomeService incSvc) {
    switch (_selectedView) {
      case ChartView.bulanan:
        final expMap = expSvc.totalPerMonth; // {1..12 -> double}
        final incMap = incSvc.totalPerMonth;

        final expSpots = List.generate(
            12, (i) => FlSpot((i + 1).toDouble(), expMap[i + 1] ?? 0));
        final incSpots = List.generate(
            12, (i) => FlSpot((i + 1).toDouble(), incMap[i + 1] ?? 0));

        final allValues = [...expMap.values, ...incMap.values];

        return LineChart(_buildChartDataTwoLines(
          incSpots: incSpots,
          expSpots: expSpots,
          allValues: allValues,
          bottomTitles: _bottomTitlesMonthlyRotated,
        ));

      case ChartView.tahunan:
        final expMapY = expSvc.totalPerYear; // {year -> double}
        final incMapY = incSvc.totalPerYear;

        if (expMapY.isEmpty && incMapY.isEmpty) {
          return const Center(child: Text('No annual data available.'));
        }

        final years = <int>{...expMapY.keys, ...incMapY.keys}.toList()..sort();
        final minYear = years.first;
        final maxYear = years.last;

        final expSpots = <FlSpot>[];
        final incSpots = <FlSpot>[];
        for (int y = minYear; y <= maxYear; y++) {
          expSpots.add(FlSpot(y.toDouble(), expMapY[y] ?? 0));
          incSpots.add(FlSpot(y.toDouble(), incMapY[y] ?? 0));
        }

        final allValues = [...expMapY.values, ...incMapY.values];

        return LineChart(_buildChartDataTwoLines(
          incSpots: incSpots,
          expSpots: expSpots,
          allValues: allValues,
          bottomTitles: _bottomTitlesYearly,
        ));
    }
  }

  LineChartData _buildChartDataTwoLines({
    required List<FlSpot> incSpots,
    required List<FlSpot> expSpots,
    required Iterable<double> allValues,
    required SideTitles bottomTitles,
  }) {
    const incomeColor = Colors.blue;
    const expenseColor = Colors.orange;

    double maxY = 0;
    if (allValues.isNotEmpty) {
      maxY = allValues.reduce(max);
    }
    maxY = maxY == 0 ? 1000 : maxY * 1.2;
    final interval = maxY / 4; // 4 grid horizontal

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval == 0 ? 1 : interval,
        getDrawingHorizontalLine: (v) => FlLine(
          color: Colors.black12.withOpacity(0.15),
          strokeWidth: 1,
        ),
      ),
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
          spots: incSpots,
          isCurved: true,
          color: incomeColor,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [incomeColor.withOpacity(0.25), incomeColor.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        LineChartBarData(
          spots: expSpots,
          isCurved: true,
          color: expenseColor,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [expenseColor.withOpacity(0.25), expenseColor.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Axis titles ----------------

  SideTitles get _bottomTitlesMonthlyRotated => SideTitles(
        showTitles: true,
        reservedSize: 48, // ruang ekstra karena dimiringkan
        interval: 1,
        getTitlesWidget: (value, meta) {
          const months = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
          ];
          final i = value.toInt();
          if (i < 1 || i > 12) return const SizedBox.shrink();
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 10,
            child: Transform.rotate(
              angle: -0.75, // ~ -43°
              child: Text(
                months[i - 1],
                style: const TextStyle(color: Colors.black54, fontSize: 10),
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
          );
        },
      );

  SideTitles get _bottomTitlesYearly => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: (value, meta) {
          const style = TextStyle(color: Colors.grey, fontSize: 12);
          final yr = value.toInt();
          final txt =
              yr.toString().length >= 4 ? yr.toString().substring(2) : yr.toString();
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(txt, style: style),
          );
        },
      );

  // ---------------- Card & list item ----------------

  Widget _buildTotalExpenseCard(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
       color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total All Expenses',
                  style: TextStyle(color: Color.fromARGB(255, 2, 2, 2), fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                rp(total, context),
                style: const TextStyle(
                    color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
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
                Text(expense.formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text('- ${rp(expense.amount, context)}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }
}
