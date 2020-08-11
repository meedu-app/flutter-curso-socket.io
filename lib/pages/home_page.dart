import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:socket_io_demo/pages/home_page_widgets/chat.dart';
import 'package:socket_io_demo/pages/home_page_widgets/nickname_form.dart';
import 'package:socket_io_demo/utils/consts.dart';
import 'package:socket_io_demo/utils/socket_client.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    SocketClient.instance.init();
    SocketClient.instance.connect();
  }

  @override
  void dispose() {
    SocketClient.instance.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff102027),
      appBar: AppBar(
        backgroundColor: accentColor,
        title: Obx(() {
          final users = SocketClient.instance.numUsers;
          return Text("users (${users.value})");
        }),
      ),
      body: Obx(() {
        final status = SocketClient.instance.status;
        if (status.value == SocketStatus.connecting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (status.value == SocketStatus.connected) {
          return NicknameForm();
        } else if (status.value == SocketStatus.joined) {
          return Chat();
        } else {
          return Center(
            child: Text("Disconnected"),
          );
        }
      }),
    );
  }
}
