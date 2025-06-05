import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus { online, offline, error, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;

  SocketService() {
    _initConfig();
  }

  get serverStatus => _serverStatus;

  void _initConfig() {
    io.Socket socket = io.io(
      'http://192.168.18.8:3000',
      io.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
    );

    socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    socket.onError((err) {
      _serverStatus = ServerStatus.error;
      notifyListeners();
    });
  }
}
