import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart'; // We will mock this for UI consistency

import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/data/stories_json.dart';
import 'package:ecosnap_1/screens/stories_detail_screen.dart';
import 'package:page_transition/page_transition.dart';

// --- Dummy AuthService and MarketplaceProvider for UI compilation ---
// These classes are here purely to satisfy the Provider.of calls for UI structure.
// They do not perform any actual authentication or data fetching.
class DummyAuthService {
  Future<void> signOut() async {
    print('Dummy sign out called');
  }
}

class DummyMarketplaceProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _items = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get items => _items;

  DummyMarketplaceProvider() {
    _items =
        stories_data.map((story) {
          return {
            'imageUrl': story['img'],
            'name': story['name'],
            'cost':
                'FREE', // Stories don't have a cost, so we set a dummy value
            'description': story['date'], // Using date as description for now
            // Add other fields from stories_data if needed
            'videoUrl': story['videoUrl'],
          };
        }).toList();
  }

  void fetchItems() {
    // In a real scenario, this would fetch data.
    // Here, we already populate _items in the constructor.
    print('Dummy fetchItems called');
  }
}
// --- End Dummy Classes ---

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All',
    'Trending',
    'Nature',
    'Travel',
    'Lifestyle',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We don't actually need to fetch anything here for stories,
      // as the data is local (stories_json.dart)
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use a MultiProvider to inject the dummy providers for UI consistency
    // with MarketplaceScreen, even though they don't perform real operations here.
    return MultiProvider(
      providers: [
        Provider<DummyAuthService>(create: (_) => DummyAuthService()),
        ChangeNotifierProvider<DummyMarketplaceProvider>(
          create: (_) => DummyMarketplaceProvider(),
        ),
      ],
      child: Scaffold(
        backgroundColor:
            white, // Assuming 'white' is defined in your colors.dart
        appBar: AppBar(
          toolbarHeight: 120,
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
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20.0,
                            ),
                          ),
                          onSubmitted: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Searching for stories: $value'),
                              ),
                            );
                          },
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Filter functionality not yet implemented for stories.',
                                ),
                              ),
                            );
                          },
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
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selected story category: ${_categories[index]}',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 8.0,
                            ),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.red[600]
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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
          actions: [
            Builder(
              builder: (context) {
                // We access the dummy authService here for UI consistency,
                // but its signOut method is a no-op.
                final dummyAuthService = Provider.of<DummyAuthService>(
                  context,
                  listen: false,
                );
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await dummyAuthService.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dummy logout called.')),
                    );
                  },
                  color: Colors.black,
                );
              },
            ),
          ],
        ),
        body: Consumer<DummyMarketplaceProvider>(
          builder: (context, dummyMarketplace, child) {
            if (dummyMarketplace.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (dummyMarketplace.errorMessage != null) {
              return Center(child: Text(dummyMarketplace.errorMessage!));
            }

            if (dummyMarketplace.items.isEmpty) {
              return const Center(child: Text('No stories found.'));
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: dummyMarketplace.items.length,
                  itemBuilder: (context, index) {
                    final item = dummyMarketplace.items[index];
                    final imageUrl = item['imageUrl'] as String?;
                    final randomHeight =
                        140 + (index % 3) * 20; // Maintain varied heights

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageTransition(
                            type: PageTransitionType.scale,
                            alignment: Alignment.bottomCenter,
                            child: StoryDetailScreen(
                              videoUrl:
                                  item['videoUrl'], // Use the videoUrl from the mapped item
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageUrl != null &&
                                    Uri.tryParse(imageUrl)?.hasAbsolutePath ==
                                        true
                                ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: randomHeight.toDouble(),
                                  placeholder:
                                      (context, url) => Container(
                                        height: randomHeight.toDouble(),
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        height: randomHeight.toDouble(),
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                )
                                : Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${item['cost']}', // Dummy cost for UI consistency
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.star_border,
                                          color: Colors.grey[700],
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Added ${item['name']} to favorites!',
                                              ),
                                            ),
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    item['name'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    item['description'] ?? 'No Description',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
