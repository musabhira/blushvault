import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _products = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
    // Refresh every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _fetchData(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData({bool isRefresh = false}) async {
    try {
      if (!isRefresh && _isLoading == false) setState(() => _isLoading = true);

      // Fetch Orders
      final ordersData = await SupaFlow.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      // Fetch Products
      final productsData =
          await SupaFlow.client.from('products').select().order('name');

      if (mounted) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(ordersData);
          _products = List<Map<String, dynamic>>.from(productsData);
          _errorMessage = null;
          _isLoading = false;
        });

        if (isRefresh) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Data Refreshed'),
                duration: Duration(seconds: 1)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleStock(String productId, int currentStock) async {
    // If stock > 0, set to 0 (Out of Stock). If 0, set to 1 (In Stock).
    // Or users might want to edit exact value.
    // Requirement says: "tap to out of stock product['stock_quantity'] ?? 0) <= 0"
    // So toggle between 0 and 10 (or some default stock) for simplicity, or confirm.
    // Let's implement a toggle:
    // If >0 -> Set to 0.
    // If 0 -> Set to 10.

    final newStock = currentStock > 0 ? 0 : 10;

    try {
      await SupaFlow.client
          .from('products')
          .update({'stock_quantity': newStock}).eq('id', productId);

      // Optimistic update locally
      setState(() {
        final index = _products.indexWhere((p) => p['id'] == productId);
        if (index != -1) {
          _products[index]['stock_quantity'] = newStock;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(newStock == 0
                ? 'Marked as Out of Stock'
                : 'Marked as In Stock (10 units)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating stock: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF997C5B),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF997C5B),
          tabs: const [
            Tab(text: 'Orders', icon: Icon(Icons.shopping_bag_outlined)),
            Tab(text: 'Inventory', icon: Icon(Icons.inventory_2_outlined)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF997C5B)))
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(),
                    _buildInventoryList(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: GoogleFonts.nunitoSans(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage ?? '',
              style: GoogleFonts.nunitoSans(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetchData(),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF997C5B)),
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return Center(
          child: Text('No orders found', style: GoogleFonts.nunitoSans()));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildOrderCard(_orders[index]);
      },
    );
  }

  Widget _buildInventoryList() {
    if (_products.isEmpty) {
      return Center(
          child: Text('No products found', style: GoogleFonts.nunitoSans()));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final product = _products[index];
        final stock = product['stock_quantity'] ?? 0;
        final isOutOfStock = stock <= 0;

        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(product['image_url'] ?? ''),
                  fit: BoxFit.cover,
                )),
          ),
          title: Text(product['name'] ?? 'Product',
              style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
          subtitle: Text('Current Stock: $stock',
              style: GoogleFonts.nunitoSans(
                  color: isOutOfStock ? Colors.red : Colors.green)),
          trailing: ElevatedButton(
            onPressed: () => _toggleStock(product['id'], stock),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOutOfStock ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isOutOfStock ? 'Set In Stock' : 'Set Out of Stock',
                style: GoogleFonts.nunitoSans(fontSize: 12)),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final shipping = order['shipping_details'] ?? {};
    final items = order['order_items'] is List
        ? List<dynamic>.from(order['order_items'])
        : [];

    // Formatting date using intl if available, else simple split
    String dateStr = order['created_at'].toString();
    try {
      final date = DateTime.parse(order['created_at']);
      dateStr = DateFormat('MMM dd, yyyy · hh:mm a').format(date.toLocal());
    } catch (_) {}

    final status = order['status']?.toString().toUpperCase() ?? 'PENDING';
    Color statusColor = Colors.orange;
    if (status == 'PAID') statusColor = Colors.green;
    if (status == 'FAILED') statusColor = Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Order ',
                            style: GoogleFonts.nunitoSans(
                                color: Colors.grey[600], fontSize: 14)),
                        TextSpan(
                            text: '#${order['id'].toString().substring(0, 8)}',
                            style: GoogleFonts.nunitoSans(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr,
                      style: GoogleFonts.nunitoSans(
                          fontSize: 12, color: Colors.grey[500])),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.nunitoSans(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Shipping Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Customer',
                            style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(shipping['full_name'] ?? 'Guest',
                        style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    if (shipping['email'] != null)
                      Text(shipping['email'],
                          style: GoogleFonts.nunitoSans(
                              fontSize: 13, color: Colors.grey[800])),
                    if (shipping['phone_number'] != null)
                      Text(shipping['phone_number'],
                          style: GoogleFonts.nunitoSans(
                              fontSize: 13, color: Colors.grey[800])),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Shipping Address',
                            style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        shipping['address_line1'],
                        shipping['street_name'],
                        shipping['area_name'],
                        shipping['city_name'],
                        shipping['state_name'],
                        shipping['pincode'],
                        shipping['country_code']
                      ]
                          .where((s) => s != null && s.toString().isNotEmpty)
                          .join(', '),
                      style: GoogleFonts.nunitoSans(
                          fontSize: 14, height: 1.4, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Order Items
          Text('Ordered Items',
              style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
          const SizedBox(height: 12),
          ...items
              .map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        if (item['image_url'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item['image_url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200]),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] ?? 'Product',
                                  style: GoogleFonts.nunitoSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (item['selected_size'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text('${item['selected_size']}',
                                          style: GoogleFonts.nunitoSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  Text('Qty: ${item['quantity']}',
                                      style: GoogleFonts.nunitoSans(
                                          fontSize: 13,
                                          color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text('₹${item['price']}',
                            style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ))
              .toList(),

          const Divider(height: 24),

          // Payment Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Details',
                        style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(order['payment_id'] ?? 'N/A',
                          style: GoogleFonts.courierPrime(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total Paid',
                      style: GoogleFonts.nunitoSans(
                          fontSize: 12, color: Colors.grey[600])),
                  Text('₹${order['amount']?.toString() ?? '0'}',
                      style: GoogleFonts.nunitoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF997C5B))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
