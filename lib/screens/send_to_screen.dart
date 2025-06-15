// lib/screens/send_to_screen.dart
// NO CHANGES WERE NEEDED FOR THIS FILE.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/data/chat_json.dart';
import 'package:ecosnap_1/models/snap_model.dart';
import 'package:ecosnap_1/services/snap_state_service.dart';
import 'package:ecosnap_1/screens/home_page_screen.dart';

class SendToScreen extends StatefulWidget {
  final String imagePath;

  const SendToScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _SendToScreenState createState() => _SendToScreenState();
}

class _SendToScreenState extends State<SendToScreen> {
  final Set<String> _selectedUsers = {};
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onUserSelected(String userName) {
    if (_isSending) return;
    setState(() {
      if (_selectedUsers.contains(userName)) {
        _selectedUsers.remove(userName);
      } else {
        _selectedUsers.add(userName);
      }
    });
  }

  Future<void> _sendSnap() async {
    if (_selectedUsers.isEmpty || _isSending) {
      if (!_isSending) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one friend.")),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    final newSnap = Snap(
      imagePath: widget.imagePath,
      userDescription: _descriptionController.text.trim(),
    );

    await SnapStateService.instance.addSnap(_selectedUsers, newSnap);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePageScreen(initialPageIndex: 1)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Send To...", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Add a description (optional)...',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Friends", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chat_data.length,
              itemBuilder: (context, index) {
                final user = chat_data[index];
                final isSelected = _selectedUsers.contains(user['name']);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  onTap: () => _onUserSelected(user['name']),
                  leading: CircleAvatar(backgroundImage: NetworkImage(user['img']), radius: 25),
                  title: Text(user['name']),
                  subtitle: Text(user['nickname']),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? blue : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendSnap,
        backgroundColor: _selectedUsers.isNotEmpty && !_isSending ? blue : Colors.grey,
        icon: _isSending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
        label: Text(_isSending ? "Sending..." : "Send"),
      ),
    );
  }
}