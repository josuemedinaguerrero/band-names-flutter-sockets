import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  final ServerStatus _serverStatus = ServerStatus.connecting;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    io.Socket socket = io.io(
      'http://192.168.18.8:3000',
      io.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
    );

    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });

    socket.onDisconnect((_) => print('Desconectado'));
    socket.on('respuesta', (data) => print('Respuesta del servidor: $data'));

    socket.onError((err) => print('Error de conexión: $err'));
  }
}
