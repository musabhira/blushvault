import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JewelryLayoutWidget extends StatefulWidget {
  const JewelryLayoutWidget({super.key});

  @override
  State<JewelryLayoutWidget> createState() => _JewelryLayoutWidgetState();
}

class _JewelryLayoutWidgetState extends State<JewelryLayoutWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  List<CollectionItem> collections = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: 0,
    );
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        int next = _pageController.page!.round();
        if (_currentPage != next) {
          setState(() {
            _currentPage = next;
          });
        }
      }
    });
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      final response = await Supabase.instance.client
          .from('collections')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      setState(() {
        collections = (response as List)
            .map((item) => CollectionItem.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load collections: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    // Dynamically update viewportFraction if screen size changes
    if (_pageController.viewportFraction != (isMobile ? 0.8 : 0.35)) {
      final oldPage = _currentPage;
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: isMobile ? 0.8 : 0.35,
        initialPage: oldPage,
      )..addListener(() {
          if (_pageController.hasClients && _pageController.page != null) {
            int next = _pageController.page!.round();
            if (_currentPage != next) {
              setState(() {
                _currentPage = next;
              });
            }
          }
        });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 80),

        // Header - Left Aligned for Asymmetric Look
        Padding(
          padding: EdgeInsets.only(left: isMobile ? 24 : 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FOR EVERY YOU',
                style: GoogleFonts.lato(
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 3,
                width: 40,
                color: const Color(0xFFB08D63),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Loading, Error, or Carousel
        if (isLoading)
          SizedBox(
            height: isMobile ? 450 : 600,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB08D63),
              ),
            ),
          )
        else if (errorMessage != null)
          SizedBox(
            height: isMobile ? 450 : 600,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      _loadCollections();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (collections.isEmpty)
          SizedBox(
            height: isMobile ? 450 : 600,
            child: const Center(
              child: Text('No collections available'),
            ),
          )
        else
          SizedBox(
            height: isMobile ? 450 : 600,
            child: PageView.builder(
              controller: _pageController,
              itemCount: collections.length,
              padEnds: false,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                    }

                    return Transform.translate(
                      offset: Offset(isMobile ? 0 : -40 * value, 0),
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: CollectionCard(
                    item: collections[index],
                    isActive: _currentPage == index,
                  ),
                );
              },
            ),
          ),

        // Navigation Arrows
        // if (!isLoading && collections.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 40),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         IconButton(
        //           onPressed: () {
        //             if (_currentPage > 0) {
        //               _pageController.previousPage(
        //                 duration: const Duration(milliseconds: 400),
        //                 curve: Curves.easeInOutCubic,
        //               );
        //             }
        //           },
        //           icon: const Icon(Icons.arrow_back_ios_new_rounded),
        //           iconSize: 24,
        //           color: Colors.black54,
        //         ),
        //         IconButton(
        //           onPressed: () {
        //             if (_currentPage < collections.length - 1) {
        //               _pageController.nextPage(
        //                 duration: const Duration(milliseconds: 400),
        //                 curve: Curves.easeInOutCubic,
        //               );
        //             }
        //           },
        //           icon: const Icon(Icons.arrow_forward_ios_rounded),
        //           iconSize: 24,
        //           color: Colors.black54,
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}

class CollectionItem {
  final String id;
  final String title;
  final String imageUrl;
  final Color color;
  final int displayOrder;

  CollectionItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.color,
    required this.displayOrder,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      color: _parseColor(json['color'] as String),
      displayOrder: json['display_order'] as int,
    );
  }

  static Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class CollectionCard extends StatefulWidget {
  final CollectionItem item;
  final bool isActive;

  const CollectionCard({
    Key? key,
    required this.item,
    required this.isActive,
  }) : super(key: key);

  @override
  State<CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<CollectionCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovered ? 0.25 : 0.15),
              blurRadius: isHovered ? 30 : 20,
              offset: Offset(0, isHovered ? 15 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              AnimatedScale(
                scale: isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: Image.network(
                  widget.item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: widget.item.color,
                    );
                  },
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),

              // Title
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      width: isHovered ? 100 : 60,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
