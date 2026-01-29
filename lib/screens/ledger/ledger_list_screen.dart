import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../models/outlet.dart';
import '../../services/outlet_service.dart';
import '../outlet/outlet_detail_screen.dart';

class LedgerListScreen extends StatefulWidget {
  const LedgerListScreen({super.key});

  @override
  State<LedgerListScreen> createState() => _LedgerListScreenState();
}

class _LedgerListScreenState extends State<LedgerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Outlet> _ledgers = [];
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
    _loadLedgers();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUserInfo() async {
    final userData = await StorageService.getUserData();
    final tenantData = await StorageService.getTenantData();

    if (userData != null) {
      final user = List.from(jsonDecode(userData).entries).fold<Map<String, dynamic>>({}, (prev, element) => prev..[element.key] = element.value);
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLedgers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _ledgers = [];
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
          _ledgers = response.data;
        } else {
          _ledgers.addAll(response.data);
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
      _loadLedgers();
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _loadLedgers(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Ledger List',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadLedgers(refresh: true),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ledger...',
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
          
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Ledger Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 1, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Sales Person', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 1, child: Text('O/S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
                SizedBox(width: 8),
                Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/ledgers/add');
          if (result == true) {
            _loadLedgers(refresh: true);
          }
        },
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Ledger', style: TextStyle(color: Colors.white)),
      ),
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
              onPressed: () => _loadLedgers(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_ledgers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No ledgers found for "$_searchQuery"'
                  : 'No ledgers found',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadLedgers(refresh: true),
      color: const Color(0xFF7C3AED),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _ledgers.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          if (index == _ledgers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              ),
            );
          }

          final ledger = _ledgers[index];
          return _buildLedgerRow(ledger);
        },
      ),
    );
  }

  Widget _buildLedgerRow(Outlet ledger) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OutletDetailScreen(outletId: ledger.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Name
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ledger.companyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ledger.mobile != null && ledger.mobile!.isNotEmpty)
                    Text(
                      ledger.mobile!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            
            // Type
            Expanded(
              flex: 1,
              child: Text(
                ledger.outletType ?? '-',
                style: const TextStyle(fontSize: 12),
              ),
            ),

            // Sales Person
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ledger.salesPerson?.fullName ?? '-',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ledger.salesPerson?.email != null)
                    Text(
                      ledger.salesPerson!.email,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Outstanding
            Expanded(
              flex: 1,
              child: Text(
                '₹${ledger.outstanding}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.right,
              ),
            ),

            const SizedBox(width: 8),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ledger.status == 'ACTIVE' ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ledger.status == 'ACTIVE' ? 'ACT' : 'INA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ledger.status == 'ACTIVE' ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Ledgers',
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart,
                  title: 'Orders',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.inventory,
                  title: 'Products',
                  onTap: () {
                    Navigator.pop(context);
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

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
