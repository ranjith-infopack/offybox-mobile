import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'quotation_detail_screen.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({super.key});

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen> {
  final ScrollController _scrollController = ScrollController();
  
  List<Order> _quotations = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuotations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreQuotations();
    }
  }

  Future<void> _loadQuotations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await OrderService.getOrders(
        page: 1,
        limit: 20,
        orderType: 'QUOTATION',
      );

      setState(() {
        _quotations = response.data;
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

  Future<void> _loadMoreQuotations() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await OrderService.getOrders(
        page: _currentPage + 1,
        limit: 20,
        orderType: 'QUOTATION',
      );

      setState(() {
        _quotations.addAll(response.data);
        _currentPage++;
        _hasMore = _quotations.length < response.total;
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
          'Quotations',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
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
              'Failed to load quotations',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuotations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_quotations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No quotations found',
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
      onRefresh: _loadQuotations,
      color: const Color(0xFF7C3AED),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _quotations.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _quotations.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              ),
            );
          }
          return _buildQuotationCard(_quotations[index]);
        },
      ),
    );
  }

  Widget _buildQuotationCard(Order quotation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuotationDetailScreen(orderId: quotation.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Quotation number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quotation.orderNo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quotation.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(quotation.orderStatus).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quotation.orderStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(quotation.orderStatus),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Customer and amount
              Row(
                children: [
                  // Customer
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              quotation.outlet?.companyName.isNotEmpty == true
                                  ? quotation.outlet!.companyName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quotation.outlet?.companyName ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${quotation.itemCount} item${quotation.itemCount != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        quotation.formattedTotalAmount,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'approved':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
