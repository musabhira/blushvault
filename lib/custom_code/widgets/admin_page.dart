import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Banner Form Controllers
  final _bannerTitleController = TextEditingController();
  final _bannerSubtitleController = TextEditingController();
  final _bannerLinkController = TextEditingController();
  final _bannerOrderController = TextEditingController();
  XFile? _bannerImage;

  // Category Form Controllers
  final _categoryNameController = TextEditingController();
  final _categoryDescController = TextEditingController();
  XFile? _categoryImage;

  // Product Form Controllers
  final _productNameController = TextEditingController();
  final _productDescController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productOriginalPriceController = TextEditingController();
  final _productStockController = TextEditingController();
  final _productTagsController = TextEditingController();
  final _productRatingController = TextEditingController();
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  XFile? _productImage;
  bool _isFeatured = false;

  // Gallery Form Controllers
  final _galleryTitleController = TextEditingController();
  final _galleryDescController = TextEditingController();
  final _galleryCategoryController = TextEditingController();
  final _galleryOrderController = TextEditingController();
  XFile? _galleryImage;

  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerTitleController.dispose();
    _bannerSubtitleController.dispose();
    _bannerLinkController.dispose();
    _bannerOrderController.dispose();
    _categoryNameController.dispose();
    _categoryDescController.dispose();
    _productNameController.dispose();
    _productDescController.dispose();
    _productPriceController.dispose();
    _productOriginalPriceController.dispose();
    _productStockController.dispose();
    _productTagsController.dispose();
    _productRatingController.dispose();
    _galleryTitleController.dispose();
    _galleryDescController.dispose();
    _galleryCategoryController.dispose();
    _galleryOrderController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response =
          await _supabase.from('categories').select().eq('is_active', true);
      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showSnackBar('Error loading categories: $e', isError: true);
    }
  }

  Future<void> _pickImage(String type) async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'banner':
            _bannerImage = pickedFile;
            break;
          case 'category':
            _categoryImage = pickedFile;
            break;
          case 'product':
            _productImage = pickedFile;
            break;
          case 'gallery':
            _galleryImage = pickedFile;
            break;
        }
      });
    }
  }

  Future<String?> _uploadImage(XFile image, String bucket) async {
    try {
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      final bytes = await image.readAsBytes();

      await _supabase.storage.from(bucket).uploadBinary(
            filePath,
            bytes,
            fileOptions:
                FileOptions(upsert: true, contentType: 'image/$fileExt'),
          );

      final imageUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      _showSnackBar('Error uploading image: $e', isError: true);
      return null;
    }
  }

  Future<void> _addBanner() async {
    if (_bannerTitleController.text.isEmpty || _bannerImage == null) {
      _showSnackBar('Please fill required fields and select an image',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage(_bannerImage!, 'banners');
      if (imageUrl == null) return;

      await _supabase.from('banners').insert({
        'title': _bannerTitleController.text,
        'image_url': imageUrl,
        'subtitle': _bannerSubtitleController.text.isEmpty
            ? null
            : _bannerSubtitleController.text,
        'link_url': _bannerLinkController.text.isEmpty
            ? null
            : _bannerLinkController.text,
        'order_position': int.tryParse(_bannerOrderController.text) ?? 0,
        'is_active': true,
      });

      _showSnackBar('Banner added successfully!');
      _clearBannerForm();
    } catch (e) {
      _showSnackBar('Error adding banner: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    if (_categoryNameController.text.isEmpty || _categoryImage == null) {
      _showSnackBar('Please fill required fields and select an image',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage(_categoryImage!, 'categories');
      if (imageUrl == null) return;

      await _supabase.from('categories').insert({
        'name': _categoryNameController.text,
        'description': _categoryDescController.text.isEmpty
            ? null
            : _categoryDescController.text,
        'image_url': imageUrl,
        'is_active': true,
      });

      _showSnackBar('Category added successfully!');
      _clearCategoryForm();
      _loadCategories();
    } catch (e) {
      _showSnackBar('Error adding category: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addProduct() async {
    if (_productNameController.text.isEmpty ||
        _productPriceController.text.isEmpty ||
        _productImage == null ||
        _selectedCategoryId == null) {
      _showSnackBar('Please fill required fields and select an image',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage(_productImage!, 'products');
      if (imageUrl == null) return;

      final tags = _productTagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _supabase.from('products').insert({
        'name': _productNameController.text,
        'description': _productDescController.text.isEmpty
            ? null
            : _productDescController.text,
        'price': double.parse(_productPriceController.text),
        'original_price': _productOriginalPriceController.text.isEmpty
            ? null
            : double.parse(_productOriginalPriceController.text),
        'category_id': _selectedCategoryId,
        'image_url': imageUrl,
        'images': [imageUrl],
        'stock_quantity': int.tryParse(_productStockController.text) ?? 0,
        'is_featured': _isFeatured,
        'is_active': true,
        'tags': tags,
        'rating': _productRatingController.text.isEmpty
            ? 0.0
            : double.parse(_productRatingController.text),
      });

      _showSnackBar('Product added successfully!');
      _clearProductForm();
    } catch (e) {
      _showSnackBar('Error adding product: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addGallery() async {
    if (_galleryTitleController.text.isEmpty || _galleryImage == null) {
      _showSnackBar('Please fill required fields and select an image',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage(_galleryImage!, 'gallery');
      if (imageUrl == null) return;

      await _supabase.from('gallery').insert({
        'title': _galleryTitleController.text,
        'image_url': imageUrl,
        'description': _galleryDescController.text.isEmpty
            ? null
            : _galleryDescController.text,
        'category': _galleryCategoryController.text.isEmpty
            ? null
            : _galleryCategoryController.text,
        'order_position': int.tryParse(_galleryOrderController.text) ?? 0,
        'is_active': true,
      });

      _showSnackBar('Gallery item added successfully!');
      _clearGalleryForm();
    } catch (e) {
      _showSnackBar('Error adding gallery item: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearBannerForm() {
    _bannerTitleController.clear();
    _bannerSubtitleController.clear();
    _bannerLinkController.clear();
    _bannerOrderController.clear();
    setState(() => _bannerImage = null);
  }

  void _clearCategoryForm() {
    _categoryNameController.clear();
    _categoryDescController.clear();
    setState(() => _categoryImage = null);
  }

  void _clearProductForm() {
    _productNameController.clear();
    _productDescController.clear();
    _productPriceController.clear();
    _productOriginalPriceController.clear();
    _productStockController.clear();
    _productTagsController.clear();
    _productRatingController.clear();
    setState(() {
      _productImage = null;
      _selectedCategoryId = null;
      _isFeatured = false;
    });
  }

  void _clearGalleryForm() {
    _galleryTitleController.clear();
    _galleryDescController.clear();
    _galleryCategoryController.clear();
    _galleryOrderController.clear();
    setState(() => _galleryImage = null);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.view_carousel), text: 'Banners'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'Products'),
            Tab(icon: Icon(Icons.photo_library), text: 'Gallery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBannerForm(),
          _buildCategoryForm(),
          _buildProductForm(),
          _buildGalleryForm(),
        ],
      ),
    );
  }

  Widget _buildBannerForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _bannerTitleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bannerSubtitleController,
            decoration: const InputDecoration(
              labelText: 'Subtitle',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bannerLinkController,
            decoration: const InputDecoration(
              labelText: 'Link URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bannerOrderController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Order Position',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickImage('banner'),
            icon: const Icon(Icons.image),
            label: Text(
                _bannerImage == null ? 'Select Image *' : 'Image Selected'),
          ),
          if (_bannerImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: kIsWeb
                  ? Image.network(_bannerImage!.path,
                      height: 200, fit: BoxFit.cover)
                  : Image.file(File(_bannerImage!.path),
                      height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _addBanner,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Add Banner'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryDescController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickImage('category'),
            icon: const Icon(Icons.image),
            label: Text(
                _categoryImage == null ? 'Select Image *' : 'Image Selected'),
          ),
          if (_categoryImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: kIsWeb
                  ? Image.network(_categoryImage!.path,
                      height: 200, fit: BoxFit.cover)
                  : Image.file(File(_categoryImage!.path),
                      height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _addCategory,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _productNameController,
            decoration: const InputDecoration(
              labelText: 'Product Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _productDescController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _productPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Price *',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _productOriginalPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Original Price',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _productStockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Stock Quantity',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['id'],
                child: Text(category['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategoryId = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _productTagsController,
            decoration: const InputDecoration(
              labelText: 'Tags (comma separated)',
              border: OutlineInputBorder(),
              hintText: 'e.g., trending, new arrival',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _productRatingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Rating (0-5)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Featured Product'),
            value: _isFeatured,
            onChanged: (value) {
              setState(() => _isFeatured = value);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickImage('product'),
            icon: const Icon(Icons.image),
            label: Text(
                _productImage == null ? 'Select Image *' : 'Image Selected'),
          ),
          if (_productImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: kIsWeb
                  ? Image.network(_productImage!.path,
                      height: 200, fit: BoxFit.cover)
                  : Image.file(File(_productImage!.path),
                      height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _addProduct,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _galleryTitleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _galleryDescController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _galleryCategoryController,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              hintText: 'e.g., Collection, Style, Occasion',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _galleryOrderController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Order Position',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickImage('gallery'),
            icon: const Icon(Icons.image),
            label: Text(
                _galleryImage == null ? 'Select Image *' : 'Image Selected'),
          ),
          if (_galleryImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: kIsWeb
                  ? Image.network(_galleryImage!.path,
                      height: 200, fit: BoxFit.cover)
                  : Image.file(File(_galleryImage!.path),
                      height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _addGallery,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Add Gallery Item'),
          ),
        ],
      ),
    );
  }
}
