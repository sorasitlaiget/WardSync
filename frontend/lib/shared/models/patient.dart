import 'enums.dart';

export 'enums.dart' show TriageColor, PatientStatus, Sex, AgeRange, TriageRoom;

class VitalSigns {
  final String id;
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final double? temperature;
  final int? spo2;
  final DateTime recordedAt;
  final String recordedBy;

  const VitalSigns({
    required this.id,
    this.systolic,
    this.diastolic,
    this.pulse,
    this.temperature,
    this.spo2,
    required this.recordedAt,
    required this.recordedBy,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) => VitalSigns(
        id: json['id'] as String,
        systolic: json['systolic'] as int?,
        diastolic: json['diastolic'] as int?,
        pulse: json['pulse'] as int?,
        temperature: (json['temperature'] as num?)?.toDouble(),
        spo2: json['spo2'] as int?,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        recordedBy: json['recordedBy'] as String,
      );
}

class Treatment {
  final String id;
  final String? diagnosis;
  final String? medication;
  final String? dosage;
  final DateTime recordedAt;
  final String doctorName;

  const Treatment({
    required this.id,
    this.diagnosis,
    this.medication,
    this.dosage,
    required this.recordedAt,
    required this.doctorName,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) => Treatment(
        id: json['id'] as String,
        diagnosis: json['diagnosis'] as String?,
        medication: json['medication'] as String?,
        dosage: json['dosage'] as String?,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        doctorName: json['doctorName'] as String,
      );
}

class Patient {
  final String id;
  final String wristbandNumber;
  final String? photoUrl;
  final Sex sex;
  final AgeRange ageRange;
  final TriageColor triageColor;
  final PatientStatus status;
  final TriageRoom room;
  final DateTime arrivedAt;
  final List<VitalSigns> vitalSigns;
  final List<Treatment> treatments;

  const Patient({
    required this.id,
    required this.wristbandNumber,
    this.photoUrl,
    required this.sex,
    required this.ageRange,
    required this.triageColor,
    required this.status,
    required this.room,
    required this.arrivedAt,
    this.vitalSigns = const [],
    this.treatments = const [],
  });

  static DateTime _parseTs(dynamic v) {
    if (v is String) return DateTime.parse(v);
    if (v is Map) {
      final s = (v['_seconds'] ?? v['seconds']) as int;
      return DateTime.fromMillisecondsSinceEpoch(s * 1000);
    }
    return DateTime.now();
  }

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'] as String,
        wristbandNumber: json['wristbandNumber'] as String,
        photoUrl: json['photoUrl'] as String?,
        sex: Sex.values.byName(json['sex'] as String),
        ageRange: AgeRange.values.byName(json['ageRange'] as String),
        triageColor: TriageColor.values.byName(json['triageColor'] as String),
        status: PatientStatus.values.byName(json['status'] as String),
        room: TriageRoom.values.byName((json['assignedRoom'] ?? json['room']) as String),
        arrivedAt: _parseTs(json['createdAt'] ?? json['arrivedAt']),
        vitalSigns: (json['vitalSigns'] as List<dynamic>? ?? [])
            .map((e) => VitalSigns.fromJson(e as Map<String, dynamic>))
            .toList(),
        treatments: (json['treatments'] as List<dynamic>? ?? [])
            .map((e) => Treatment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'wristbandNumber': wristbandNumber,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'sex': sex.name,
        'ageRange': ageRange.name,
        'triageColor': triageColor.name,
      };
}
