import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum SocketStatus { connecting, connected, joined, disconnected, error }

class SocketClient {
  SocketClient._internal();
  static SocketClient _instance = SocketClient._internal();
  static SocketClient get instance => _instance;
  StreamController<SocketStatus> _statusController =
      StreamController.broadcast();
  Stream<SocketStatus> get status => _statusController.stream;

  IO.Socket _socket;
  String _nickname;

  void connect() {
    this._socket = IO.io(
      'https://socketio-chat-h9jt.herokuapp.com',
      <String, dynamic>{
        'transports': ['websocket'],
        // 'autoConnect': false,
      },
    );

    this._socket.on('connect', (_) {
      print("😀 connected");
      this._statusController.sink.add(SocketStatus.connected);
    });

    this._socket.on('connect_error', (_) {
      print("😀 error $_");
      this._statusController.sink.add(SocketStatus.error);
    });

    this._socket.on('disconnect', (_) {
      print("😀 disconnect $_");
      this._statusController.sink.add(SocketStatus.disconnected);
    });

    this._socket.on('login', (data) {
      print("🥶 $data");
      final int numUsers = data['numUsers'];
      this._statusController.sink.add(SocketStatus.joined);
    });

    // this._socket.connect();
  }

  void joinToChat(String nickname) {
    this._nickname = nickname;
    this._socket?.emit('add user', nickname);
  }

  void disconnect() {
    this._socket?.disconnect();
    this._socket = null;
  }
}
