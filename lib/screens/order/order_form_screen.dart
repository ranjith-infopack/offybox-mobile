import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../models/outlet.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../services/outlet_service.dart';
import '../../services/product_service.dart';
import '../../services/api_service.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Info
  List<Outlet> _ledgers = [];
  Outlet? _selectedLedger;
  DateTime _orderDate = DateTime.now();
  String _orderStatus = 'Pending';
  OutletAddress? _selectedBillingAddress;
  OutletAddress? _selectedShippingAddress;
  
  // Products list
  List<Product> _products = [];
  
  // Order Items
  List<Map<String, dynamic>> _items = [];
  
  // Controllers
  final _remarksController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _addItemRow(); // Start with one empty row
  }

  @override
  void dispose() {
    _remarksController.dispose();
    for (var item in _items) {
      item['qtyController'].dispose();
      item['priceController'].dispose();
      item['discountController'].dispose();
    }
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final results = await Future.wait([
        OutletService.getOutlets(limit: 100),
        ProductService.getProducts(limit: 100),
      ]);

      if (mounted) {
        setState(() {
          if (results[0]['success']) {
            _ledgers = (results[0]['data'] as OutletListResponse).data;
          }
          if (results[1]['success']) {
            _products = results[1]['data'] as List<Product>;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading initial data: $e')),
        );
      }
    }
  }

  void _addItemRow() {
    setState(() {
      final qtyController = TextEditingController(text: '1');
      final priceController = TextEditingController(text: '0');
      final discountController = TextEditingController(text: '0');
      
      _items.add({
        'product': null,
        'qtyController': qtyController,
        'priceController': priceController,
        'discountController': discountController,
        'tax_rate': 0.0,
      });
      
      // Add listeners for real-time calculation
      qtyController.addListener(_updateTotals);
      priceController.addListener(_updateTotals);
      discountController.addListener(_updateTotals);
    });
  }

  void _removeItemRow(int index) {
    if (_items.length > 1) {
      setState(() {
        final item = _items.removeAt(index);
        item['qtyController'].dispose();
        item['priceController'].dispose();
        item['discountController'].dispose();
        _updateTotals();
      });
    }
  }

  void _updateTotals() {
    setState(() {
      // Logic for real-time totals calculation is triggered here
      // and reflected in the UI builds
    });
  }

  double get _subTotal {
    double total = 0;
    for (var item in _items) {
      final qty = double.tryParse(item['qtyController'].text) ?? 0;
      final price = double.tryParse(item['priceController'].text) ?? 0;
      total += qty * price;
    }
    return total;
  }

  double get _totalDiscount {
    double total = 0;
    for (var item in _items) {
      total += double.tryParse(item['discountController'].text) ?? 0;
    }
    return total;
  }

  double get _totalTax {
    double total = 0;
    for (var item in _items) {
      final qty = double.tryParse(item['qtyController'].text) ?? 0;
      final price = double.tryParse(item['priceController'].text) ?? 0;
      final discount = double.tryParse(item['discountController'].text) ?? 0;
      final netAmt = (qty * price) - discount;
      final taxRate = (item['tax_rate'] as double) / 100;
      total += netAmt * taxRate;
    }
    return total;
  }

  double get _grandTotal => _subTotal - _totalDiscount + _totalTax;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLedger == null) {
      _showError('Please select a ledger');
      return;
    }
    if (_items.any((item) => item['product'] == null)) {
      _showError('Please select a product for all items');
      return;
    }

    setState(() => _isSubmitting = true);

    // Mock payload structure based on typical API requirements
    final payload = {
      'outlet_id': _selectedLedger!.id,
      'order_date': DateFormat('yyyy-MM-dd').format(_orderDate),
      'order_status': _orderStatus.toUpperCase(),
      'billing_address_id': _selectedBillingAddress?.id,
      'shipping_address_id': _selectedShippingAddress?.id,
      'remarks': _remarksController.text,
      'items': _items.map((item) {
        final product = item['product'] as Product;
        final qty = double.parse(item['qtyController'].text);
        final price = double.parse(item['priceController'].text);
        final discount = double.parse(item['discountController'].text);
        final netAmt = (qty * price) - discount;
        final taxAmt = netAmt * (item['tax_rate'] / 100);
        
        return {
          'product_id': product.id,
          'quantity': qty,
          'price': price,
          'discount_amount': discount,
          'tax_amount': taxAmt,
          'total_amount': netAmt + taxAmt,
        };
      }).toList(),
      'net_amount': _subTotal - _totalDiscount,
      'tax_amount': _totalTax,
      'total_amount': _grandTotal,
      'order_type': 'ORDER',
    };

    // Need to implement ApiService.post for orders
    // For now, mirroring createOutlet behavior
    final result = await ApiService.post('/orders', payload);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully')),
        );
        Navigator.pop(context, true);
      } else {
        _showError(result['message'] ?? 'Failed to create order');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        title: const Text('Create New Order', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Ledger *'),
                  _buildLedgerDropdown(),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Order Date *'),
                            _buildDateField(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Order Status *'),
                            _buildStatusDropdown(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  _buildLabel('Billing Address *'),
                  _buildAddressDropdown(isBilling: true),
                  
                  _buildLabel('Shipping Address *'),
                  _buildAddressDropdown(isBilling: false),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('Order Items'),
                  const SizedBox(height: 12),
                  
                  _buildItemsTable(),
                  
                  const SizedBox(height: 12),
                  _buildAddMoreButton(),
                  
                  const SizedBox(height: 24),
                  _buildSummarySection(),
                  
                  const SizedBox(height: 16),
                  _buildLabel('Remarks'),
                  _buildTextField(_remarksController, 'Enter Remarks', maxLines: 3),
                  
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151), fontSize: 13),
      ),
    );
  }

  Widget _buildLedgerDropdown() {
    return DropdownButtonFormField<Outlet>(
      value: _selectedLedger,
      hint: const Text('Select Ledger', style: TextStyle(fontSize: 14)),
      decoration: _inputDecoration(),
      items: _ledgers.map((l) => DropdownMenuItem(value: l, child: Text(l.companyName, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (v) {
        setState(() {
          _selectedLedger = v;
          _selectedBillingAddress = v?.billingAddress;
          _selectedShippingAddress = v?.shippingAddress;
        });
      },
      validator: (v) => v == null ? 'Please select a ledger' : null,
      isExpanded: true,
    );
  }

  Widget _buildStatusDropdown() {
    final statuses = ['Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
    return DropdownButtonFormField<String>(
      value: _orderStatus,
      decoration: _inputDecoration(),
      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _orderStatus = v!),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _orderDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => _orderDate = picked);
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: TextEditingController(text: DateFormat('MM/dd/yyyy').format(_orderDate)),
          decoration: _inputDecoration(suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        ),
      ),
    );
  }

  Widget _buildAddressDropdown({required bool isBilling}) {
    final addresses = _selectedLedger?.addresses ?? [];
    return DropdownButtonFormField<OutletAddress>(
      value: isBilling ? _selectedBillingAddress : _selectedShippingAddress,
      hint: Text(isBilling ? 'Select Billing Address' : 'Select Shipping Address', style: const TextStyle(fontSize: 14)),
      decoration: _inputDecoration(),
      items: addresses.map((a) => DropdownMenuItem(value: a, child: Text('${a.type}: ${a.fullAddress}', overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (v) => setState(() {
        if (isBilling) _selectedBillingAddress = v;
        else _selectedShippingAddress = v;
      }),
      isExpanded: true,
    );
  }

  Widget _buildItemsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40),   // #
          1: FixedColumnWidth(180),  // Product
          2: FixedColumnWidth(80),   // HSN
          3: FixedColumnWidth(60),   // Unit
          4: FixedColumnWidth(70),   // Qty
          5: FixedColumnWidth(90),   // Price
          6: FixedColumnWidth(80),   // Discount
          7: FixedColumnWidth(70),   // Tax %
          8: FixedColumnWidth(100),  // Net Amt
          9: FixedColumnWidth(100),  // Tax Amt
          10: FixedColumnWidth(100), // Total
          11: FixedColumnWidth(40),  // Delete
        },
        border: TableBorder.all(color: Colors.grey.shade300, width: 0.5, borderRadius: BorderRadius.circular(4)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildTableHeader(),
          ...List.generate(_items.length, (index) => _buildItemRow(index)),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: [
        '#', 'Product *', 'HSN', 'Unit', 'Qty *', 'Price *', 'Disc', 'Tax %', 'Net Amt', 'Tax Amt', 'Total', ''
      ].map((h) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center),
      )).toList(),
    );
  }

  TableRow _buildItemRow(int index) {
    final item = _items[index];
    final qty = double.tryParse(item['qtyController'].text) ?? 0;
    final price = double.tryParse(item['priceController'].text) ?? 0;
    final discount = double.tryParse(item['discountController'].text) ?? 0;
    final netAmt = (qty * price) - discount;
    final taxAmt = netAmt * (item['tax_rate'] / 100);
    final total = netAmt + taxAmt;

    return TableRow(
      children: [
        // #
        Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 12))),
        
        // Product
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Product>(
              value: item['product'],
              hint: const Text('Select', style: TextStyle(fontSize: 11)),
              isExpanded: true,
              items: _products.map((p) => DropdownMenuItem(value: p, child: Text(p.name, style: const TextStyle(fontSize: 11)))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    item['product'] = v;
                    item['priceController'].text = v.sellingPrice;
                    item['tax_rate'] = double.tryParse(v.taxRate ?? '0') ?? 0.0;
                    _updateTotals();
                  });
                }
              },
            ),
          ),
        ),
        
        // HSN
        Center(child: Text(item['product']?.hsn ?? '-', style: const TextStyle(fontSize: 11))),
        
        // Unit
        Center(child: Text(item['product']?.unit ?? '-', style: const TextStyle(fontSize: 11))),
        
        // Qty
        _buildTableInput(item['qtyController']),
        
        // Price
        _buildTableInput(item['priceController']),
        
        // Discount
        _buildTableInput(item['discountController']),
        
        // Tax %
        Center(child: Text('${item['tax_rate']}%', style: const TextStyle(fontSize: 11))),
        
        // Net Amt
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text('₹${netAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11), textAlign: TextAlign.right),
        ),
        
        // Tax Amt
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text('₹${taxAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11), textAlign: TextAlign.right),
        ),
        
        // Total
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right),
        ),

        // Action
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          onPressed: () => _removeItemRow(index),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildTableInput(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return TextButton.icon(
      onPressed: _addItemRow,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add More Item'),
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF7C3AED)),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Sub Total', '₹${_subTotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Total Discount', '- ₹${_totalDiscount.toStringAsFixed(2)}', color: Colors.red),
          _buildSummaryRow('Total Tax', '₹${_totalTax.toStringAsFixed(2)}'),
          _buildSummaryRow('Round Off', '₹0.00'), // Simplification
          const Divider(height: 24),
          _buildSummaryRow('Grand Total', '₹${_grandTotal.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(
            fontSize: isTotal ? 20 : 14, 
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF7C3AED) : color ?? Colors.black87,
          )),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(hint: hint),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Create Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
