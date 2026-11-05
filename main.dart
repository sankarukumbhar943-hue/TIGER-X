import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const TigerXApp());

class TigerXApp extends StatelessWidget {
  const TigerXApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TIGER X',
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF07111F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF35D7FF), secondary: Color(0xFF35D7FF),
        surface: Color(0xFF102238),
      ),
    ),
    home: const TigerHome(),
  );
}

class ChatLine {
  final String text;
  final bool user;
  ChatLine(this.text, this.user);
}

class TigerHome extends StatefulWidget {
  const TigerHome({super.key});
  @override
  State<TigerHome> createState() => _TigerHomeState();
}

class _TigerHomeState extends State<TigerHome> {
  final input = TextEditingController();
  final speech = stt.SpeechToText();
  final tts = FlutterTts();
  final scroll = ScrollController();
  final List<ChatLine> messages = [
    ChatLine('Namaste! Main TIGER X hoon. Hindi, English ya Odia mein baat karein. Aaj English practice karein?', false)
  ];
  String language = 'Hindi';
  bool listening = false, busy = false;

  // Backend deploy hone ke baad yahan apna HTTPS URL daalein.
  final String backendUrl = 'https://YOUR-BACKEND-URL';

  String get locale => language == 'English' ? 'en-US' : language == 'Odia' ? 'or-IN' : 'hi-IN';

  Future<void> startListening() async {
    final available = await speech.initialize(
      onStatus: (s) { if (s == 'done' || s == 'notListening') setState(() => listening = false); },
      onError: (e) { setState(() => listening = false); },
    );
    if (!available) {
      showMessage('Speech recognition available nahi hai. Aap type karke bhej sakte hain.');
      return;
    }
    setState(() => listening = true);
    await speech.listen(
      localeId: locale,
      onResult: (r) => setState(() => input.text = r.recognizedWords),
    );
  }

  Future<void> speak(String text) async {
    await tts.setLanguage(locale);
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void showMessage(String text) => setState(() => messages.add(ChatLine(text, false)));

  Future<void> send() async {
    final question = input.text.trim();
    if (question.isEmpty || busy) return;
    setState(() {
      messages.add(ChatLine(question, true));
      input.clear();
      busy = true;
    });
    try {
      if (backendUrl.contains('YOUR-BACKEND-URL')) {
        showMessage('Backend abhi connect nahi hua hai. Backend deploy karke main.dart mein backendUrl set karein.');
      } else {
        final response = await http.post(
          Uri.parse('$backendUrl/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': question, 'language': language}),
        ).timeout(const Duration(seconds: 45));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final answer = data['reply']?.toString() ?? 'Mujhe jawab nahi mila.';
          showMessage(answer);
          await speak(answer);
        } else {
          showMessage('Server error (${response.statusCode}). Backend settings check karein.');
        }
      }
    } catch (_) {
      showMessage('Connection nahi ho paya. Internet aur backend URL check karein.');
    } finally {
      setState(() => busy = false);
      await Future.delayed(const Duration(milliseconds: 100));
      if (scroll.hasClients) {
        scroll.animateTo(scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    }
  }

  @override
  void dispose() {
    input.dispose(); scroll.dispose(); speech.stop(); tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF091A2B),
        title: const Row(children: [
          Icon(Icons.pets, color: Color(0xFF35D7FF), size: 30),
          SizedBox(width: 10),
          Text('TIGER X', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          DropdownButton<String>(
            value: language, underline: const SizedBox(),
            dropdownColor: const Color(0xFF102238),
            items: ['Hindi','English','Odia'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => language = v!),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0D2942), Color(0xFF07111F)]),
          ),
          child: Column(children: [
            Container(
              width: 86, height: 86,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF35D7FF), width: 2),
                boxShadow: const [BoxShadow(color: Color(0x6635D7FF), blurRadius: 22)]),
              child: const Icon(Icons.smart_toy, size: 52, color: Color(0xFF35D7FF)),
            ),
            const SizedBox(height: 10),
            Text(listening ? 'SUN RAHA HOON...' : busy ? 'SOCH RAHA HOON...' : 'YOUR AI ENGLISH PARTNER',
              style: const TextStyle(color: Color(0xFF65DFFF), letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 4),
            const Text('Learn • Speak • Improve', style: TextStyle(color: Colors.white70)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: scroll, padding: const EdgeInsets.all(14),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              return Align(
                alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 310),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: m.user ? const Color(0xFF075B78) : const Color(0xFF14283D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x3335D7FF)),
                  ),
                  child: Text(m.text, style: const TextStyle(fontSize: 15, height: 1.4)),
                ),
              );
            },
          ),
        ),
        if (busy) const LinearProgressIndicator(minHeight: 2),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(children: [
              IconButton(
                tooltip: 'Voice input',
                onPressed: listening ? () async { await speech.stop(); setState(() => listening = false); } : startListening,
                icon: Icon(listening ? Icons.mic : Icons.mic_none,
                  color: const Color(0xFF35D7FF), size: 29),
              ),
              Expanded(child: TextField(
                controller: input, minLines: 1, maxLines: 4,
                onSubmitted: (_) => send(),
                decoration: InputDecoration(
                  hintText: 'TIGER X se kuch poochhein...',
                  filled: true, fillColor: const Color(0xFF14283D),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              )),
              const SizedBox(width: 6),
              CircleAvatar(
                backgroundColor: const Color(0xFF35D7FF),
                child: IconButton(onPressed: send, icon: const Icon(Icons.send, color: Color(0xFF07111F))),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
