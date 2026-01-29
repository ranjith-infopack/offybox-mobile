import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/outlet.dart';
import '../../services/outlet_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../outlet/outlet_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Outlet> _outlets = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';

  // User info
  String _userName = '';
  String _userEmail = '';
  String _tenantName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadOutlets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final userData = await StorageService.getUserData();
    final tenantData = await StorageService.getTenantData();

    if (userData != null) {
      final user = jsonDecode(userData);
      setState(() {
        _userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
        _userEmail = user['email'] ?? '';
      });
    }

    if (tenantData != null) {
      final tenant = jsonDecode(tenantData);
      setState(() {
        _tenantName = tenant['name'] ?? '';
      });
    }
  }

  Future<void> _loadOutlets({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _outlets = [];
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await OutletService.getOutlets(
      page: _currentPage,
      limit: 10,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (!mounted) return;

    if (result['success']) {
      final response = result['data'] as OutletListResponse;
      setState(() {
        if (refresh || _currentPage == 1) {
          _outlets = response.data;
        } else {
          _outlets.addAll(response.data);
        }
        _totalPages = response.totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
        _isLoadingMore = false;
      });

      if (result['unauthorized'] == true && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadOutlets();
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _loadOutlets(refresh: true);
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Outlets',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadOutlets(refresh: true),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search outlets...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: _onSearch,
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 40,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(height: 20),
                // Tenant name
                Text(
                  _tenantName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // User info
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/dashboard');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.store,
                  title: 'Outlets',
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Ledgers',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ledgers');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart,
                  title: 'Orders',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.inventory,
                  title: 'Products',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/products');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long,
                  title: 'Invoices',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.payments,
                  title: 'Payments',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Logout
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool selected = false,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF7C3AED) : textColor ?? Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF7C3AED) : textColor ?? Colors.grey.shade800,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
      onTap: onTap,
    );
  }

  Widget _buildContent() {
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
              onPressed: () => _loadOutlets(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_outlets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No outlets found for "$_searchQuery"'
                  : 'No outlets found',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadOutlets(refresh: true),
      color: const Color(0xFF7C3AED),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _outlets.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _outlets.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              ),
            );
          }

          final outlet = _outlets[index];
          return _buildOutletCard(outlet);
        },
      ),
    );
  }

  Widget _buildOutletCard(Outlet outlet) {
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
              builder: (context) => OutletDetailScreen(outletId: outlet.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C3AED),
                      const Color(0xFF9F67FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    outlet.companyName.isNotEmpty
                        ? outlet.companyName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company name
                    Text(
                      outlet.companyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Type, Category, Status badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (outlet.outletType != null &&
                            outlet.outletType!.isNotEmpty)
                          _buildBadge(
                            outlet.outletType!,
                            _getTypeColor(outlet.outletType!),
                            Colors.white,
                          ),
                        if (outlet.outletCategory != null)
                          _buildBadge(
                            outlet.outletCategory!.name,
                            Colors.grey.shade200,
                            Colors.grey.shade700,
                          ),
                        _buildBadge(
                          outlet.status,
                          outlet.status == 'ACTIVE'
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          outlet.status == 'ACTIVE'
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Phone icon button (circle style)
              if (outlet.mobile != null && outlet.mobile!.isNotEmpty) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _makePhoneCall(outlet.mobile!),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'DEALER':
        return Colors.blue;
      case 'CUSTOMER':
        return Colors.green;
      case 'SUPPLIER':
        return Colors.orange;
      case 'BOTH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(String amount) {
    final num = double.tryParse(amount) ?? 0;
    if (num >= 100000) {
      return '${(num / 100000).toStringAsFixed(1)}L';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toStringAsFixed(0);
  }
}
