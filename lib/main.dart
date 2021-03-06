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
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  void _addToDo() {
    Map<String, dynamic> newToDo = new Map();
    newToDo["title"] = _toDoController.text;
    _toDoController.text = "";
    newToDo["ok"] = false;

    setState(() {
      _toDoList.add(newToDo);
    });

    _saveData();
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
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
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
  
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a,b){
        if(a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;     
        });
    });

     _saveData();
    
  }

  Column col() {
    return Column(
      children: <Widget>[
        Container(padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0), child: row1()),
        Expanded(child: RefreshIndicator(
                          onRefresh: _refresh,
                          child: listTask(),
                        )
                )
      ],
    );
  }

  ListView listTask() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      itemCount: _toDoList.length,
      itemBuilder: buildItem,
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
                    color: Colors.red, 
                    child: Align(
                              alignment: Alignment(-0.9, 0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                  ),
      direction: DismissDirection.startToEnd,
      child:  CheckboxListTile(
                title: Text(_toDoList[index]["title"]),
                value: _toDoList[index]["ok"],
                secondary:  CircleAvatar(
                              child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
                            ),
                onChanged: (check) {
                  setState(() {
                    _toDoList[index]["ok"] = check;
                  });
                  _saveData();
                },
              ),
      onDismissed: (dir){
        _lastRemoved = Map.from(_toDoList[index]);
        _lastRemovedPos = index;
        setState(() {
           _toDoList.removeAt(index);
        });       
        _saveData();

        final snack = SnackBar(
          content: Text("Task ${_lastRemoved["title"]} removida!"),
          action: SnackBarAction(
                    label: "undo", 
                    onPressed: (){

                      setState(() {
                        _toDoList.insert(_lastRemovedPos, _lastRemoved);
                      });
                      
                      _saveData();
                    },
                  ),
          duration: Duration(seconds: 2),
        );
        Scaffold.of(context).removeCurrentSnackBar(); 
        Scaffold.of(context).showSnackBar(snack);
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
                labelStyle: TextStyle(color: Colors.blueAccent)),
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
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: col(),
    );
  }
}
