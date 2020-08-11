import 'package:meta/meta.dart' show required;

class ChatMessage {
  final String username, message;
  final bool sender;

  ChatMessage({
    @required this.username,
    @required this.message,
    @required this.sender,
  });
}
