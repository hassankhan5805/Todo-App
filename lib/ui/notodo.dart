import 'package:flutter/material.dart';
import 'package:no_todo/model/notodo_item.dart';
import 'package:no_todo/utils/database_client.dart';
import 'package:no_todo/utils/date_formatter.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  var db = new DatabaseHelper();
  final List<NoToDoItems> _itemList = <NoToDoItems>[];

  void initState() {
    super.initState();
    _readNoDoList();
  }

  void _handleSubmit(String mess) async {
    _textEditingController.clear();
    NoToDoItems noDoItem = new NoToDoItems(mess, dateFormatted());
    int savedItemId = await db.saveItem(noDoItem);
    print("Item Saved With ID: $savedItemId");
    NoToDoItems addedItem = await db.getItem(savedItemId);
    setState(() {
      _itemList.insert(0, addedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_, int index) {
                    return new Card(
                      color: Colors.white10,
                      child: new ListTile(
                        title: _itemList[index],
                        onLongPress: () => _editItem(_itemList[index], index),
                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                          ),
                          onPointerDown: (pointerEvent) =>
                              _deleteItem(_itemList[index].id, index),
                        ),
                      ),
                    );
                  })),
          new Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          tooltip: "Add Note",
          backgroundColor: Colors.red,
          child: new ListTile(
            title: new Icon(Icons.add),
          ),
          onPressed: _showFormDialogue),
    );
  }

  void _showFormDialogue() {
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: new InputDecoration(
                labelText: "Add Note",
                hintText: "eg. Don't go outside",
                icon: new Icon(Icons.note_add)),
          ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text('Save')),
        new FlatButton(
            onPressed: () => Navigator.pop(context), child: Text('Cancel'))
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      setState(() {
        _itemList.add(NoToDoItems.map(item));
      });
    });
  }

  _deleteItem(int id, int index) async {
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _editItem(NoToDoItems item, int index) {
    var alert = new AlertDialog(
      title: new Text("Edit Item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: new InputDecoration(
                labelText: "Edit Item",
                hintText: "${_textEditingController.text}",
                icon: new Icon(Icons.edit)),
          ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async {
              NoToDoItems updatedItem = NoToDoItems.fromMap({
                'itemName': _textEditingController.text,
                'dateCreated': dateFormatted(),
                'id': item.id
              });
              _handleSubmitUpdate(index, item);
              await db.updateItem(updatedItem);
              setState(() {
                _readNoDoList();
              });
              Navigator.pop(context);
            },
            child: new Text("Save Changes")),
        new FlatButton(
            onPressed: () => Navigator.pop(context), child: new Text('Cancel'))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _handleSubmitUpdate(int index, NoToDoItems item) {
    setState(() {
      _itemList.removeWhere((element) {
        _itemList[index].itemName == item.itemName;
      });
    });
  }
}
