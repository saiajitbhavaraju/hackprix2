// lib/screens/stories_screen.dart
// FINAL AND CORRECTED - FIXES DATA FETCHING

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';

import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/screens/stories_detail_screen.dart';
import 'package:ecosnap_1/providers/stories_provider.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Trending', 'Nature', 'Travel', 'Lifestyle'];

  // NOTE: The initState method has been REMOVED as it was causing the issue.

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We now call .fetchStories() right when the provider is created.
    // The '..' is cascade notation, a clean way to do this.
    return ChangeNotifierProvider<StoriesProvider>(
      create: (_) => StoriesProvider()..fetchStories(), // THIS IS THE FIX
      child: Scaffold(
        backgroundColor: white,
        appBar: _buildAppBar(),
        body: Consumer<StoriesProvider>(
          builder: (context, storiesProvider, child) {
            if (storiesProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (storiesProvider.errorMessage != null) {
              return Center(child: Text('Error: ${storiesProvider.errorMessage}'));
            }

            if (storiesProvider.items.isEmpty) {
              return const Center(child: Text('No stories found.'));
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: storiesProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = storiesProvider.items[index];
                    final imageUrl = item['imageUrl'] as String?;
                    final randomHeight = 140 + (index % 3) * 20;

                    return _buildStoryCard(context, item, imageUrl, randomHeight);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // NOTE: The rest of the file (helper methods for UI) remains the same.
  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 120,
      backgroundColor: white,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search stories',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 35.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red[600] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, Map<String, dynamic> item, String? imageUrl, int height) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.bottomCenter,
            // We must wrap the destination screen with the same provider
            // so it can access the 'buyStory' method.
            child: ChangeNotifierProvider.value(
              value: Provider.of<StoriesProvider>(context, listen: false),
              child: StoryDetailScreen(
                item: item,
              ),
            ),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: height.toDouble(),
                placeholder: (context, url) => Container(
                  height: height.toDouble(),
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: height.toDouble(),
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                ),
              )
            else
              Container(
                height: height.toDouble(),
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "\$${item['cost']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}