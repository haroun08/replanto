import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.text, required this.isFromUser});

  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isFromUser) ...[
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/replanto-bot.png'),
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            margin: const EdgeInsets.only(bottom: 8),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: isFromUser ? Colors.blueAccent : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isFromUser ? const Radius.circular(18) : Radius.zero,
                bottomRight: isFromUser ? Radius.zero : const Radius.circular(18),
              ),
            ),
            child: MarkdownBody(data: text),
          ),
        ),
        if (isFromUser) ...[
          const SizedBox(width: 10),
          const CircleAvatar(
            child: Icon(Icons.person), // User Avatar
          ),
        ]
      ],
    );
  }
}
