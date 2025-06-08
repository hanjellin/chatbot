import 'package:chatbot/model/schedule_model.dart';
import 'package:chatbot/repository/schedule_repository.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

//1. provider 정의 그리고 CRUD
//2. 정의된 provider 인스턴스화
//3. provider access

class ScheduleProvider extends ChangeNotifier{
  final ScheduleRepository repository;
  final uuid = Uuid();

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<DateTime , List<ScheduleModel>> cache ={};

  ScheduleProvider({
    required this.repository,
  }) : super() {
    getSchedules(date: selectedDate);
  }

  void getSchedules({
    required DateTime date,
  }) async {
    final resp = await repository.getSchedules(date: date);
    cache.update(date, (value) => resp, ifAbsent: () => resp);
    notifyListeners();
  }

  void createSchedules({
    required ScheduleModel schedule,
  }) async {
    final targetDate = schedule.date;
    final saverSchedule = await repository.createSchedule(schedule: schedule);

    cache.update(
      targetDate,
        (value) => [
          ...value,
          schedule.copyWith(
            id: saverSchedule,
          ),
        ]..sort(
            (a,b) =>a.startTime.compareTo(
              b.startTime,
            ),
        ),
      ifAbsent: () => [schedule],
    );
    notifyListeners();
  }

  void deleteSchedules({
    required DateTime date,
    required String id,
  }) async{
    final targetSchedule = cache[date]!.firstWhere(
        (e) => e.id == id,
    );
    cache.update(
      date,
        (value) => value.where((e) => e.id != id).toList(),
      ifAbsent: () => [],
    );

    notifyListeners();

    try{
      await repository.deleteSchedule(id : id);
    }catch(e){
      cache.update(date,
          (value)=> [...value, targetSchedule]..sort(
              (a,b)=> a.startTime.compareTo(b.startTime,
              ),
          ),
      );
    }
  notifyListeners();
  }

  void changeSelectedDate({
    required DateTime date,
  }) {
    selectedDate = date;
    notifyListeners();
  }
}