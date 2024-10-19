import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Grafikler için

class EmployeeReportingScreen extends StatelessWidget {
  final List<EmployeeActivity> activities = [
    // Örnek veriler
    EmployeeActivity(employeeName: 'Ali Yılmaz', activityType: 'Satış', activityDate: DateTime.now(), duration: 120),
    EmployeeActivity(employeeName: 'Ayşe Kaya', activityType: 'Toplantı', activityDate: DateTime.now().subtract(const Duration(days: 1)), duration: 60),
    // Daha fazla örnek veri ekleyebilirsiniz
  ];

 EmployeeReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışanlar Raporları'),
      ),
      body: Column(
        children: [
          // Grafikler ve diğer görselleştirmeler için
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PieChart(
                PieChartData(
                  sections: _getPieChartSections(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Çalışan Adı')),
                  DataColumn(label: Text('Etkinlik Türü')),
                  DataColumn(label: Text('Tarih')),
                  DataColumn(label: Text('Süre (dk)')),
                ],
                rows: activities.map((activity) {
                  return DataRow(cells: [
                    DataCell(Text(activity.employeeName)),
                    DataCell(Text(activity.activityType)),
                    DataCell(Text('${activity.activityDate.toLocal()}')),
                    DataCell(Text('${activity.duration}')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    // Burada aktiviteleri kategori bazında hesaplayıp grafiğe dönüştüreceksiniz
    return activities
        .map((activity) => PieChartSectionData(
              color: Colors.blue, // Dinamik renk kullanabilirsiniz
              value: activity.duration.toDouble(),
              title: activity.activityType,
            ))
        .toList();
  }
}

class EmployeeActivity {
  final String employeeName;
  final String activityType;
  final DateTime activityDate;
  final int duration; // in minutes

  EmployeeActivity({
    required this.employeeName,
    required this.activityType,
    required this.activityDate,
    required this.duration,
  });
}