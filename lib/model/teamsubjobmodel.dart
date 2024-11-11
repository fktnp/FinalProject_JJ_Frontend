import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Teamsubjobmodel {
  final String jobId;
  final String subJobId;
  final String name;
  final String status;
  final String details;
  final DateTime startDate;
  final DateTime lastDate;
  final DateTime startTime;
  final DateTime lastTime;
  final List<String> workByUserID;
  final String linkAreaWork;
  final String linkSubmitWork;
  final String headSubJobID;

  Teamsubjobmodel({
    required this.jobId,
    required this.name,
    required this.subJobId,
    required this.status,
    required this.details,
    required this.startTime,
    required this.lastTime,
    required this.startDate,
    required this.lastDate,
    required this.workByUserID,
    required this.linkAreaWork,
    required this.linkSubmitWork,
    required this.headSubJobID,
  });

  factory Teamsubjobmodel.fromJson(Map<String, dynamic> json) {
    final startDateJson = json['StartDate'];
    final lastDateJson = json['LastDate'];

    return Teamsubjobmodel(
      jobId: json['JobID'] ?? '',
      subJobId: json['SubJobID'] ?? '',
      name: json['Name'] ?? '',
      status: json['Status'] ?? '',
      details: json['Details'] ?? '',
      startTime: DateTime(0, 1, 1, json['StartTime']['hour'] ?? 0,
          json['StartTime']['minute'] ?? 0),
      lastTime: DateTime(0, 1, 1, json['LastTime']['hour'] ?? 0,
          json['LastTime']['minute'] ?? 0),
      startDate: DateTime.parse(
        '${startDateJson['year']}-${startDateJson['month'].toString().padLeft(2, '0')}-${startDateJson['day'].toString().padLeft(2, '0')}',
      ),
      lastDate: DateTime.parse(
        '${lastDateJson['year']}-${lastDateJson['month'].toString().padLeft(2, '0')}-${lastDateJson['day'].toString().padLeft(2, '0')}',
      ),
      workByUserID: List<String>.from(json['WorkByUserID'] ?? []),
      linkAreaWork: json['LinkAreaWork'] ?? '',
      linkSubmitWork: json['LinkSubmitWork'] ?? '',
      headSubJobID: json['HeadSubJobID'] ?? '',
    );
  }
}

Future<void> createSubCoop({
  required String jobId,
  required String name,
  required String status,
  required String details,
  required DateTime startDate,
  required DateTime lastDate,
  required TimeOfDay startTime,
  required TimeOfDay lastTime,
  required List<String> workByUserIds,
  required String linkWorkArea,
  required String linkSubmitWork,
  required String headUserId,
}) async {
  try {
    final Map<String, dynamic> data = {
      'job_id': jobId,
      'name': name,
      'status': "Incomplete",
      'details': details,
      'start_date': {
        'day': startDate.day,
        'month': startDate.month,
        'year': startDate.year,
      },
      'last_date': {
        'day': lastDate.day,
        'month': lastDate.month,
        'year': lastDate.year,
      },
      'start_time': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'last_time': {
        'hour': lastTime.hour,
        'minute': lastTime.minute,
      },
      'work_by_user_id': workByUserIds,
      'link_area_work': linkWorkArea,
      'link_submit_work': linkSubmitWork,
      'head_sub_job_id': headUserId,
    };
    var response = await Dio().post(
      'http://192.168.1.36:8080/v1/teamSubJob',
      data: data,
    );
    // การส่งข้อมูล POST
    print(response.data);
  } on DioException catch (e) {
    if (e.response != null) {
      print('Error status code: ${e.response?.statusCode}');
      print('Error saving task: ${e.response?.data}');
    } else {
      print('Error sending request: ${e.message}');
    }
  }
}
