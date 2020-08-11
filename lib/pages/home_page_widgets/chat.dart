import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:socket_io_demo/models/chat_message.dart';
import 'package:socket_io_demo/pages/home_page_widgets/input_chat.dart';
import 'package:socket_io_demo/pages/home_page_widgets/message_item.dart';
import 'package:socket_io_demo/utils/socket_client.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ScrollController _scrollController = ScrollController();
  bool _isEnd = false;
  StreamSubscription _subscription;
  ValueNotifier<int> _counter = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _subscription = SocketClient.instance.messages.listen((_) {
      if (_.length > 0 && !_.last.sender) {
        if (_isEnd) {
          _goToEnd();
        } else if (_scrollController.position.maxScrollExtent > 0) {
          _counter.value++;
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _goToEnd() {
    Future.delayed(Duration(milliseconds: 200), () {
      final offset = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      _counter.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () {
                        final messages = SocketClient.instance.messages;
                        return NotificationListener(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemBuilder: (_, index) {
                              final ChatMessage message = messages[index];
                              return MessageItem(message: message);
                            },
                            itemCount: messages.length,
                          ),
                          onNotification: (t) {
                            if (t is ScrollEndNotification) {
                              this._isEnd = _scrollController.offset >=
                                  _scrollController.position.maxScrollExtent;
                            }

                            return false;
                          },
                        );
                      },
                    ),
                  ),
                  Obx(() {
                    final String typingUser = SocketClient.instance.typingUser;
                    if (typingUser != null) {
                      return Text(
                        "$typingUser is typing",
                        style: TextStyle(
                          color: Colors.black26,
                        ),
                      );
                    }
                    return Container(height: 0);
                  }),
                  InputChat(
                    onSent: this._goToEnd,
                  )
                ],
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _counter,
              builder: (_, int counter, __) {
                if (counter == 0) {
                  return Container();
                }
                return Positioned(
                  right: 10,
                  bottom: 120,
                  child: FloatingActionButton(
                    onPressed: _goToEnd,
                    backgroundColor: Colors.white,
                    child: Text(
                      counter.toString(),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
