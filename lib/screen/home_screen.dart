import 'package:flutter/material.dart';
import 'package:chatbot/component/main_calendar.dart';
import 'package:chatbot/component/schedule_card.dart';
import 'package:chatbot/component/today_banner.dart';
import 'package:chatbot/component/schedule_bottom_sheet.dart';
import 'package:chatbot/const/colors.dart';
import 'package:provider/provider.dart';
import 'package:chatbot/provider/schedule_provider.dart';

//이게 메인 화면임

class HomeScreen extends StatelessWidget{
  //오늘 날짜 가져오는 변수
  //schedule_button_sheet에서 명언을 서버에 저장할 때 명언 필요한데 그걸 여기서
  //만족도조사버튼 함수에서 매개변수로 넘기기 위한거 schedule_provider에 있던거 그대로 가져옴
  DateTime selectedDate = DateTime.utc(
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
        onPressed: () => SatisfactionButton(context),
        child: Icon(
          Icons.add,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //상단 문장 출력 컨테이너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              color: Colors.black87,
              child: const Center(
                child: Text(
                  '오늘의 한 문장',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            //컬렌더
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: (selectedDate, focusedDate) =>
                  onDaySelected(selectedDate, focusedDate, context),
            ),

            //오늘 날짜 표기 배너
            SizedBox(height: 8.0),
            TodayBanner(
              selectedDate: selectedDate,
              count: schedules.length,
            ),

            //여기서 저정된 명언 카드 출력
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

  //만족도 조사 버튼
  void SatisfactionButton(BuildContext context) async {
    await showModalBottomSheet<Map<String, int?>>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ScheduleBottomSheet(
        selectedDate: selectedDate,
      ),
    );
  }

  void onDaySelected(
      DateTime selectedDate,
      DateTime focusedDate,
      BuildContext context){
    final provider = context.read<ScheduleProvider>();
    provider.changeSelectedDate(date: selectedDate);
    provider.getSchedules(date: selectedDate);
  }
}