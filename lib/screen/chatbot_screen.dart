import 'package:flutter/material.dart';
import 'package:chatbot/component/logo.dart';
import 'package:chatbot/model/message_model.dart';
import 'package:chatbot/component/message.dart';
import 'package:chatbot/component/date_divider.dart';
import 'package:chatbot/component/chat_text_field.dart';
import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:isar/isar.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>{
  final TextEditingController controller = TextEditingController();

  bool isRunning = false;
  String? error;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                  stream: GetIt.I<Isar>().messageModels.where().watch(fireImmediately: true),
                  builder: (context, snapshot){
                    final messages = snapshot.data ?? [];
                    return buildMessageList(messages);
                  },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
              child: ChatTextField(
                  error: error,
                  loading: isRunning,
                  onSend: handleSendMessage,
                  controller: controller
              ),
            ),
          ],
        ),
      ),
    );
  }
  handleSendMessage()async{
    if(controller.text.isEmpty){
      setState(() => error = '메세지를 입력해주세요!');
      return;
    }
    //현재 응답받고 있는 메세지ID(스트림으로 지속저긍로 업데이트)
    int ? currentModelMessageId;
    //내가 보낸 메세지에 배정된 ID
    int ? currentUserMessageId;
    final isar = GetIt.I<Isar>();
    final currentPrompt = controller.text;
    try{
      //로딩중 상태 변경
      setState(() {
        isRunning = true;
      });
      //Textfield에 입력된 값 모두 삭제
      controller.clear();
      //현재 데이터베이스에 저장되어있는 내가 보낸 메세지 숫자 세기
      final myMessagesCount = await isar.messageModels.filter().isMineEqualTo(true).count();
      currentUserMessageId = await isar.writeTxn(() async{
        return await isar.messageModels.put(
          MessageModel(
              isMine: true,
              message: currentPrompt,
              point: myMessagesCount + 1,
              date: DateTime.now(),
          ),
        );
      });

      final contextMessages = await isar.messageModels.where().limit(5).findAll();
      final List<Content> promptContext = contextMessages.map((e) =>
          Content(e.isMine! ? 'user':'model', [TextPart(e.message!),],),).toList();
      final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: 'AIzaSyAAMhb0ziMRYwa9T0cZadWNrtq3BkWGeQI',
          systemInstruction:
          Content.system('오늘 하루동안의 성취도 1~5점, 행복도1~5점, 만족도1~5점이라고 점수를 각각 보낼거야. 그러면 점수을 분석해서 그날 필요한 명언 하나씩 가져오고 설명글을 써줘.'),
      );
      String message = '';
      model.generateContentStream(promptContext).listen(
          (event)async{
            if(event.text != null){
              message += event.text!;
            }
            final MessageModel model = MessageModel(
                isMine: false,
                message: message,
                date: DateTime.now(),
            );
            if(currentUserMessageId != null){
              model.id = currentUserMessageId!;
            }
            currentUserMessageId = await isar.writeTxn<int>(()=>isar.messageModels.put(model));
          },
          onDone: () => setState(() {
            isRunning = false;
          }),
          onError: (e)async{
            await isar.writeTxn(() async{
              return isar.messageModels.delete(currentUserMessageId!);
            });
            setState(() {
              error =e.toString();
              isRunning = false;
            });
          },
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildMessageList(List<MessageModel> messages){
    return ListView.separated(
        itemCount: messages.length + 1,
        itemBuilder: (context , index) => index == 0
      ? buildLogo()
        : buildMessageItem(
            message: messages[index - 1],
            prevMessage: index > 1 ? messages[index - 2] : null,
            index: index -1,
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 16.0),
    );
  }

  Widget buildLogo(){
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Padding(
        padding: EdgeInsets.only(bottom: 60.0),
        child: Logo(),
      ),
    );
  }

  Widget buildMessageItem({
    MessageModel? prevMessage,
    required MessageModel message,
    required int index,
}) {
    final isMine = message.isMine;
    final shouldDrawDateDivider = prevMessage == null || shouldDrawDate(prevMessage.date!, message.date!);

    return Column(
      children: [
        if(shouldDrawDateDivider)
          Padding(padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DateDivder(date: message.date),
          ),
        Padding(
          padding: EdgeInsets.only(
            left: isMine? 64.0 : 16.0, right: isMine ? 16.0 : 64.0
          ),
          child: Message(
            alignLeft: !isMine,
            message: message.message.trim(),
            point: message.point,
          ),
        ),
      ],
    );
  }

  bool shouldDrawDate(DateTime date1, DateTime date2){
    return getStringDate(date1) != getStringDate(date2);
  }

  String getStringDate(DateTime date){
    return '${date.year}년 ${date.month}월 ${date.month}일';
  }
}