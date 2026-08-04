import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

typedef ServiceIconStyle = ({IconData icon, Color color, Color bg});

ServiceIconStyle serviceIconFor(String name, String? categoryName) {
  final n = name.trim();

  if (_contains(n, ['plafon'])) {
    return (icon: Icons.roofing, color: const Color(0xFFB45309), bg: const Color(0xFFFEF3C7));
  }
  if (_contains(n, ['mcb'])) {
    return (icon: Icons.electrical_services, color: const Color(0xFF2563EB), bg: const Color(0xFFDBEAFE));
  }
  if (_contains(n, ['stopkontak'])) {
    return (icon: Icons.outlet, color: const Color(0xFF9333EA), bg: const Color(0xFFF3E8FF));
  }
  if (_contains(n, ['listrik'])) {
    return (icon: Icons.electric_bolt, color: const Color(0xFFFFB300), bg: const Color(0xFFFFF8E1));
  }
  if (_contains(n, ['bangun', 'keramik'])) {
    return (icon: Icons.home_repair_service, color: const Color(0xFFFF6B00), bg: const Color(0xFFFFF0E0));
  }
  if (_contains(n, ['bersih', 'cuci', 'kebersihan'])) {
    return (icon: Icons.cleaning_services, color: const Color(0xFF059669), bg: const Color(0xFFE6F7F0));
  }
  if (_contains(n, ['pindah', 'angkut', 'pindahan'])) {
    return (icon: Icons.local_shipping, color: AppColors.primary, bg: const Color(0xFFE6EEFF));
  }
  if (_contains(n, ['kayu', 'furnitur'])) {
    return (icon: Icons.handyman, color: const Color(0xFF7C3AED), bg: const Color(0xFFF0E6FF));
  }
  if (_contains(n, ['ac', 'elektronik'])) {
    return (icon: Icons.ac_unit, color: const Color(0xFF0891B2), bg: const Color(0xFFE0F7FA));
  }
  if (_contains(n, ['cat', 'pengecatan'])) {
    return (icon: Icons.format_paint, color: const Color(0xFFE91E63), bg: const Color(0xFFFCE4EC));
  }
  if (_contains(n, ['taman', 'berkebun'])) {
    return (icon: Icons.yard, color: const Color(0xFF4CAF50), bg: const Color(0xFFE8F5E9));
  }
  if (_contains(n, ['plumbing', 'pipa', 'ledeng'])) {
    return (icon: Icons.plumbing, color: const Color(0xFF00BCD4), bg: const Color(0xFFE0F7FA));
  }
  if (_contains(n, ['kaca'])) {
    return (icon: Icons.window, color: const Color(0xFF6366F1), bg: const Color(0xFFEEF2FF));
  }

  final c = (categoryName ?? '').trim();
  if (_contains(c, ['listrik', 'kelistrikan'])) {
    return (icon: Icons.electric_bolt, color: const Color(0xFFFFB300), bg: const Color(0xFFFFF8E1));
  }
  if (_contains(c, ['bangun', 'keramik'])) {
    return (icon: Icons.home_repair_service, color: const Color(0xFFFF6B00), bg: const Color(0xFFFFF0E0));
  }
  if (_contains(c, ['kebersihan', 'bersih', 'cuci'])) {
    return (icon: Icons.cleaning_services, color: const Color(0xFF059669), bg: const Color(0xFFE6F7F0));
  }
  if (_contains(c, ['pindah', 'pindahan'])) {
    return (icon: Icons.local_shipping, color: AppColors.primary, bg: const Color(0xFFE6EEFF));
  }
  if (_contains(c, ['kayu', 'furnitur'])) {
    return (icon: Icons.handyman, color: const Color(0xFF7C3AED), bg: const Color(0xFFF0E6FF));
  }
  if (_contains(c, ['ac', 'elektronik'])) {
    return (icon: Icons.ac_unit, color: const Color(0xFF0891B2), bg: const Color(0xFFE0F7FA));
  }
  if (_contains(c, ['cat', 'pengecatan'])) {
    return (icon: Icons.format_paint, color: const Color(0xFFE91E63), bg: const Color(0xFFFCE4EC));
  }
  if (_contains(c, ['taman', 'berkebun'])) {
    return (icon: Icons.yard, color: const Color(0xFF4CAF50), bg: const Color(0xFFE8F5E9));
  }
  if (_contains(c, ['plumbing', 'pipa', 'ledeng'])) {
    return (icon: Icons.plumbing, color: const Color(0xFF00BCD4), bg: const Color(0xFFE0F7FA));
  }
  if (_contains(c, ['kaca'])) {
    return (icon: Icons.window, color: const Color(0xFF6366F1), bg: const Color(0xFFEEF2FF));
  }

  return (icon: Icons.build_circle, color: const Color(0xFF6B7280), bg: const Color(0xFFF3F4F6));
}

ServiceIconStyle categoryIconFor(String name) {
  final n = name.trim();

  if (_contains(n, ['listrik', 'kelistrikan'])) {
    return (icon: Icons.electric_bolt, color: const Color(0xFFFFB300), bg: const Color(0xFFFEF3C7));
  }
  if (_contains(n, ['bangun'])) {
    return (icon: Icons.home_repair_service, color: const Color(0xFFFF6B00), bg: const Color(0xFFFFEDD5));
  }
  if (_contains(n, ['kebersihan', 'bersih', 'cuci'])) {
    return (icon: Icons.cleaning_services, color: const Color(0xFF059669), bg: const Color(0xFFD1FAE5));
  }
  if (_contains(n, ['pindah', 'pindahan'])) {
    return (icon: Icons.local_shipping, color: AppColors.primary, bg: const Color(0xFFDBEAFE));
  }
  if (_contains(n, ['kayu', 'furnitur'])) {
    return (icon: Icons.handyman, color: const Color(0xFF7C3AED), bg: const Color(0xFFEDE9FE));
  }
  if (_contains(n, ['ac', 'elektronik'])) {
    return (icon: Icons.ac_unit, color: const Color(0xFF0891B2), bg: const Color(0xFFCFFAFE));
  }
  if (_contains(n, ['cat', 'pengecatan'])) {
    return (icon: Icons.format_paint, color: const Color(0xFFE91E63), bg: const Color(0xFFFCE4EC));
  }
  if (_contains(n, ['taman', 'berkebun'])) {
    return (icon: Icons.yard, color: const Color(0xFF4CAF50), bg: const Color(0xFFE8F5E9));
  }
  if (_contains(n, ['plumbing', 'pipa', 'ledeng'])) {
    return (icon: Icons.plumbing, color: const Color(0xFF00BCD4), bg: const Color(0xFFE0F7FA));
  }
  if (_contains(n, ['kaca'])) {
    return (icon: Icons.window, color: const Color(0xFF6366F1), bg: const Color(0xFFEEF2FF));
  }

  return (icon: Icons.build_circle, color: const Color(0xFF6B7280), bg: const Color(0xFFF3F4F6));
}

bool _contains(String text, List<String> keywords) {
  final lower = text.toLowerCase();
  return keywords.any((k) => lower.contains(k));
}
