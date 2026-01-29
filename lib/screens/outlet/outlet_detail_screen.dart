import 'package:flutter/material.dart';
import '../../models/outlet.dart';
import '../../services/outlet_service.dart';

class OutletDetailScreen extends StatefulWidget {
  final String outletId;

  const OutletDetailScreen({super.key, required this.outletId});

  @override
  State<OutletDetailScreen> createState() => _OutletDetailScreenState();
}

class _OutletDetailScreenState extends State<OutletDetailScreen> {
  Outlet? _outlet;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOutletDetails();
  }

  Future<void> _loadOutletDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await OutletService.getOutletById(widget.outletId);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _outlet = result['data'] as Outlet;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });

      if (result['unauthorized'] == true && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _outlet?.companyName ?? 'Outlet Details',
          style: const TextStyle(fontWeight: FontWeight.w600),
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

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOutletDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_outlet == null) {
      return const Center(child: Text('Outlet not found'));
    }

    return RefreshIndicator(
      onRefresh: _loadOutletDetails,
      color: const Color(0xFF7C3AED),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header card
            _buildHeaderCard(),
            const SizedBox(height: 16),
            // Contact info
            _buildSection('Contact Information', [
              _buildInfoRow(Icons.email, 'Email', _outlet!.email ?? 'N/A'),
              _buildInfoRow(Icons.phone, 'Phone', _outlet!.phone ?? 'N/A'),
              _buildInfoRow(Icons.phone_android, 'Mobile', _outlet!.mobile ?? 'N/A'),
            ]),
            const SizedBox(height: 16),
            // Address info - Billing Address
            if (_outlet!.hasAddresses) ...[
              for (final address in _outlet!.addresses)
                ...[
                  _buildSection('${_capitalizeFirst(address.type)} Address', [
                    if (address.name != null && address.name!.isNotEmpty)
                      _buildInfoRow(Icons.business, 'Name', address.name!),
                    if (address.address1 != null && address.address1!.isNotEmpty)
                      _buildInfoRow(Icons.location_on, 'Address', address.address1!),
                    if (address.address2 != null && address.address2!.isNotEmpty)
                      _buildInfoRow(Icons.location_on_outlined, 'Address 2', address.address2!),
                    if (address.pincode != null && address.pincode!.isNotEmpty)
                      _buildInfoRow(Icons.pin_drop, 'Pincode', address.pincode!),
                  ]),
                  const SizedBox(height: 16),
                ],
            ],
            // Contact person info
            if (_outlet!.hasContactPerson) ...[
              _buildSection('Contact Person', [
                if (_outlet!.contactPersonName != null && _outlet!.contactPersonName!.isNotEmpty)
                  _buildInfoRow(Icons.person, 'Name', _outlet!.contactPersonName!),
                if (_outlet!.contactPersonDesignation != null && _outlet!.contactPersonDesignation!.isNotEmpty)
                  _buildInfoRow(Icons.work, 'Designation', _outlet!.contactPersonDesignation!),
                if (_outlet!.contactPersonPhone != null && _outlet!.contactPersonPhone!.isNotEmpty)
                  _buildInfoRow(Icons.phone, 'Phone', _outlet!.contactPersonPhone!),
                if (_outlet!.contactPersonEmail != null && _outlet!.contactPersonEmail!.isNotEmpty)
                  _buildInfoRow(Icons.email, 'Email', _outlet!.contactPersonEmail!),
              ]),
              const SizedBox(height: 16),
            ],
            // Business info
            _buildSection('Business Information', [
              _buildInfoRow(Icons.category, 'Category', _outlet!.outletCategory?.name ?? 'N/A'),
              _buildInfoRow(Icons.badge, 'Type', _outlet!.outletType ?? 'N/A'),
              _buildInfoRow(Icons.receipt, 'GSTN', _outlet!.gstn ?? 'N/A'),
              _buildInfoRow(Icons.check_circle, 'Status', _outlet!.status),
            ]),
            const SizedBox(height: 16),
            // Financial info
            _buildSection('Financial Information', [
              _buildInfoRow(Icons.account_balance_wallet, 'Credit Limit', '₹${_formatAmount(_outlet!.creditLimit)}'),
              _buildInfoRow(Icons.payments, 'Outstanding', '₹${_formatAmount(_outlet!.outstanding)}'),
            ]),
            const SizedBox(height: 16),
            // Sales person info
            if (_outlet!.salesPerson != null) ...[
              _buildSection('Sales Person', [
                _buildInfoRow(Icons.person, 'Name', _outlet!.salesPerson!.fullName),
                _buildInfoRow(Icons.email, 'Email', _outlet!.salesPerson!.email),
                _buildInfoRow(Icons.badge, 'Code', _outlet!.salesPerson!.code),
              ]),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF7C3AED),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _outlet!.companyName.isNotEmpty
                    ? _outlet!.companyName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Company name
          Text(
            _outlet!.companyName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Type and status badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_outlet!.outletType != null && _outlet!.outletType!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _outlet!.outletType!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _outlet!.status == 'ACTIVE'
                      ? Colors.green.withValues(alpha: 0.8)
                      : Colors.red.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _outlet!.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat('Credit Limit', '₹${_formatAmount(_outlet!.creditLimit)}'),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildQuickStat('Outstanding', '₹${_formatAmount(_outlet!.outstanding)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(String amount) {
    final num = double.tryParse(amount) ?? 0;
    if (num >= 100000) {
      return '${(num / 100000).toStringAsFixed(2)}L';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(2)}K';
    }
    return num.toStringAsFixed(0);
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
