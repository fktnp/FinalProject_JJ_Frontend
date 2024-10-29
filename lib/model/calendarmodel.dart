class CalendarModel {
  final String id;
  final String subJobID;
  final DateTime timePass;
  final bool statusSubJob;
  final String userID;
  final DateTime dateCalendar;

  CalendarModel({
    required this.id,
    required this.subJobID,
    required this.timePass,
    required this.statusSubJob,
    required this.userID,
    required this.dateCalendar,
  });

  // ฟังก์ชันสำหรับแปลง JSON เป็น CalendarModel
  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    final dateCalendar = json['DateCalendar'];

    return CalendarModel(
      id: json['Id'] ?? '', // ใช้ 'Id' แทน 'id'
      subJobID: json['SubJobID'] ?? '', // ใช้ 'SubJobID' แทน 'subJobID'
      timePass: DateTime(0, 1, 1, json['TimePass']['hour'] ?? 0,
          json['TimePass']['minute'] ?? 0), // ใช้ 'DatePass' แทน 'datePass'
      statusSubJob: json['StatusSubJob'] ??
          false, // ใช้ 'StatusSubJob' แทน 'statusSubJob'
      userID: json['UserID'] ?? '', // ใช้ 'UserID' แทน 'userID'
      dateCalendar: DateTime.parse(
        '${dateCalendar['year']}-${dateCalendar['month'].toString().padLeft(2, '0')}-${dateCalendar['day'].toString().padLeft(2, '0')}',
      ),
    );
  }
}
