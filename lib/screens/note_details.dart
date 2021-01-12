import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() =>
      _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  var _formkey = GlobalKey<FormState>();
  String appBarTitle;
  Note note;
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionContrller = TextEditingController();
  _NoteDetailState(this.note, this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionContrller.text = note.deccription;
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              moveToLastScreen();
            },
          ),
          title: Text(appBarTitle),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Form(
            key: _formkey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      value: getPriorityAsString(note.priority),
                      style: textStyle,
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User Selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: titleController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint('Somthing changed in title Text field');
                        updateTitle();
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter time in year';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      controller: descriptionContrller,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint(
                            'Somthing changed in Description Text field');
                        updateDescription();
                      },
                      decoration: InputDecoration(
                        labelText: 'Decription',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please Enter some dwscription';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_formkey.currentState.validate()) {
                                  _save();
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint('Delete button clicked');
                                _delete();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //Convert the string priority in the form of integer before saving it to databse
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert int priority to string priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //'High'
        break;
      case 2:
        priority = _priorities[1]; //'Low'
        break;
    }
    return priority;
  }

  //Update the title of the Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  //Update the description of the note object
  void updateDescription() {
    note.deccription = descriptionContrller.text;
  }

  //Save data to database
  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      //Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      //Case 2: Insert Operation
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      //Success
      _showAlertDialog('Status', 'Note Saved Succesfully');
    } else {
      //Failer
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  //Case 1: If user is trying to delete the NEW NOTe i.e. he has
  //to the detail page by pressing the FAB of NoteList page.

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog('Status', 'No save Note, is deleted');
      return;
    } else {
      int result = await helper.deleteNote(note.id);
      if (result != 0) {
        _showAlertDialog('Status', 'Note Deleted Succesfully');
      } else {
        _showAlertDialog('Status', 'Error Occured while Deleting Note');
      }
    }
  }

  //Case 2: User is trying to delete the old note already has a valid ID.
}
