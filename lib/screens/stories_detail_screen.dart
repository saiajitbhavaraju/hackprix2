// lib/screens/stories_detail_screen.dart
// FINAL AND CORRECTED VERSION

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/providers/stories_provider.dart';

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const StoryDetailScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  // NOTE: This now gets the provider once and shows user feedback.
  Future<void> _handleBuyAction(BuildContext context) async {
    // We use the context to find the provider.
    final provider = Provider.of<StoriesProvider>(context, listen: false);
    
    // Prevent action if a purchase is already in progress.
    if (provider.isBuying) return;

    final itemId = widget.item['itemId'] as String?;
    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Item ID is missing.'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await provider.buyStory(itemId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully purchased ${widget.item['name']}!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.item['imageUrl'] as String?;
    
    // We use a Consumer here to rebuild the button when 'isBuying' changes.
    return Consumer<StoriesProvider>(
      builder: (context, storiesProvider, child) {
        return Scaffold(
          backgroundColor: white,
          body: CustomScrollView(
            slivers: [
              // Your SliverAppBar and other UI elements remain unchanged.
              SliverAppBar(
                expandedHeight: 400.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // All text and info display remains unchanged.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.item['name'] ?? 'Story Title',
                              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          Text(
                            '\$${widget.item['cost']}',
                            style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        widget.item['description'] ?? 'No description available.',
                        style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Posted by:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.person, color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            widget.item['postedBy'] ?? 'Anonymous',
                            style: const TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // NOTE: Button is disabled and shows a loader when buying.
                          onPressed: storiesProvider.isBuying ? null : () => _handleBuyAction(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                          child: storiesProvider.isBuying
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  'Contact Storyteller', // Text remains the same.
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}