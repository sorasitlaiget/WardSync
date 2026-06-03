import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class RoomCapacity {
  final String room;
  final int capacity;
  final int occupied;

  const RoomCapacity({
    required this.room,
    required this.capacity,
    required this.occupied,
  });

  double get occupancyRatio => capacity == 0 ? 0 : occupied / capacity;
  int get free => capacity - occupied;

  factory RoomCapacity.fromJson(Map<String, dynamic> json) => RoomCapacity(
        room: json['room'] as String,
        capacity: (json['maxCapacity'] as num).toInt(),
        occupied: (json['current'] as num?)?.toInt() ?? 0,
      );
}

class RoomRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<RoomCapacity>> getAllRoomCapacity() async {
    try {
      final res = await _dio.get('/api/rooms/capacity');
      return (res.data as List)
          .map((e) => RoomCapacity.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<RoomCapacity> getRoomCapacity(String room) async {
    try {
      final res = await _dio.get('/api/rooms/capacity/$room');
      return RoomCapacity.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> setRoomCapacity(String room, int capacity) async {
    try {
      await _dio.put('/api/rooms/capacity/$room', data: {'capacity': capacity});
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
