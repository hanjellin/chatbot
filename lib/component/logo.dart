import 'package:flutter/material.dart';

class Logo extends StatelessWidget{
  final double width;
  final double height;
  const Logo ({
    super.key, this.width = 200, this.height =200,
  });
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Image.asset(
          'asset/img/logo.png',
          width: width,
          height: height,
        ),
        SizedBox(height: 32.0),
        Text(
          '하이,',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}