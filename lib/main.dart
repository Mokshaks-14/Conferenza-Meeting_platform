import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';

// ================= CONFIGURATION =================
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAq6yYNCYj1I5A2mSxPglv2i1qESY9WP64",
  authDomain: "meetingapp-9fb61.firebaseapp.com",
  projectId: "meetingapp-9fb61",
  storageBucket: "meetingapp-9fb61.firebasestorage.app",
  messagingSenderId: "993354913044",
  appId: "1:993354913044:web:183d87d64966c76f609e01",
  measurementId: "G-PRQMWH0FHH",
);

String getBackendUrl() {
  return "https://sillily-vehicular-cyndy.ngrok-free.dev/translate";
}

final List<Map<String, String>> languages = [
  {"name": "English", "code": "en_US", "trans": "en"},
  {"name": "Hindi", "code": "hi_IN", "trans": "hi"},
  {"name": "Kannada", "code": "kn_IN", "trans": "kn"},
  {"name": "Telugu", "code": "te_IN", "trans": "te"},
  {"name": "Tamil", "code": "ta_IN", "trans": "ta"},
  {"name": "Malayalam", "code": "ml_IN", "trans": "ml"},
  {"name": "Marathi", "code": "mr_IN", "trans": "mr"},
  {"name": "French", "code": "fr_FR", "trans": "fr"},
  {"name": "Spanish", "code": "es_ES", "trans": "es"},
];

class ChatMessage {
  final String sender;
  final String text;
  String? reaction;
  ChatMessage({required this.sender, required this.text, this.reaction});
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MeetingPlatformApp());
}

class MeetingPlatformApp extends StatelessWidget {
  const MeetingPlatformApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff3e1e68),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const RegisterPage(),
    );
  }
}

