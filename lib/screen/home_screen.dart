import 'package:flutter/material.dart';
import 'package:chatbot/component/main_calendar.dart';
import 'package:chatbot/component/schedule_card.dart';
import 'package:chatbot/component/today_banner.dart';
import 'package:chatbot/component/schedule_bottom_sheet.dart';
import 'package:chatbot/const/colors.dart';

import 'package:provider/provider.dart';
import 'package:chatbot/provider/schedule_provider.dart';

class HomeScreen extends StatelessWidget{
  DateTime selectDate =DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
  );
  @override
  Widget build(BuildContext context){
    final provider = context.watch<ScheduleProvider>();
    final selectedDate = provider.selectedDate;
    final schedules = provider.cache[selectedDate] ?? [];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isDismissible: true,
              builder: (_) => ScheduleBottomSheet(
                //selectedDate: selectDate,
              ),
            isScrollControlled: true,
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              selectedDate: selectDate,
              onDaySelected: (selectedDate, focusedDate) =>
                  onDaySelected(selectedDate, focusedDate, context),
            ),
            SizedBox(height: 8.0),
            TodayBanner(
              selectedDate: selectDate,
                count: schedules.length,
            ),
            SizedBox(height: 8.0,),
            Expanded(
                child: ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];

                      return Dismissible(
                          key: ObjectKey(schedule.id),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (DismissDirection direction){
                            provider.deleteSchedules(date: selectedDate, id: schedule.id);
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8.0, right: 8.0),
                              child: ScheduleCard(
                                  startTime: schedule.startTime,
                                  endTime: schedule.endTime,
                                  content: schedule.content
                              ),
                          ),
                      );
                    }
                )
            )
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate, BuildContext context){
    final provider = context.read<ScheduleProvider>();
    provider.changeSelectedDate(date: selectedDate,);
    provider.getSchedules(date: selectedDate);
  }
}