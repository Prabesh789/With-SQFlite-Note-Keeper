class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note(this._date, this._priority, this._title, [this._description]);
  //This constructor accept id as a parameter
  //Named constructor bcz we cannot have two unnamed constructor
  Note.withId(this._id, this._date, this._priority, this._title,
      [this._description]);

  //Getter
  int get id => _id;
  String get title => _title;
  String get deccription => _description;
  int get priority => _priority;
  String get date => _date;

  //Seter

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set deccription(String newDescription) {
    if (newDescription.length <= 250) {
      this._description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  //Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;

    return map;
  }

  //Extract a Note object from a Map object

  Note.formMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }
}
