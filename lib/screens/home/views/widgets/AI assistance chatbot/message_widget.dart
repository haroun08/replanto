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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isFromUser) ...[
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.green,
            backgroundImage: AssetImage('assets/replanto-bot.png'), // Bot Avatar
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            margin: const EdgeInsets.only(bottom: 8),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              gradient: isFromUser
                  ? const LinearGradient(
                colors: [Color(0xFF00B4DB), Color(0xFF0083B0)], // Blue gradient for user
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
                  : const LinearGradient(
                colors: [Color(0xFFECE9E6), Color(0xFFFFFFFF)], // Soft grey for bot
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isFromUser ? const Radius.circular(18) : Radius.zero,
                bottomRight: isFromUser ? Radius.zero : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isFromUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                a: TextStyle(color: isFromUser ? Colors.white : Colors.blue),
              ),
            ),
          ),
        ),
        if (isFromUser) ...[
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white), // User Avatar
          ),
        ],
      ],
    );
  }
}
