import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_demo/utils/socket_client.dart';

class NicknameForm extends StatefulWidget {
  const NicknameForm({Key key}) : super(key: key);

  @override
  _NicknameFormState createState() => _NicknameFormState();
}

class _NicknameFormState extends State<NicknameForm> {
  String _nickname = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "What's your nickname?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          CupertinoTextField(
            placeholder: "insert your nickname",
            onChanged: (text) {
              this._nickname = text;
            },
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: Colors.blue,
              onPressed: () {
                if (this._nickname.trim().length > 0) {
                  SocketClient.instance.joinToChat(this._nickname);
                }
              },
              child: Text("Join to chat"),
            ),
          ),
        ],
      ),
    );
  }
}
