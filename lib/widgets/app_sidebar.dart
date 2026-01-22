import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppSidebar extends StatelessWidget {
  final String activeItem;
  final String userName;
  final String userEmail;
  final String tenantName;
  final Function(String) onItemTap;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.activeItem,
    required this.userName,
    required this.userEmail,
    required this.tenantName,
    required this.onItemTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Header Section
          _buildHeader(context),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  id: 'Dashboard',
                ),
                
                const SizedBox(height: 16),
                _buildSectionLabel('USER'),
                _buildMenuItem(
                  icon: Icons.people_outline,
                  title: 'Users',
                  id: 'Users',
                ),
                _buildMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Roles',
                  id: 'Roles',
                ),
                _buildMenuItem(
                  icon: Icons.account_tree_outlined,
                  title: 'Ledger Groups',
                  id: 'Ledger Groups',
                ),
                _buildMenuItem(
                  icon: Icons.menu_book_outlined,
                  title: 'Ledger',
                  id: 'Ledger',
                ),
                
                const SizedBox(height: 16),
                _buildSectionLabel('SALES'),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Quotation',
                  id: 'Quotation',
                ),
                _buildMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Orders',
                  id: 'Orders',
                ),
                _buildMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Invoice',
                  id: 'Invoice',
                ),
                _buildMenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Delivery Challan',
                  id: 'Delivery Challan',
                ),
                _buildMenuItem(
                  icon: Icons.assignment_return_outlined,
                  title: 'DC Return',
                  id: 'DC Return',
                ),
                
                const SizedBox(height: 16),
                _buildSectionLabel('PURCHASE'),
                _buildMenuItem(
                  icon: Icons.storefront_outlined,
                  title: 'Suppliers',
                  id: 'Suppliers',
                ),
                _buildMenuItem(
                  icon: Icons.login_outlined,
                  title: 'Purchase Entry',
                  id: 'Purchase Entry',
                ),
                _buildMenuItem(
                  icon: Icons.keyboard_return_outlined,
                  title: 'Purchase Return',
                  id: 'Purchase Return',
                ),
                
                const SizedBox(height: 16),
                _buildSectionLabel('FINANCE'),
                _buildMenuItem(
                  icon: Icons.payments_outlined,
                  title: 'Payments',
                  id: 'Payments',
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Expenses',
                  id: 'Expenses',
                ),

                const SizedBox(height: 16),
                _buildSectionLabel('REPORTS'),
                _buildMenuItem(
                  icon: Icons.bar_chart_outlined,
                  title: 'Analytics',
                  id: 'Analytics',
                ),
                _buildMenuItem(
                  icon: Icons.assignment_outlined,
                  title: 'Sales Report',
                  id: 'Sales Report',
                ),
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Purchase Report',
                  id: 'Purchase Report',
                ),
                _buildMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory Report',
                  id: 'Inventory Report',
                ),

                const SizedBox(height: 16),
                _buildSectionLabel('PRODUCT'),
                _buildMenuItem(
                  icon: Icons.grid_view_outlined,
                  title: 'Units',
                  id: 'Units',
                ),
                _buildMenuItem(
                  icon: Icons.folder_open_outlined,
                  title: 'Category',
                  id: 'Category',
                ),
                _buildMenuItem(
                  icon: Icons.sentiment_satisfied_alt_outlined,
                  title: 'Brand',
                  id: 'Brand',
                ),
                _buildMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Products',
                  id: 'Products',
                ),
                _buildMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory',
                  id: 'Inventory',
                ),

                const SizedBox(height: 16),
                _buildSectionLabel('SYSTEM'),
                _buildMenuItem(
                  icon: Icons.attach_money_outlined,
                  title: 'Tax Rates',
                  id: 'Tax Rates',
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Accounts',
                  id: 'Bank Accounts',
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  id: 'Settings',
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          // Footer / Logout
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo placeholder or Image
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'OFFYBOX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            tenantName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            userEmail,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.sectionLabel,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String id,
  }) {
    final bool isActive = activeItem == id;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InkWell(
        onTap: () => onItemTap(id),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.sidebarActiveBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.sidebarActiveText : AppColors.sidebarText,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? AppColors.sidebarActiveText : AppColors.sidebarText,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              const Icon(
                Icons.logout_outlined,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 16),
              const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
