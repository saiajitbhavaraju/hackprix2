// lib/screens/home_page_screen.dart
// NO CHANGES WERE NEEDED FOR THIS FILE.

import 'package:flutter/material.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/screens/camera_screen.dart';
import 'package:ecosnap_1/screens/chat_screen.dart';
import 'package:ecosnap_1/screens/discovery_screen.dart';
import 'package:ecosnap_1/screens/map_screen.dart';
import 'package:ecosnap_1/screens/stories_screen.dart';

class HomePageScreen extends StatefulWidget {
  final int initialPageIndex;
  const HomePageScreen({Key? key, this.initialPageIndex = 2}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _pageIndex;

  final List<Widget> _pages = [
    const MapScreen(),
    const ChatScreen(),
    const CameraScreen(),
    const StoriesScreen(),
    const DiscoverScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialPageIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.map_outlined, 'text': 'Map', 'color': green},
      {'icon': Icons.chat_bubble_outline, 'text': 'Chat', 'color': blue},
      {'icon': Icons.camera_alt_outlined, 'text': 'Camera', 'color': primary},
      {'icon': Icons.people_outline, 'text': 'Stories', 'color': purple},
      {'icon': Icons.menu, 'text': 'Discover', 'color': primary},
    ];

    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(width: 1, color: Colors.white12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final bool isSelected = _pageIndex == index;

            return _buildNavItem(
              icon: item['icon'],
              text: item['text'],
              color: item['color'],
              isSelected: isSelected,
              onTap: () => _onTabTapped(index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String text,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final itemColor = isSelected ? color : Colors.white.withOpacity(0.5);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: itemColor),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: itemColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}