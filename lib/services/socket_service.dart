import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus { online, offline, error, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;

  SocketService() {
    _initConfig();
  }

  ServerStatus get serverStatus => _serverStatus;
  io.Socket get socket => _socket;

  void _initConfig() {
    _socket = io.io('http://192.168.18.8:3000', io.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build());

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _socket.onError((err) {
      _serverStatus = ServerStatus.error;
      notifyListeners();
    });
  }
}
