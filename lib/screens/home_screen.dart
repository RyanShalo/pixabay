import 'package:flutter/material.dart';
import 'package:pixabay_app/services/pixabay_services.dart';
import '../models/pixabay_image.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PixabayService _service = PixabayService();
  final TextEditingController _searchController = TextEditingController();
  List<PixabayImage> _images = [];
  bool _isLoading = true;
  String? _error;
  String _currentSearch = '';
  MediaType _selectedType = MediaType.images;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadImages({String? searchQuery}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final images =
          await _service.fetchTrendingImages(searchQuery: searchQuery);
      setState(() {
        _images = images;
        _isLoading = false;
        _currentSearch = searchQuery ?? '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) {
      _loadImages();
    } else {
      _loadImages(searchQuery: query.trim());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _loadImages();
  }

  void _showImageDialog(PixabayImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image.largeImageURL,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMediaTypeChanged(MediaType type) {
    setState(() {
      _selectedType = type;
    });
    if (type == MediaType.videos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Videos coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar (only on desktop)
          if (isDesktop)
            Sidebar(
              selectedType: _selectedType,
              onTypeSelected: _onMediaTypeChanged,
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Title and Search Row
                      Row(
                        children: [
                          if (!isDesktop)
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: const Color(0xFF16213e),
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.image,
                                              color: Colors.white),
                                          title: const Text('Images',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          selected:
                                              _selectedType == MediaType.images,
                                          selectedTileColor:
                                              const Color(0xFFe94560),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _onMediaTypeChanged(
                                                MediaType.images);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.video_library,
                                              color: Colors.white),
                                          title: const Text('Videos (Soon)',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _onMediaTypeChanged(
                                                MediaType.videos);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (!isDesktop) const SizedBox(width: 8),
                          const Text(
                            'Pixabay Gallery',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _onSearchSubmitted,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText:
                                    'Search images... (e.g., "nature", "cars")',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white70),
                                suffixIcon: _currentSearch.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.white70),
                                        onPressed: _clearSearch,
                                      )
                                    : null,
                                filled: true,
                                fillColor: const Color(0xFF0f3460),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () =>
                                _onSearchSubmitted(_searchController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe94560),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Search',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Results count
                if (!_isLoading && _error == null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentSearch.isEmpty
                              ? 'Showing ${_images.length} trending images'
                              : 'Found ${_images.length} results for "$_currentSearch"',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        if (_currentSearch.isNotEmpty)
                          TextButton.icon(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFe94560),
                            ),
                          ),
                      ],
                    ),
                  ),
                // Image Grid
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading images',
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please check your internet connection',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _loadImages(
                                        searchQuery: _currentSearch.isEmpty
                                            ? null
                                            : _currentSearch),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _images.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported,
                                          size: 64, color: Colors.grey[600]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No images found',
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 18),
                                      ),
                                      if (_currentSearch.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Try a different search term',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        _getCrossAxisCount(context),
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemCount: _images.length,
                                  itemBuilder: (context, index) {
                                    final image = _images[index];
                                    return GestureDetector(
                                      onTap: () => _showImageDialog(image),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              image.previewURL,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black
                                                        .withOpacity(0.7),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 8,
                                              left: 8,
                                              right: 8,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    image.user,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.favorite,
                                                          color: Colors.red,
                                                          size: 14),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${image.likes}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Icon(
                                                          Icons.visibility,
                                                          color: Colors.blue,
                                                          size: 14),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${image.views}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1600) return 5;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 2;
  }
}