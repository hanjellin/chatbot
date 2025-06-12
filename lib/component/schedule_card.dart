import 'package:chatbot/const/colors.dart';
import 'package:flutter/material.dart';

//저장된 명언글 출력

class ScheduleCard extends StatelessWidget {
  final String content;

  const ScheduleCard({
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //bottom_sheet에서 그대로 가져온거
    final RegExp quoteRegExp = RegExp(r'명언\s*[：:\s]?\s*(.+?)\s*(?=설명|$)', dotAll: true);
    final RegExp explanationRegExp = RegExp(r'설명\s*[：:\s]?\s*(.+)', dotAll: true);

    final quoteMatch = quoteRegExp.firstMatch(content);
    final explanationMatch = explanationRegExp.firstMatch(content);

    final quote = quoteMatch?.group(1)?.trim() ?? '명언 없음';
    final explanation = explanationMatch?.group(1)?.trim() ?? '설명 없음';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: PRIMARY_COLOR,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //명언과 설명글 출력
        children: [
          Text(
            '명언',
            style: TextStyle(
              color: PRIMARY_COLOR,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 4),
          Text(
            quote,
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 12),
          Text(
            '설명',
            style: TextStyle(
              color: PRIMARY_COLOR,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 4),
          Text(
            explanation,
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}