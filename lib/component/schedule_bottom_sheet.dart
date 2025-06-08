import 'package:flutter/material.dart';
import 'package:chatbot/component/coustom_text_field.dart';
import 'package:chatbot/const/colors.dart';
import 'package:chatbot/model/schedule_model.dart';
import 'package:provider/provider.dart';
import 'package:chatbot/provider/schedule_provider.dart';


class ScheduleBottomSheet extends StatefulWidget {
  @override
  _ScheduleBottomSheetState createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  int? taskSatisfaction;  // 0 ~ 4
  int? moodSatisfaction;  // 0 ~ 4

  Widget buildSatisfactionRow({
    required String question,
    required int? selectedValue,
    required Function(int) onTap,
  }) {
    return Column(
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int value = index + 1;
            bool isSelected = selectedValue == index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ElevatedButton(
                onPressed: () => onTap(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                  side: BorderSide(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  '$value',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildSatisfactionRow(
            question: "오늘 하기로 마음먹었던 것들을\n어느정도 성취하셨나요?",
            selectedValue: taskSatisfaction,
            onTap: (val) => setState(() => taskSatisfaction = val),
          ),
          SizedBox(height: 30),
          buildSatisfactionRow(
            question: "하루동안 기분은 어떠셨나요?",
            selectedValue: moodSatisfaction,
            onTap: (val) => setState(() => moodSatisfaction = val),
          ),
          SizedBox(height: 30),
          buildSatisfactionRow(
            question: "오늘 하루의 전체적으로 만족하시나요?",
            selectedValue: moodSatisfaction,
            onTap: (val) => setState(() => moodSatisfaction = val),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              print("Task: $taskSatisfaction / Mood: $moodSatisfaction");
              Navigator.pop(context);
            },
            child: Text("제출"),
          ),
        ],
      ),
    );
  }
}