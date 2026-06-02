enum TriageColor { red, yellow, green, black }

enum PatientSex { male, female }

enum AgeRange { infant, child, adult, senior }

enum PatientStatus { waiting, inTreatment, discharged, deceased }

class PatientModel {
  final String wristbandNumber;
  final PatientSex sex;
  final AgeRange ageRange;
  final TriageColor triageColor;
  final String? photoUrl;
  final DateTime arrivedAt;
  PatientStatus status;

  PatientModel({
    required this.wristbandNumber,
    required this.sex,
    required this.ageRange,
    required this.triageColor,
    this.photoUrl,
    required this.arrivedAt,
    this.status = PatientStatus.waiting,
  });

  String get triageColorName {
    switch (triageColor) {
      case TriageColor.red:
        return 'RED';
      case TriageColor.yellow:
        return 'YELLOW';
      case TriageColor.green:
        return 'GREEN';
      case TriageColor.black:
        return 'BLACK';
    }
  }

  String get ageRangeLabel {
    switch (ageRange) {
      case AgeRange.infant:
        return 'INFANT';
      case AgeRange.child:
        return 'CHILD';
      case AgeRange.adult:
        return 'ADULT';
      case AgeRange.senior:
        return 'SENIOR';
    }
  }

  String get sexLabel => sex == PatientSex.male ? 'MALE' : 'FEMALE';

  String get roomName => '${triageColorName} ROOM';
}
