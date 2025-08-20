import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/education_provider.dart';

class ProductsGuideScreen extends StatefulWidget {
  const ProductsGuideScreen({super.key});

  @override
  State<ProductsGuideScreen> createState() => _ProductsGuideScreenState();
}

class _ProductsGuideScreenState extends State<ProductsGuideScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final educationProvider = Provider.of<EducationProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink, Colors.purple],
            ),
          ),
        ),
        title: Text(
          'Period Products Guide',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProductsFromFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load products',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products available',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return _buildProductCard(product, theme, educationProvider);
                  }, childCount: products.length),
                ),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product,
    ThemeData theme,
    EducationProvider educationProvider,
  ) {
    final colorValue =
        int.tryParse(product['color'] ?? '0xFFE91E63') ?? 0xFFE91E63;
    final productColor = Color(colorValue);

    return GestureDetector(
      onTap: () => _showProductDetails(product, educationProvider),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: productColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: productColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and rating
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    productColor.withOpacity(0.1),
                    productColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: productColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getProductIcon(product['type']),
                      color: productColor,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${product['rating'] ?? 4.5}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product['category'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: productColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        product['description'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Learn More',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: productColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: productColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pad':
        return Icons.favorite;
      case 'tampon':
        return Icons.circle;
      case 'cup':
        return Icons.local_drink;
      case 'disc':
        return Icons.album;
      case 'liner':
        return Icons.rectangle;
      default:
        return Icons.health_and_safety;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProductsFromFirebase() async {
    try {
      // TODO: Replace with actual Firebase Firestore query
      // This is a mock implementation for now
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      return [
        {
          'id': '1',
          'name': 'Organic Cotton Pads',
          'category': 'Pads',
          'type': 'pad',
          'rating': 4.8,
          'color': '0xFFE91E63',
          'description':
              'Ultra-soft organic cotton pads for maximum comfort and protection.',
          'instructions':
              'Remove adhesive backing and place sticky side down on underwear. Change every 4-6 hours.',
          'features': [
            'Biodegradable',
            'Hypoallergenic',
            'Super Absorbent',
            'Comfortable Fit',
          ],
          'sizes': ['Regular', 'Super', 'Overnight'],
        },
        {
          'id': '2',
          'name': 'Menstrual Cup',
          'category': 'Cups',
          'type': 'cup',
          'rating': 4.9,
          'color': '0xFF9C27B0',
          'description': 'Eco-friendly silicone cup that lasts up to 12 hours.',
          'instructions':
              'Fold cup, insert like a tampon, ensure it opens fully. Empty every 4-12 hours.',
          'features': [
            'Medical Grade Silicone',
            'Reusable',
            'Leak-proof',
            'Eco-friendly',
          ],
          'sizes': ['Small', 'Large'],
        },
        {
          'id': '3',
          'name': 'Super Tampons',
          'category': 'Tampons',
          'type': 'tampon',
          'rating': 4.6,
          'color': '0xFF673AB7',
          'description':
              'High-absorbency tampons with applicator for heavy days.',
          'instructions': '''• Wash hands thoroughly before and after use
• Remove tampon from applicator packaging
• Hold applicator grip with thumb and middle finger
• Insert gently at a 45-degree angle towards your back
• Push inner tube until your fingers touch your body
• Pull out applicator, leaving string outside
• Change every 4-8 hours (never exceed 8 hours)
• To remove: relax and gently pull the string downward
• Dispose of tampon in trash (never flush)

⚠️ Important Safety Warning:
Tampons are associated with Toxic Shock Syndrome (TSS), a rare but serious condition. Always use the lowest absorbency needed and never leave a tampon in for more than 8 hours.''',
          'features': [
            'Comfortable Applicator',
            'High Absorbency',
            'TSS Safety Guidelines',
            'Easy Removal String',
          ],
          'sizes': ['Regular', 'Super', 'Super Plus'],
        },
        {
          'id': '4',
          'name': 'Period Disc',
          'category': 'Discs',
          'type': 'disc',
          'rating': 4.7,
          'color': '0xFF3F51B5',
          'description':
              'Flexible disc that sits at the vaginal fornix for 12-hour wear.',
          'instructions':
              'Fold disc, insert and push back to sit behind pubic bone. Can be worn during intercourse.',
          'features': [
            '12-Hour Wear',
            'Mess-free Removal',
            'Comfortable',
            'Intimate-friendly',
          ],
          'sizes': ['One Size'],
        },
        {
          'id': '5',
          'name': 'Daily Liners',
          'category': 'Liners',
          'type': 'liner',
          'rating': 4.4,
          'color': '0xFF2196F3',
          'description': 'Thin, breathable liners for light days and spotting.',
          'instructions':
              'Remove backing and place in underwear. Change as needed throughout the day.',
          'features': [
            'Ultra-thin',
            'Breathable',
            'All-day Freshness',
            'Discreet',
          ],
          'sizes': ['Regular', 'Long'],
        },
        {
          'id': '6',
          'name': 'Reusable Pads',
          'category': 'Pads',
          'type': 'pad',
          'rating': 4.5,
          'color': '0xFF009688',
          'description':
              'Washable cloth pads with snap closures for sustainability.',
          'instructions':
              'Snap around underwear, wash in cold water after use, air dry.',
          'features': [
            'Washable',
            'Eco-friendly',
            'Cost-effective',
            'Chemical-free',
          ],
          'sizes': ['Regular', 'Heavy', 'Overnight'],
        },
      ];
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  void _showProductDetails(
    Map<String, dynamic> product,
    EducationProvider educationProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          final colorValue =
              int.tryParse(product['color'] ?? '0xFFE91E63') ?? 0xFFE91E63;
          final productColor = Color(colorValue);

          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        productColor.withOpacity(0.1),
                        productColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: productColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getProductIcon(product['type']),
                          color: productColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Unknown Product',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${product['rating'] ?? 4.5}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
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

                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['description'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // How to Use
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: productColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to Use',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: productColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: productColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          product['instructions'] ??
                              'No instructions available.',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Features
                      Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...((product['features'] as List<dynamic>?) ?? []).map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: productColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sizes
                      if (product['sizes'] != null &&
                          (product['sizes'] as List).isNotEmpty) ...[
                        Text(
                          'Available Sizes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: (product['sizes'] as List<dynamic>)
                              .map(
                                (size) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: productColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: productColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    size.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: productColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Mark as viewed button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            educationProvider.recordResourceViewed(
                              product['id'] ?? '',
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added to your learning progress!',
                                ),
                                backgroundColor: productColor,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: productColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Mark as Learned',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
