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

  factory ChartStats.fromJson(Map<String, dynamic> json) => ChartStats(
        totalToday: (json['totalToday'] as num?)?.toInt() ?? 0,
        activePatients: (json['activePatients'] as num?)?.toInt() ?? 0,
        byTriageColor: {
          'red': (json['byTriageColor']?['red'] as num?)?.toInt() ?? 0,
          'yellow': (json['byTriageColor']?['yellow'] as num?)?.toInt() ?? 0,
          'green': (json['byTriageColor']?['green'] as num?)?.toInt() ?? 0,
          'black': (json['byTriageColor']?['black'] as num?)?.toInt() ?? 0,
        },
      );
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
