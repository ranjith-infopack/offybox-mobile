import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ProductService.getProducts(limit: 100);
      if (mounted) {
        setState(() {
          if (result['success']) {
            _products = result['data'] as List<Product>;
          } else {
            _error = result['message'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Add Product screen
        },
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load products',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: const Color(0xFF7C3AED),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF7C3AED).withOpacity(0.05)),
            columns: const [
              DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('MRP', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Selling Price', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _products.map((product) => _buildProductRow(product)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildProductRow(Product product) {
    return DataRow(
      cells: [
        DataCell(Text(product.code, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(SizedBox(
          width: 150,
          child: Text(product.name, overflow: TextOverflow.ellipsis),
        )),
        DataCell(Text(product.categoryName ?? '-')),
        DataCell(Text(product.brandName ?? '-')),
        DataCell(Text(product.unit ?? '-')),
        DataCell(Text('₹${product.mrp}')),
        DataCell(Text('₹${product.sellingPrice}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)))),
        DataCell(Text(product.stock)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: product.status == 'ACTIVE' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            product.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: product.status == 'ACTIVE' ? Colors.green : Colors.red,
            ),
          ),
        )),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 20, color: Colors.blue),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        )),
      ],
    );
  }
}
