import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryBackground = Color(0xFF7C3AED);
  
  // Sidebar colors
  static const Color sidebarBackground = Color(0xFF7C3AED);
  static const Color sidebarText = Colors.white;
  static const Color sidebarActiveBackground = Colors.white;
  static const Color sidebarActiveText = Color(0xFF7C3AED);
  static const Color sidebarSelectionDivider = Colors.white24;
  
  // Section labels
  static const Color sectionLabel = Colors.white70;
  
  // Hover effects (represented as subtle overlays)
  static final Color hoverOverlay = Colors.white.withValues(alpha: 0.1);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
