import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_demo/utils/socket_client.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class InputChat extends StatefulWidget {
  final VoidCallback onSent;
  const InputChat({Key key, @required this.onSent}) : super(key: key);

  @override
  _InputChatState createState() => _InputChatState();
}

class _InputChatState extends State<InputChat> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Color(0xff37474f),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              placeholder: "Your message here ...",
              placeholderStyle: GoogleFonts.quicksand(
                color: Color(0xff546e7a),
              ),
              style: GoogleFonts.quicksand(
                color: Colors.white,
              ),
              controller: _controller,
              onChanged: SocketClient.instance.onInputChanged,
            ),
          ),
          CupertinoButton(
            color: Color(0xff546e7a),
            padding: EdgeInsets.all(5),
            borderRadius: BorderRadius.circular(30),
            onPressed: () {
              final sent = SocketClient.instance.sendMessage();
              if (sent) {
                _controller.text = "";
                widget.onSent();
              }
            },
            child: Icon(
              Ionicons.ios_send,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
