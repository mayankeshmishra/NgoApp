import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ngo_app/login_register.dart';
import './home_page.dart';
import './mapping.dart';
import './authentication.dart';

void main(){
  runApp(new NgoApp());
}

class NgoApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title:"NGO",
      theme:new ThemeData(
        primarySwatch:Colors.pink,
      ),
      home:MappingPage(auth:Auth(),),
    );
  }
}