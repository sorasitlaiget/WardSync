import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class ChartStats {
  final int totalToday;
  final int activePatients;
  final Map<String, int> byTriageColor;

  const ChartStats({
    required this.totalToday,
    required this.activePatients,
    required this.byTriageColor,
  });

  factory ChartStats.fromJson(Map<String, dynamic> json) {
    // backend returns patientsPerDay: [{date, count}] — last entry = today
    final perDay = (json['patientsPerDay'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final todayStr = DateTime.now().toUtc().toIso8601String().split('T')[0];
    final todayEntry = perDay.where((d) => d['date'] == todayStr).toList();
    final totalToday = todayEntry.isNotEmpty
        ? (todayEntry.first['count'] as num?)?.toInt() ?? 0
        : (perDay.isNotEmpty ? (perDay.last['count'] as num?)?.toInt() ?? 0 : 0);

    // active = total minus deceased (approximation from byColor total)
    // backend doesn't return activePatients directly — use totalToday
    final byColor = (json['byColor'] as Map<String, dynamic>?) ?? {};

    return ChartStats(
      totalToday: totalToday,
      activePatients: totalToday, // refined below if needed
      byTriageColor: {
        'red':    (byColor['red']    as num?)?.toInt() ?? 0,
        'yellow': (byColor['yellow'] as num?)?.toInt() ?? 0,
        'green':  (byColor['green']  as num?)?.toInt() ?? 0,
        'black':  (byColor['black']  as num?)?.toInt() ?? 0,
      },
    );
  }
}

class StatsRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<ChartStats> getChartStats() async {
    try {
      final res = await _dio.get('/api/stats/charts');
      return ChartStats.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
