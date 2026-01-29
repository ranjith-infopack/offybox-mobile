import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../services/invoice_service.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await InvoiceService.getInvoices(page: _currentPage, limit: 100);
      if (mounted) {
        setState(() {
          if (result['success']) {
            _invoices = (result['data'] as InvoiceListResponse).data;
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
          'Invoices',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Invoice feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Invoice', style: TextStyle(color: Colors.white)),
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
              _error ?? 'Failed to load invoices',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInvoices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No invoices found',
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
      onRefresh: _loadInvoices,
      color: const Color(0xFF7C3AED),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF7C3AED).withOpacity(0.05)),
            columns: const [
              DataColumn(label: Text('Invoice No', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Ledger', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Items', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Net Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tax Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _invoices.map((invoice) => _buildInvoiceRow(invoice)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildInvoiceRow(Invoice invoice) {
    return DataRow(
      cells: [
        DataCell(Text(invoice.invoiceNo, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(invoice.formattedDate)),
        DataCell(SizedBox(
          width: 150,
          child: Text(invoice.outletName ?? '-', overflow: TextOverflow.ellipsis),
        )),
        DataCell(Text(invoice.itemCount.toString())),
        DataCell(Text('₹${invoice.netAmount}')),
        DataCell(Text('₹${invoice.taxAmount}')),
        DataCell(Text('₹${invoice.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(invoice.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            invoice.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(invoice.status),
            ),
          ),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 20, color: Colors.blue),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.print, size: 20, color: Colors.grey),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
        return Colors.green;
      case 'PARTIAL':
        return Colors.orange;
      case 'PENDING':
      case 'DUE':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
