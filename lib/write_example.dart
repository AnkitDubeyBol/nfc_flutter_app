import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'dart:async';
import 'dart:io';

class RecordEditor {

  TextEditingController payloadController;
  TextEditingController titleController;

  RecordEditor() {
    payloadController = TextEditingController();
    titleController = TextEditingController();
  }
}

class WriteExampleScreen extends StatefulWidget {
  @override
  _WriteExampleScreenState createState() => _WriteExampleScreenState();
}

class _WriteExampleScreenState extends State<WriteExampleScreen> {
  StreamSubscription<NDEFMessage> _stream;
  List<RecordEditor> _records = [];
  bool _hasClosedWriteDialog = false;

  void _addRecord() {
    setState(() {
      _records.add(RecordEditor());
    });
  }

  void _write(BuildContext context) async {

    List<NDEFRecord> records = _records.map((record) {

      var json = {
        'title': record.titleController.text,
        'description' : record.payloadController.text
      };

      return NDEFRecord.type(
        "text/plain",
        json.toString(),
      );
    }).toList();

    NDEFMessage message = NDEFMessage.withRecords(records);

    // Show dialog on Android (iOS has it's own one)
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Scan the tag you want to write to"),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cancel"),
              onPressed: () {
                _hasClosedWriteDialog = true;
                _stream?.cancel();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    // Write to the first tag scanned
    await NFC.writeNDEF(message).first;
    if (!_hasClosedWriteDialog) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write NFC example"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Center(
            child: OutlineButton(
              child: const Text("Add record"),
              onPressed: _addRecord,
            ),
          ),
          for (var record in _records)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Record", style: Theme.of(context).textTheme.body2),

                  TextFormField(
                    controller: record.titleController,
                    decoration: InputDecoration(
                      hintText: "Title",
                    ),
                  ),

                  TextFormField(
                    controller: record.payloadController,
                    decoration: InputDecoration(
                      hintText: "Enter description",
                    ),
                  )
                ],
              ),
            ),
          Center(
            child: RaisedButton(
              child: const Text("Write to tag"),
              onPressed: _records.length > 0 ? () => _write(context) : null,
            ),
          ),
        ],
      ),
    );
  }
}