import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  
  List<Order> _orders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await OrderService.getOrders(
        page: 1,
        limit: 20,
        orderType: 'ORDER', // Changed from QUOTATION to ORDER
      );

      setState(() {
        _orders = response.data;
        _currentPage = 1;
        _hasMore = response.data.length < response.total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await OrderService.getOrders(
        page: _currentPage + 1,
        limit: 20,
        orderType: 'ORDER',
      );

      setState(() {
        _orders.addAll(response.data);
        _currentPage++;
        _hasMore = _orders.length < response.total;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
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
          'Orders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/orders/add');
          if (result == true) {
            _loadOrders();
          }
        },
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Order', style: TextStyle(color: Colors.white)),
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
              'Failed to load orders',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No orders found',
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
      onRefresh: _loadOrders,
      color: const Color(0xFF7C3AED),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF7C3AED).withOpacity(0.05)),
            columns: const [
              DataColumn(label: Text('Order No', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Ledger', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Items', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Net Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tax Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _orders.map((order) => _buildOrderRow(order)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildOrderRow(Order order) {
    return DataRow(
      cells: [
        DataCell(Text(order.orderNo, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(order.formattedDate)),
        DataCell(SizedBox(
          width: 150,
          child: Text(
            order.outlet?.companyName ?? 'Unknown',
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Text(order.itemCount.toString())),
        DataCell(Text('₹${double.tryParse(order.netAmount)?.toStringAsFixed(2) ?? '0.00'}')),
        DataCell(Text('₹${double.tryParse(order.taxAmount)?.toStringAsFixed(2) ?? '0.00'}')),
        DataCell(Text(order.formattedTotalAmount, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)))),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 20, color: Colors.blue),
              onPressed: () {
                // View details
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
              onPressed: () {
                // Edit order
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        )),
      ],
    );
  }
}
