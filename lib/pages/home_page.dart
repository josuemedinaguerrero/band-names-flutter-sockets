import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  void _handleActiveBands(dynamic payload) {
    setState(() {
      bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  void addNewBand() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
          ),
    );
  }

  void addBandToList(String name) {
    if (name.isNotEmpty) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child:
                socketService.serverStatus == ServerStatus.online
                    ? Icon(Icons.check_circle, color: Colors.blue[300])
                    : Icon(Icons.offline_bolt, color: Colors.red[500]),
          ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(itemCount: bands.length, itemBuilder: (context, index) => _BandListTile(band: bands[index])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: addNewBand, elevation: 1, child: Icon(Icons.add)),
    );
  }

  SizedBox _showGraph() {
    if (bands.isEmpty) return SizedBox();

    Map<String, double> dataMap = {};

    for (var element in bands) {
      dataMap[element.name] = element.votes.toDouble();
    }

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(dataMap: dataMap, chartValuesOptions: ChartValuesOptions(showChartValuesInPercentage: true)),
    );
  }
}

class _BandListTile extends StatelessWidget {
  final Band band;

  const _BandListTile({required this.band});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.socket.emit('delete-band', {'id': band.id}),
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
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }
}