// =========================== UI PAGES ===========================

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    return Scaffold(
      body: GradientBg(
        child: Center(
          child: Card(
            color: Colors.white.withOpacity(0.95),
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.app_registration,
                      size: 50, color: Color(0xff3e1e68)),
                  const SizedBox(height: 20),
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const TextField(
                    style: TextStyle(color: Colors.black),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3e1e68),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    onPressed: () {
                      if (usernameController.text.isNotEmpty) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(
                              userName: usernameController.text,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(userName: "User"),
                      ),
                    ),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final String userName;
  const LoginPage({super.key, required this.userName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: Center(
          child: Card(
            color: Colors.white.withOpacity(0.95),
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.login,
                      size: 50, color: Color(0xff3e1e68)),
                  const SizedBox(height: 20),
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const TextField(
                    style: TextStyle(color: Colors.black),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3e1e68),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(userName: userName),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    ),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Colors.blue),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final createController = TextEditingController();
  final joinController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      final uri = Uri.base;

      // 1. Normal query param ?roomID=xyz
      String? roomFromQuery = uri.queryParameters['roomID'];

      // 2. If not found, try fragment #/?roomID=xyz
      if (roomFromQuery == null && uri.fragment.isNotEmpty) {
        try {
          final frag = uri.fragment;
          final fragUri = Uri.parse(
            frag.startsWith('/') ? frag : '/$frag',
          );
          roomFromQuery = fragUri.queryParameters['roomID'];
        } catch (_) {}
      }

      if (roomFromQuery != null && roomFromQuery.isNotEmpty) {
        joinController.text = roomFromQuery;
      }
    }
  }

  void _join(BuildContext context, String room, bool isCreator) {
    if (room.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebRTCMeetingPage(
            roomId: room,
            userName: widget.userName,
            isCreator: isCreator,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: Center(
          child: Card(
            color: Colors.white.withOpacity(0.95),
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome, ${widget.userName}!",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3e1e68),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Create Meeting",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: createController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Room Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.add_box),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () =>
                          _join(context, createController.text, true),
                      child: const Text(
                        "Create & Join",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const Divider(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Join Meeting",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: joinController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Room Code",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.login),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () =>
                          _join(context, joinController.text, false),
                      child: const Text(
                        "Join",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================== WEBRTC MEETING PAGE ===========================

class WebRTCMeetingPage extends StatefulWidget {
  final String roomId;
  final String userName;
  final bool isCreator;

  const WebRTCMeetingPage({
    super.key,
    required this.roomId,
    required this.userName,
    required this.isCreator,
  });

  @override
  State<WebRTCMeetingPage> createState() => _WebRTCMeetingPageState();
}

class _WebRTCMeetingPageState extends State<WebRTCMeetingPage> {
  final List<RTCVideoRenderer> _videoRenderers = [];
  final List<String> _participantNames = [];
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final PageController _pageController = PageController();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // State
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isScreenSharing = false;
  bool _isRecording = false;
  bool _showParticipants = false;
  bool _showChat = false;
  bool _showTranslation = false;
  bool _showEmojiPicker = false;

  int _recordSeconds = 0;
  Timer? _recordTimer;
  final List<String> _recordedFiles = [];

  // Translation
  late stt.SpeechToText _speech;
  String _originalText = "Listening...";
  String _translatedText = "Translation...";
  String _sourceLang = "en_US";
  String _targetLang = "hi";
  Timer? _debounce;

  // Chat
  final TextEditingController _chatController = TextEditingController();

  // Firestore participant doc
  String? _myDocId;

  // Translation sync
  StreamSubscription<QuerySnapshot>? _captionsSub;
  final Set<String> _handledCaptionIds = {};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _participantNames.add("${widget.userName} (You)");
    _initWebRTC();
    _joinParticipantList();
    _listenToCaptions();
  }

  Future<void> _joinParticipantList() async {
    // Use username as doc id to avoid duplicate entries
    final ref = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('participants')
        .doc(widget.userName);

    await ref.set(
      {
        'name': widget.userName,
        'mic': _isMicOn,
        'cam': _isCameraOn,
        'joinedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    setState(() => _myDocId = ref.id);
  }

  Future<void> _updateStatusInFirestore() async {
    if (_myDocId != null) {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .collection('participants')
          .doc(_myDocId)
          .update({
        'mic': _isMicOn,
        'cam': _isCameraOn,
      });
    }
  }

  Future<void> _initWebRTC() async {
    await _localRenderer.initialize();
    _videoRenderers.add(_localRenderer);

    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': true});
    _localRenderer.srcObject = _localStream;
    setState(() {});

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
      ]
    });

    _peerConnection!.onTrack = (event) {
      if (event.track.kind == 'video') {
        var remoteRenderer = RTCVideoRenderer();
        remoteRenderer.initialize().then((_) {
          remoteRenderer.srcObject = event.streams[0];
          setState(() {
            _videoRenderers.add(remoteRenderer);
            _participantNames.add("Participant ${_videoRenderers.length}");
          });
        });
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .collection(widget.isCreator ? 'callerCandidates' : 'calleeCandidates')
          .add(candidate.toMap());
    };

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    if (widget.isCreator) {
      await _createRoom();
    } else {
      await _joinRoom();
    }
  }

  Future<void> _createRoom() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .set({'offer': offer.toMap()});

    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots()
        .listen((snapshot) async {
      var data = snapshot.data();
      if (data != null && data.containsKey('answer')) {
        var answer =
            RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
        await _peerConnection!.setRemoteDescription(answer);
      }
    });

    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('calleeCandidates')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data() as Map<String, dynamic>;
          _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });
  }

  Future<void> _joinRoom() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .get();
    if (snapshot.exists) {
      var data = snapshot.data()!;
      var offer = data['offer'];
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .update({'answer': answer.toMap()});

      FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .collection('callerCandidates')
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var data = change.doc.data() as Map<String, dynamic>;
            _peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        }
      });
    }
  }

  void _copyLink() {
    final location = html.window.location;
    String baseUrl = "${location.origin}${location.pathname}";
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    final url = "$baseUrl/?roomID=${widget.roomId}";

    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Meeting Link Copied!")),
    );
  }

  // --- CONTROLS ---
  void _toggleMic() {
    setState(() => _isMicOn = !_isMicOn);
    _localStream?.getAudioTracks()[0].enabled = _isMicOn;
    _updateStatusInFirestore();

    // Only listen when mic ON and translation visible
    if (_isMicOn && _showTranslation) {
      _startListening();
    } else {
      _speech.stop();
    }
  }

  void _toggleCamera() {
    setState(() => _isCameraOn = !_isCameraOn);
    _localStream?.getVideoTracks()[0].enabled = _isCameraOn;
    _updateStatusInFirestore();
  }

  // --- DUMMY RECORDING ---
  void _toggleRecording() {
    if (_isRecording) {
      // Stop recording
      _recordTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stopped recording.")),
      );
    } else {
      // Start dummy recording
      String timestamp =
          DateTime.now().toIso8601String().replaceAll(":", "-").replaceAll(".", "-");
      String fakeFileName = "recording_$timestamp.webm";

      setState(() {
        _isRecording = true;
        _recordedFiles.add(fakeFileName);
      });

      _recordTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            _recordSeconds++;
          });
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recording started: $fakeFileName")),
      );
    }
  }

  void _toggleScreenShare() async {
    if (!_isScreenSharing) {
      try {
        final stream =
            await navigator.mediaDevices.getDisplayMedia({'video': true});
        _localRenderer.srcObject = stream;
        var senders = await _peerConnection!.getSenders();
        var sender = senders.firstWhere((s) => s.track?.kind == 'video');
        sender.replaceTrack(stream.getVideoTracks()[0]);
        setState(() => _isScreenSharing = true);
      } catch (e) {
        print(e);
      }
    } else {
      _localRenderer.srcObject = _localStream;
      var senders = await _peerConnection!.getSenders();
      var sender = senders.firstWhere((s) => s.track?.kind == 'video');
      sender.replaceTrack(_localStream!.getVideoTracks()[0]);
      setState(() => _isScreenSharing = false);
    }
  }

  void _toggleChat() {
    setState(() => _showChat = !_showChat);
  }

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('chat')
        .add({
      'sender': widget.userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'reaction': null,
    });
  }

  void _toggleTranslation() {
    setState(() => _showTranslation = !_showTranslation);

    if (_showTranslation && _isMicOn) {
      _startListening();
    } else {
      _speech.stop();
    }
  }

  // --- TRANSLATION LOGIC ---

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        localeId: _sourceLang,
        onResult: (res) async {
          final text = res.recognizedWords.trim();
          if (text.isEmpty) return;

          // Push original text to Firestore "captions"
          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomId)
              .collection('captions')
              .add({
            'sender': widget.userName,
            'text': text,
            'lang': _sourceLang,
            'timestamp': FieldValue.serverTimestamp(),
          });
        },
        listenFor: const Duration(minutes: 30),
      );
    }
  }

  void _listenToCaptions() {
    _captionsSub = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('captions')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final doc = change.doc;
          if (_handledCaptionIds.contains(doc.id)) continue;
          _handledCaptionIds.add(doc.id);

          final data = doc.data() as Map<String, dynamic>;
          final text = data['text'] as String? ?? '';
          if (text.isEmpty) continue;

          // Show only if user enabled translation bar
          if (!_showTranslation) continue;

          setState(() {
            _originalText = text;
          });

          _runTranslation(text);
        }
      }
    });
  }

  Future<void> _runTranslation(String text) async {
    try {
      final resp = await http.post(
        Uri.parse(getBackendUrl()),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "target_lang": _targetLang,
          "source_lang": "auto",
        }),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (mounted) {
          setState(() {
            _translatedText = data["translated"] ?? "";
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return "${h.toString().padLeft(2, '0')}:"
        "${m.toString().padLeft(2, '0')}:"
        "${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    for (var r in _videoRenderers) {
      r.dispose();
    }
    _peerConnection?.close();
    _speech.stop();
    _recordTimer?.cancel();
    _captionsSub?.cancel();

    if (_myDocId != null) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .collection('participants')
          .doc(_myDocId)
          .delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int itemsPerPage = 6;
    int totalPages = (_videoRenderers.length / itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    return Scaffold(
      body: Stack(
        children: [
          // 1. VIDEO GRID
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 60, 10, 180),
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              itemBuilder: (context, pageIndex) {
                int start = pageIndex * itemsPerPage;
                int end = min(start + itemsPerPage, _videoRenderers.length);
                var pageRenderers = _videoRenderers.sublist(start, end);

                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 16 / 9,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: pageRenderers.length,
                  itemBuilder: (ctx, idx) =>
                      _buildVideoTile(pageRenderers[idx], start + idx),
                );
              },
            ),
          ),

          // 2. TOP BAR: Link, Recording, Participants dropdown
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: _copyLink,
                        icon: const Icon(Icons.link,
                            color: Colors.white, size: 18),
                        label: const Text(
                          "Copy Link",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _isRecording
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatTime(_recordSeconds),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _recordedFiles.isNotEmpty
                              ? PopupMenuButton<String>(
                                  icon: const Row(
                                    children: [
                                      Icon(Icons.folder_copy,
                                          color: Colors.white),
                                      SizedBox(width: 5),
                                      Text(
                                        "Recordings",
                                        style:
                                            TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  color: Colors.grey[900],
                                  itemBuilder: (ctx) => _recordedFiles
                                      .map(
                                        (f) => PopupMenuItem<String>(
                                          value: f,
                                          child: Text(
                                            f,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : const SizedBox(),
                    ],
                  ),

                  // Participants dropdown
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(widget.roomId)
                        .collection('participants')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final rawDocs = snapshot.data?.docs ?? [];

                      // Deduplicate by 'name'
                      final Map<String, QueryDocumentSnapshot> byName = {};
                      for (var d in rawDocs) {
                        final data =
                            d.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] as String?) ?? 'Unknown';
                        byName[name] = d;
                      }
                      final docs = byName.values.toList();

                      return PopupMenuButton<String>(
                        color: Colors.grey[900],
                        offset: const Offset(0, 40),
                        onSelected: (value) {
                          if (value == 'panel') {
                            setState(() {
                              _showParticipants = true;
                            });
                          }
                        },
                        itemBuilder: (context) {
                          final items = <PopupMenuEntry<String>>[];

                          items.add(
                            const PopupMenuItem<String>(
                              enabled: false,
                              value: '',
                              child: Text(
                                "Participants",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );

                          items.add(const PopupMenuDivider());

                          if (docs.isEmpty) {
                            items.add(
                              const PopupMenuItem<String>(
                                enabled: false,
                                value: '',
                                child: Text(
                                  "No participants yet",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            );
                          } else {
                            for (var doc in docs) {
                              final data = doc.data() as Map<String, dynamic>;
                              items.add(
                                PopupMenuItem<String>(
                                  enabled: false,
                                  value: '',
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['name'],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            data['mic']
                                                ? Icons.mic
                                                : Icons.mic_off,
                                            color: data['mic']
                                                ? Colors.green
                                                : Colors.red,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            data['cam']
                                                ? Icons.videocam
                                                : Icons.videocam_off,
                                            color: data['cam']
                                                ? Colors.green
                                                : Colors.red,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }

                          items.add(const PopupMenuDivider());
                          items.add(
                            const PopupMenuItem<String>(
                              value: 'panel',
                              child: Text(
                                "Open full panel",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );

                          return items;
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              "${docs.length}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. TRANSLATION BAR
          if (_showTranslation)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: _sourceLang,
                          dropdownColor: Colors.grey[900],
                          style:
                              const TextStyle(color: Colors.white),
                          items: languages
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l['code'],
                                  child: Text(l['name']!),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _sourceLang = v!),
                        ),
                        const Icon(Icons.arrow_forward,
                            color: Colors.white54),
                        DropdownButton<String>(
                          value: _targetLang,
                          dropdownColor: Colors.grey[900],
                          style:
                              const TextStyle(color: Colors.white),
                          items: languages
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l['trans'],
                                  child: Text(l['name']!),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _targetLang = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _originalText,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      _translatedText,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. PARTICIPANT SIDE PANEL
          if (_showParticipants)
            Positioned(
              top: 70,
              right: 20,
              width: 280,
              child: Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(widget.roomId)
                        .collection('participants')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final rawDocs = snapshot.data!.docs;
                      final Map<String, QueryDocumentSnapshot> byName = {};
                      for (var d in rawDocs) {
                        final data =
                            d.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] as String?) ?? 'Unknown';
                        byName[name] = d;
                      }
                      final docs = byName.values.toList();

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Participants (${docs.length})",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _showParticipants = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24),
                          ...docs.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "https://api.dicebear.com/9.x/notionists/png?seed=${data['name']}",
                                ),
                              ),
                              title: Text(
                                data['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    data['mic']
                                        ? Icons.mic
                                        : Icons.mic_off,
                                    color: data['mic']
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    data['cam']
                                        ? Icons.videocam
                                        : Icons.videocam_off,
                                    color: data['cam']
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

          // 5. CHAT BOX (Firestore-backed)
          if (_showChat)
            Positioned(
              bottom: 200,
              right: 20,
              width: 350,
              height: 450,
              child: Card(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xff3e1e68),
                      child: const Row(
                        children: [
                          Text(
                            "Chat",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(widget.roomId)
                            .collection('chat')
                            .orderBy('timestamp')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          return ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: docs.length,
                            itemBuilder: (ctx, i) {
                              final doc = docs[i];
                              final data =
                                  doc.data() as Map<String, dynamic>;
                              final sender = data['sender'] ?? 'Unknown';
                              final text = data['text'] ?? '';
                              final reaction = data['reaction'] as String?;

                              return ListTile(
                                title: Text(
                                  sender,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                subtitle: Text(
                                  text,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (reaction != null)
                                      Text(
                                        reaction,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.add_reaction,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      onSelected: (emoji) {
                                        doc.reference
                                            .update({'reaction': emoji});
                                      },
                                      itemBuilder: (ctx) => [
                                        "👍",
                                        "❤️",
                                        "😂",
                                        "😮",
                                      ]
                                          .map(
                                            (e) =>
                                                PopupMenuItem<String>(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions),
                            onPressed: () => setState(
                              () => _showEmojiPicker = !_showEmojiPicker,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: "Type message...",
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.blue,
                            ),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                    if (_showEmojiPicker)
                      SizedBox(
                        height: 200,
                        child: EmojiPicker(
                          config: const Config(
                            emojiViewConfig: EmojiViewConfig(columns: 7),
                          ),
                          onEmojiSelected: (category, emoji) {
                            _chatController.text += emoji.emoji;
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // 6. BOTTOM CONTROLS
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF202124),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlBtn(
                    icon: Icons.mic,
                    bg: _isMicOn ? Colors.white : Colors.red,
                    fg: _isMicOn ? Colors.blue : Colors.white,
                    onTap: _toggleMic,
                  ),
                  const SizedBox(width: 15),
                  _controlBtn(
                    icon: Icons.videocam,
                    bg: _isCameraOn ? Colors.white : Colors.red,
                    fg: _isCameraOn ? Colors.blue : Colors.white,
                    onTap: _toggleCamera,
                  ),
                  const SizedBox(width: 15),
                  _controlBtn(
                    icon: Icons.closed_caption,
                    bg: _showTranslation ? Colors.green : Colors.white,
                    fg: _showTranslation ? Colors.white : Colors.blue,
                    onTap: _toggleTranslation,
                  ),
                  const SizedBox(width: 15),
                  _controlBtn(
                    icon: Icons.screen_share,
                    bg: _isScreenSharing ? Colors.blue : Colors.white,
                    fg: _isScreenSharing ? Colors.white : Colors.blue,
                    onTap: _toggleScreenShare,
                  ),
                  const SizedBox(width: 15),
                  _controlBtn(
                    icon: Icons.chat_bubble,
                    bg: _showChat ? Colors.blue : Colors.white,
                    fg: Colors.white,
                    onTap: _toggleChat,
                  ),
                  const SizedBox(width: 15),
                  _controlBtn(
                    icon: Icons.fiber_manual_record,
                    bg: Colors.white,
                    fg: Colors.red,
                    onTap: _toggleRecording,
                  ),
                  const SizedBox(width: 15),
                  _controlBtn(
                    icon: Icons.call_end,
                    bg: Colors.red,
                    fg: Colors.white,
                    onTap: () {
                      _localRenderer.dispose();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTile(RTCVideoRenderer renderer, int index) {
    bool isLocal = (index == 0);
    bool showVideo;

    if (isLocal) {
      showVideo = _isCameraOn;
    } else {
      final stream = renderer.srcObject;
      final tracks = stream?.getVideoTracks() ?? [];
      if (tracks.isEmpty) {
        showVideo = false;
      } else {
        // If all remote video tracks are disabled or muted, show avatar
        showVideo = tracks.any((t) => t.enabled && !(t.muted ?? false));
      }
    }

    String label =
        isLocal ? "${widget.userName} (You)" : _participantNames[index];

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: Colors.grey[900],
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showVideo)
              RTCVideoView(
                renderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: isLocal,
              )
            else
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.amber.shade100,
                  backgroundImage: NetworkImage(
                    "https://api.dicebear.com/9.x/notionists/png?seed=$label",
                  ),
                ),
              ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: bg,
        onPressed: onTap,
        child: Icon(icon, color: fg),
      ),
    );
  }
}

class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3e1e68), Color(0xfffb6b6b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
