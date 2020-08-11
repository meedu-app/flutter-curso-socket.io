import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_demo/models/chat_message.dart';

enum SocketStatus { connecting, connected, joined, disconnected, error }

class SocketClient {
  SocketClient._internal();
  static SocketClient _instance = SocketClient._internal();
  static SocketClient get instance => _instance;

  RxInt _numUsers = 0.obs;
  RxString _inputText = "".obs;
  RxMap<String, String> _typingUsers = Map<String, String>().obs;
  RxList<ChatMessage> _messages = List<ChatMessage>().obs;
  RxList<ChatMessage> get messages => _messages;

  String get typingUser {
    if (this._typingUsers.values.length > 0) {
      return this._typingUsers.values.last;
    }
    return null;
  }

  RxInt get numUsers => _numUsers;
  Rx<SocketStatus> _status = SocketStatus.connecting.obs;
  Rx<SocketStatus> get status => _status;

  IO.Socket _socket;
  String _nickname;
  Worker _typingWorker;

  void init() {
    debounce(
      this._inputText,
      (_) {
        this._socket?.emit('stop typing');
        this._typingWorker = null;
      },
      time: Duration(milliseconds: 500),
    );
  }

  void connect() {
    this._socket = IO.io(
      'https://socketio-chat-h9jt.herokuapp.com',
      <String, dynamic>{
        'transports': ['websocket'],
      },
    );

    this._socket.on('connect', (_) {
      this._status.value = SocketStatus.connected;
    });

    this._socket.on('connect_error', (_) {
      this._status.value = SocketStatus.error;
    });

    this._socket.on('disconnect', (_) {
      this._status.value = SocketStatus.disconnected;
    });

    this._socket.on('login', (data) {
      final int numUsers = data['numUsers'];
      this._numUsers.value = numUsers;
      this._status.value = SocketStatus.joined;
    });

    this._socket.on('user joined', (data) {
      this._numUsers.value = data['numUsers'] as int;
    });

    this._socket.on('typing', (data) {
      final String username = data['username'];
      this._typingUsers.add(username, username);
    });

    this._socket.on('stop typing', (data) {
      final String username = data['username'];
      this._typingUsers.remove(username);
    });

    this._socket.on('user left', (data) {
      showSimpleNotification(
        Text("${data['username']} left"),
        background: Colors.redAccent,
      );
      this._numUsers.value = data['numUsers'] as int;
    });

    this._socket.on('new message', (data) {
      final String username = data['username'];
      final String message = data['message'];

      if (message != null && message.length > 0) {
        this._messages.add(
              ChatMessage(
                username: username,
                message: message,
                sender: false,
              ),
            );
      }
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

  void onInputChanged(String text) {
    if (this._typingWorker == null) {
      this._typingWorker = once(this._inputText, (_) {
        // print("start typing");
        this._socket?.emit('typing');
      });
    }
    this._inputText.value = text;
  }

  bool sendMessage() {
    final text = this._inputText.value;
    if (text.trim().length > 0) {
      this._socket.emit('new message', text);
      this._inputText.value = '';

      final message = ChatMessage(
        username: this._nickname,
        message: text,
        sender: true,
      );
      this._messages.add(message);

      return true;
    }
    return false;
  }
}
