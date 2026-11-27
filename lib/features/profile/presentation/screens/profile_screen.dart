import 'package:flutter/material.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/design_system/notixa_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLocaleChanged;

  const ProfileScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDark = true;
  String _selectedLang = 'ar';

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج (Logout)'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من Notixa؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NotixaPalette.error),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('خروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب نهائياً'),
        content: const Text('سيتم حذف جميع الملاحظات والبيانات المالية والمواعيد المسجلة ولا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NotixaPalette.error),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const NotixaAppBar(
        title: 'الملف الشخصي والإعدادات',
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: NotixaPalette.primary.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 36, color: NotixaPalette.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مستخدم Notixa',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'user@notixa.ai',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: NotixaPalette.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Group
            Container(
              decoration: BoxDecoration(
                color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
              ),
              child: Column(
                children: [
                  // Theme Mode
                  SwitchListTile(
                    title: const Text('الوضع الداكن (Dark Theme)'),
                    subtitle: const Text('تفعيل السمة الليلية المريحة للعين'),
                    secondary: const Icon(Icons.dark_mode_outlined, color: NotixaPalette.primary),
                    value: _isDark,
                    onChanged: (val) {
                      setState(() => _isDark = val);
                      widget.onThemeChanged(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1),

                  // Language
                  ListTile(
                    leading: const Icon(Icons.language_outlined, color: NotixaPalette.primary),
                    title: const Text('اللغة (Language)'),
                    trailing: DropdownButton<String>(
                      value: _selectedLang,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'ar', child: Text('العربية 🇪🇬')),
                        DropdownMenuItem(value: 'en', child: Text('English 🇺🇸')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLang = val);
                          widget.onLocaleChanged(Locale(val));
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Notifications & Alarms
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: NotixaPalette.primary),
                    title: const Text('إشعارات المنبه والمواعيد'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Legal & About Group
            Container(
              decoration: BoxDecoration(
                color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: NotixaPalette.primary),
                    title: const Text('حول Notixa (About)'),
                    subtitle: const Text('الإصدار 1.0.6 (Build 11)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: NotixaPalette.primary),
                    title: const Text('سياسة الخصوصية (Privacy Policy)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout & Delete Buttons
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: NotixaPalette.error, width: 0.8),
              ),
              leading: const Icon(Icons.logout, color: NotixaPalette.error),
              title: const Text('تسجيل الخروج', style: TextStyle(color: NotixaPalette.error, fontWeight: FontWeight.bold)),
              onTap: _showLogoutDialog,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _showDeleteAccountDialog,
              child: const Text('حذف الحساب نهائياً', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
