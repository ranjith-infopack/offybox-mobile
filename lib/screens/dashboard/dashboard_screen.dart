import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../quotation/quotation_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String _userName = '';
  String _userEmail = '';
  String _tenantName = '';
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good morning';
    } else if (hour < 17) {
      _greeting = 'Good afternoon';
    } else {
      _greeting = 'Good evening';
    }
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
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadUserInfo();
        },
        color: const Color(0xFF7C3AED),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '$_greeting! Here\'s an overview of your business.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              
              // Stats Grid
              _buildStatsGrid(),
              
              const SizedBox(height: 24),
              
              // Recent Activity Section
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 12),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            Expanded(child: _buildStatCard(
              icon: Icons.account_balance_wallet,
              iconColor: const Color(0xFF3B82F6),
              iconBgColor: const Color(0xFFDBEAFE),
              label: 'Ledger',
              value: '17',
              onTap: () {
                Navigator.pushNamed(context, '/ledgers');
              },
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              icon: Icons.inventory_2,
              iconColor: const Color(0xFFF59E0B),
              iconBgColor: const Color(0xFFFEF3C7),
              label: 'Products',
              value: '2',
              onTap: () {
                Navigator.pushNamed(context, '/products');
              },
            )),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            Expanded(child: _buildStatCard(
              icon: Icons.shopping_cart,
              iconColor: const Color(0xFFF59E0B),
              iconBgColor: const Color(0xFFFEF3C7),
              label: 'Orders',
              value: '5',
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              icon: Icons.receipt_long,
              iconColor: const Color(0xFF10B981),
              iconBgColor: const Color(0xFFD1FAE5),
              label: 'Invoices',
              value: '1',
            )),
          ],
        ),
        const SizedBox(height: 12),
        // Third row - 2 cards
        Row(
          children: [
            Expanded(child: _buildStatCard(
              icon: Icons.currency_rupee,
              iconColor: const Color(0xFFF59E0B),
              iconBgColor: const Color(0xFFFEF3C7),
              label: 'Sales (Month)',
              value: '₹0',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              icon: Icons.account_balance,
              iconColor: const Color(0xFF6366F1),
              iconBgColor: const Color(0xFFE0E7FF),
              label: 'Outstanding',
              value: '₹0',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.add_shopping_cart,
            label: 'New Order',
            color: const Color(0xFF7C3AED),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.person_add,
            label: 'Add Customer',
            color: const Color(0xFF10B981),
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/ledgers/add');
              if (result == true && mounted) {
                Navigator.pushNamed(context, '/ledgers');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.receipt,
            label: 'New Invoice',
            color: const Color(0xFF3B82F6),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
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
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ledgers');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description,
                  title: 'Quotations',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuotationListScreen()),
                    );
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
}
