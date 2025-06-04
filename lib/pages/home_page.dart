import 'dart:developer';

import 'package:band_names/models/band.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Michael', votes: 6),
    Band(id: '3', name: 'Bon Jovy', votes: 2),
    Band(id: '4', name: 'Enanitos verdes', votes: 12),
  ];

  void addNewBand() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New band name'),
          content: TextField(controller: textController),
          actions: [
            MaterialButton(
              onPressed: () => addBandToList(textController.text),
              elevation: 5,
              textColor: Colors.blue,
              child: Text('Add'),
            ),
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              elevation: 5,
              textColor: Colors.redAccent,
              child: Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BandNames')),
      body: ListView.builder(itemCount: bands.length, itemBuilder: (context, index) => _BandListTile(band: bands[index])),
      floatingActionButton: FloatingActionButton(onPressed: addNewBand, elevation: 1, child: Icon(Icons.add)),
    );
  }
}

class _BandListTile extends StatelessWidget {
  final Band band;

  const _BandListTile({required this.band});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        log("BAND: $band");
      },
      background: Container(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.text_rotation_angleup_sharp, color: Colors.white)),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue[100], child: Text(band.name.substring(0, 2))),
        title: Text(band.name),
        trailing: Text(band.votes.toString()),
      ),
    );
  }
}
