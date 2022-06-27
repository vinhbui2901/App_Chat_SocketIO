// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    _connectToServer();
    _messageController.addListener(() {
      sendTyping(true);
    });
    super.initState();
  }

  void _connectToServer() {
    try {
      socket = IO.io('http://192.168.0.1:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      // connect to web socket
      socket.connect();

      // handle socket events

      socket.on('connect', (data) => print('hoan.dv: connect ${socket.id}'));
      socket.on('location', (data) => null);
      socket.on('typing', (data) => handleTyping(data));
      socket.on('message', (data) => handleMessage(data));
      socket.on('disconnect', (_) => print('disconnect'));
      socket.on('fromServer', (_) => print(_));
    } catch (e) {
      if (kDebugMode) {
        print('hoan.dv: socket connect error ${e.toString()}');
      }
    }
  }

  // Send Location to Server
  sendLocation(Map<String, dynamic> data) {
    socket.emit("location", data);
  }

  // Listen to Location updates of connected usersfrom server
  handleLocationListen(Map<String, dynamic> data) async {
    print(data);
  }

  // Send update of user's typing status
  sendTyping(bool typing) {
    socket.emit("typing", {
      "id": socket.id,
      "typing": typing,
    });
  }

  // Send a Message to the server
  sendMessage(String message) {
    socket.emit(
      "message",
      {
        "id": socket.id,
        "message": message, // Message to be sent
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Listen to all message events from connected users
  void handleMessage(Map<String, dynamic> data) {
    print('hoan.dv: handle message: $data');
  }

  handleTyping(Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('hoan.dv: handle typing: $data');
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      socket.dispose();
    } else {
      socket.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ListView.builder(
                // physics: const NeverScrollableScrollPhysics(),
                // shrinkWrap: true,
                itemCount: 0,
                itemBuilder: (_, index) {
                  return const Text('aa');
                },
              ),
            ),
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.green),
                      ),
                      onEditingComplete: () {
                        sendTyping(false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      sendMessage(_messageController.text);
                      _messageController.clear();
                    },
                    child: const Icon(
                      Icons.send_outlined,
                      size: 42,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
