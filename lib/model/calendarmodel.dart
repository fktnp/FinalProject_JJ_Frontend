class CalendarModel {
  final String id;
  final String subJobID;
  final DateTime datePass;
  final bool statusSubJob;
  final String userID;
  final DateTime dateCalendar;

  CalendarModel({
    required this.id,
    required this.subJobID,
    required this.datePass,
    required this.statusSubJob,
    required this.userID,
    required this.dateCalendar,
  });

  // ฟังก์ชันสำหรับแปลง JSON เป็น CalendarModel
  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      id: json['Id'] ?? '', // ใช้ 'Id' แทน 'id'
      subJobID: json['SubJobID'] ?? '', // ใช้ 'SubJobID' แทน 'subJobID'
      datePass: DateTime.parse(json['DatePass'] ??
          '1970-01-01T00:00:00Z'), // ใช้ 'DatePass' แทน 'datePass'
      statusSubJob: json['StatusSubJob'] ??
          false, // ใช้ 'StatusSubJob' แทน 'statusSubJob'
      userID: json['UserID'] ?? '', // ใช้ 'UserID' แทน 'userID'
      dateCalendar:
          DateTime.parse(json['DateCalendar'] ?? '1970-01-01T00:00:00Z'),
    );
  }
}
