import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoController = TextEditingController();
  List _toDoList = [];

  void _addToDo(){
    Map<String, dynamic> newToDo = new Map();
    newToDo["title"] = _toDoController.text;
    _toDoController.text = "";
    newToDo["ok"] = false;

    setState(() {
      _toDoList.add(newToDo);
    });
    
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {

    try{
      final file = await _getFile();
      return file.readAsString();
    }
    catch(e){
      return null;
    }
  }
  
  AppBar appBar() {
    return AppBar(
      title: Text("To do list"),
      backgroundColor: Colors.blueAccent,
      centerTitle: true,
    );
  }

  Column col() {
    return Column(
      children: <Widget>[
        Container(padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0), child: row1()),
        Expanded(child: listTask(),)
      ],
    );
  }

  ListView listTask() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      itemCount: _toDoList.length,
      itemBuilder: (context, index){
        return CheckboxListTile(
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(_toDoList[index]["ok"]?Icons.check:Icons.error),
          ),
          onChanged: (check){
            setState(() {
              _toDoList[index]["ok"] = check;
            });
          },
        );
      },
    );
  }

  Row row1() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
                    decoration: InputDecoration(
                                  labelText: "New task", 
                                  labelStyle: TextStyle(color: Colors.blueAccent)
                                ),
                    controller: _toDoController,
                  ),
        ),
        RaisedButton(
          color: Colors.blueAccent,
          child: Text("Add"),
          textColor: Colors.white,
          onPressed: _addToDo,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: col(),
    );
  }
}
