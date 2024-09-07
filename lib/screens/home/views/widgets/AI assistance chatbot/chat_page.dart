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
        title: const Text('replanto AI bot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: _pickFile, // Button to read files
          ),
        ],
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
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: textFieldDecoration(),
                        controller: _textController,
                        onSubmitted: _sendChatMessage,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendChatMessage(_textController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
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
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileContent = await file.readAsString();
      _sendChatMessage(fileContent); // Send file content as message
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

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
    );
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

  Future<String> getPlantAdvice(String plantId) async {
    try{
      final doc = await FirebaseFirestore.instance.collection('plants').doc(plantId).get();
      if(doc.exists){
        final plantData = doc.data();
        return plantData != null ? plantData['advice'] ?? 'No advice available' : 'No data found';
      }
      return 'plant not found';
    }catch(e){
      return 'Error fetching plant advice: $e';
    }
  }
}
