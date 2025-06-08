import 'package:flutter/material.dart';

class DateDivder extends StatelessWidget{
  final DateTime date;
  const DateDivder({
   super.key,
   required this.date,
});
  @override
  Widget build(BuildContext context){
    return Text(
      '${date.year}년 ${date.month}월 ${date.day}일',
      style: TextStyle(color: Colors.black54, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }
}