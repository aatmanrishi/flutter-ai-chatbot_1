import 'dart:convert'; // Importing Dart's JSON library for encoding and decoding JSON
import 'package:dash_chat_2/dash_chat_2.dart'; // Importing chat library
import 'package:flutter/material.dart'; // Importing Flutter material package
import 'package:http/http.dart'
    as http; // Importing HTTP package for network requests
import 'dart:async'; // Importing Dart's async library for timers

// Main widget for the chat application
class Walle extends StatefulWidget {
  const Walle({super.key});

  @override
  State<Walle> createState() => _WalleState();
}

class _WalleState extends State<Walle> {
  // Your Google API key for the Gemini model
  final String apiKey = 'AIzaSyAm5ooB9j7c-r3n2l2-vAM-LrKqOUSmV-M';

  // URL for the API endpoint
  late final String url; // Declare url as a late final variable

  // HTTP headers for the API request
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  // User information for the current user and the bot
  ChatUser myself = ChatUser(
    id: '1',
    firstName: 'Sarthak',
  );

  ChatUser walle = ChatUser(
    id: '2',
    firstName: 'Walle',
  );

  // List to hold all chat messages
  List<ChatMessage> allMessages = <ChatMessage>[];

  // List to track typing users
  List<ChatUser> typing_ = <ChatUser>[];

  // Timer to manage typing indicator duration
  Timer? typingTimer;

  // Constructor to initialize the url
  _WalleState() {
    url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey';
  }

  // Function to send a message and get a response from the API
  Future<void> getData(ChatMessage m) async {
    // Add Walle to the typing list
    typing_.add(walle);
    setState(() {}); // Update the UI to show typing indicator

    // Insert the current message at the start of the list
    allMessages.insert(0, m);

    // Prepare data for the API request
    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    // Send the POST request to the API
    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(data));

      // Check if the request was successful
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        // Extract the bot's response from the API result
        String botResponse =
            result["candidates"][0]['content']['parts'][0]['text'];

        // Create a new message for the bot's response
        ChatMessage m2 = ChatMessage(
            user: walle, createdAt: DateTime.now(), text: botResponse);

        // Insert the bot's message at the start of the list
        allMessages.insert(0, m2);
      } else {
        print('Error occurred: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }

    // Use a timer to remove Walle from typing users after a delay
    typingTimer?.cancel(); // Cancel any existing timer
    typingTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        typing_.remove(walle);
      });
    });

    // Update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text('GOOGLE GEMEINI'),
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      body: DashChat(
        typingUsers: typing_,
        currentUser: myself,
        onSend: (ChatMessage m) {
          getData(m); // Call getData to handle the message sending
        },
        messages: allMessages,
        inputOptions: InputOptions(
          alwaysShowSend: true,
          cursorStyle: CursorStyle(color: Colors.black),
        ),
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.black,
          avatarBuilder: yourAvatarBuilder,
        ),
      ),
    );
  }

  // Function to build the avatar for the chat user
  Widget yourAvatarBuilder(
      ChatUser user, Function? onAvatarTap, Function? onAvatarLongPress) {
    return Center(
      child: Image.asset(
        'assets/images/Wall.E.png', // Path to the user's avatar image
        height: 40,
        width: 40,
      ),
    );
  }
}
