import 'package:flutter/material.dart';
import 'package:socket_io_demo/pages/home_page_widgets/chat.dart';
import 'package:socket_io_demo/pages/home_page_widgets/nickname_form.dart';
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
      appBar: AppBar(),
      body: StreamBuilder<SocketStatus>(
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == SocketStatus.connecting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data == SocketStatus.connected) {
              return NicknameForm();
            } else if (snapshot.data == SocketStatus.joined) {
              return Chat();
            } else {
              return Center(
                child: Text("Disconnected"),
              );
            }
          }
          return Center(
            child: Text("Error"),
          );
        },
        initialData: SocketStatus.connecting,
        stream: SocketClient.instance.status,
      ),
    );
  }
}
