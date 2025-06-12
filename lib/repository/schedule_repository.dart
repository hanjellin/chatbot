import 'dart:async';
import 'dart:io';
import 'package:chatbot/model/schedule_model.dart';
import 'package:dio/dio.dart';

//레포지토리 여기서 get create delete 정의

class ScheduleRepository{
  final _dio = Dio();
  //이거 주소에 띄어쓰기 떄문에 안 됬던 거였음
  //와 이걸로 2주를 까먹은 게 레전드네
  //
  //ㄹㅇㅋㅋ
  final _targetUrl = 'http://${Platform.isAndroid?'10.0.2.2':'localhost'}:3000/schedule';

  Future<List<ScheduleModel>> getSchedules({
    required DateTime date,
    }) async {
    final resp = await _dio.get(
      _targetUrl,
      queryParameters: {
        'date':
            '${date.year}${date.month.toString().padLeft(2,'0')}${date.day.toString().padLeft(2, '0')}',
      },
    );

    return resp.data.map<ScheduleModel>(
        (x) => ScheduleModel.fromJson(json: x,),
    ).tolist();
  }
  Future createSchedule({
    required ScheduleModel schedule,
    }) async {
    final json = schedule.toJson();
    final resp = await _dio.post(_targetUrl, data : json);
    return resp.data?['id'];
  }

  Future deleteSchedule({
    required String id,
}) async {
    final resp = await _dio.delete(_targetUrl, data: {
      'id' : id,
    });
    return resp.data?['id'];
  }
}