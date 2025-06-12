import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:chatbot/provider/schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:chatbot/model/schedule_model.dart';

//핵심 코드

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  const ScheduleBottomSheet({
    required this.selectedDate,
    Key? key,
}): super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  //설문조사 점수 변수
  int achievement = 3; //성취도
  int happiness = 3;  //행복도
  int satisfaction = 3; //만복도

  //챗봇에게 받아올 문자열 변수
  String chatbotQuote = '';
  String chatbotExplanation = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //설문조사
              const Text(
                '오늘 하루를 평가해주세요!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              buildSelector('성취도 : 오늘 하기로 마음먹었던 것들을 성취하셨나요?', achievement, (value) {
                setState(() {
                  achievement = value;
                });
              }),
              buildSelector('행복도 : 하루동안 기분은 어떠셨나요?', happiness, (value) {
                setState(() {
                  happiness = value;
                });
              }),
              buildSelector('만족도 : 오늘 하루의 전체적으로 만족하시나요?', satisfaction, (value) {
                setState(() {
                  satisfaction = value;
                });
              }),

              const SizedBox(height: 24),
              //제출 버튼
              ElevatedButton(
                onPressed: isLoading ? null : sendSurveyToChatbot,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('제출'),
              ),
              const SizedBox(height: 24),

              //제미니 응답을 받아 명언과 설명을 두 로우으로 나눠서 표시
              if (chatbotQuote.isNotEmpty || chatbotExplanation.isNotEmpty) ...[
                //명언글 컨테
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chatbotQuote,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                // 설명글 컨테
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chatbotExplanation,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  //만족도 조사 버튼 선택 UI
  Widget buildSelector(String title, int selectedValue, Function(int) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final value = index + 1; //0~4에서 1~5점으로 맞추기
            final isSelected = selectedValue == value;
            return GestureDetector(
              onTap: () => onSelected(value),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[300],
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  //입력받은 성취도/행복도/만족도 점수를 Gemini 모델에 전달하고, 챗봇이 응답한 명언+설명을 파싱해서 화면에 표시.
  void sendSurveyToChatbot() async {
    setState(() {
      isLoading = true;
    });

    final prompt = '오늘 하루동안의 성취도: $achievement, 행복도: $happiness, 만족도: $satisfaction 이라고 점수를 보낼게.';
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyAAMhb0ziMRYwa9T0cZadWNrtq3BkWGeQI',
        systemInstruction: Content.system(
          '... 점수를 분석해서 명언과 설명을 \"명언:\", \"설명:\" 으로 구분해 줘.',
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final parsed = await parseBotResponse(context, text);

      setState(() {
        chatbotQuote = parsed['quote'] ?? '';
        chatbotExplanation = parsed['explanation'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      //오류나면
      setState(() {
        chatbotQuote = '';
        chatbotExplanation = '에러 발생: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  //제미니가 보낸 문자열에서 "명언 : ", "설명 : " 구분자를 기준으로 잘라서 Map 형태로 반환
  //Future를 붙여서 await로 provider를 써야 서버로 안정적으로 보낼 수 있음
  Future<Map<String, String>> parseBotResponse(BuildContext context, String text) async {
    //"명언" 뒤, "설명"이 나오기 전까지의 텍스트를 추출
    //특히 (.+?) 부분이 실제 추출을 담당, 나머지는 조건
    final RegExp quoteRegExp = RegExp(r'명언\s*[：:\s]?\s*(.+?)(?=설명|$)', dotAll: true);
    final RegExp explanationRegExp = RegExp(r'설명\s*[：:\s]?\s*(.+)', dotAll: true);

    final quoteMatch = quoteRegExp.firstMatch(text);
    final explanationMatch = explanationRegExp.firstMatch(text);

    final quote = quoteMatch?.group(1)?.trim() ?? '';
    final explanation = explanationMatch?.group(1)?.trim() ?? '';

    final provider = context.read<ScheduleProvider>();

    //성공적으로 저장하면 문제 없음
    try {
      //서버에 오늘날짜로 명언과 설명글 저장
      await provider.createSchedules(
        schedule: ScheduleModel(
          //id: const Uuid().v4(), //이건 최신 아이디
          id: 'new', //예시용 임시 아이디
          content: '명언: $quote\n설명: $explanation',
          date: widget.selectedDate,
          startTime: 0,
          endTime: 0,
        ),
      );
    } catch (e) {
      print('저장 실패: $e');
    }



    return {
      'quote': quote,
      'explanation': explanation,
    };
  }
}
