import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'message_widget.dart';
import 'consts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _chatHistory = []; // To store chat history locally
  bool _loading = false;

  final String apiKey = GEMINI_APi_KEY;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _chatSession = _model.startChat();
    _loadChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'replanto AI bot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _chatSession.history.length,
                  itemBuilder: (context, index) {
                    final Content content = _chatSession.history.toList()[index];
                    final text = content.parts
                        .whereType<TextPart>()
                        .map<String>((e) => e.text)
                        .join('');
                    return MessageWidget(
                      text: text,
                      isFromUser: content.role == 'user',
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          focusNode: _textFieldFocus,
                          controller: _textController,
                          onSubmitted: _sendChatMessage,
                          decoration: _inputDecoration(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: () => _sendChatMessage(_textController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'Enter a prompt...',
      contentPadding: const EdgeInsets.all(18),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      log("User message: $message");

      final response = await _chatSession.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null) {
        log("API response error: No response from API", level: 900);
        _showError('No response from API');
        return;
      } else {
        log("AI response: $text", level: 800);
        _saveMessage(message, text);
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      log("Error sending message: $e", error: e, level: 1000);
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      _textFieldFocus.requestFocus();
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileContent = await file.readAsString();
      _sendChatMessage(fileContent);
    }
  }

  void _saveMessage(String userMessage, String aiMessage) async {
    _chatHistory.add({'user': userMessage, 'ai': aiMessage});
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chat_history.txt');
    await file.writeAsString(_chatHistory.toString(), mode: FileMode.append);
  }

  void _loadChatHistory() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chat_history.txt');
    if (await file.exists()) {
      final history = await file.readAsString();
      log("Chat history loaded: $history");
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Something went wrong"),
          content: SingleChildScrollView(child: SelectableText(message)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }
}
