import 'package:flutter/material.dart';
import '../../../../app/theme/notixa_palette.dart';

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
  bool _isDark = false;
  String _language = 'English'; // 'English' or 'Arabic'
  String _currency = 'EGP';

  final List<Map<String, String>> _personalNotes = [
    {
      'title': 'أفكار مشروع NEXA',
      'content': 'تطوير الباك إند بالكامل والربط مع Gemini API',
      'category': 'عمل',
      'date': 'اليوم • 7:15 AM',
    },
    {
      'title': 'ملاحظات ومهام شخصية',
      'content': 'متابعة المصروفات اليومية وتنظيم المواعيد',
      'category': 'شخصي',
      'date': 'أمس',
    },
  ];

  void _openCreateNoteModal() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String category = 'شخصي';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ملاحظة جديدة (New Note)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight),
                      decoration: InputDecoration(
                        labelText: 'عنوان الملاحظة',
                        filled: true,
                        fillColor: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightFieldFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      style: TextStyle(color: isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight),
                      decoration: InputDecoration(
                        labelText: 'محتوى الملاحظة...',
                        filled: true,
                        fillColor: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightFieldFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isNotEmpty) {
                            setState(() {
                              _personalNotes.insert(0, {
                                'title': titleController.text.trim(),
                                'content': contentController.text.trim(),
                                'category': category,
                                'date': 'الآن',
                              });
                            });
                            Navigator.of(ctx).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NotixaPalette.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('حفظ الملاحظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? NotixaPalette.darkBackground : NotixaPalette.lightBackground;
    final cardBg = isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard;
    final textPrimary = isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight;
    final textMuted = isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight;
    final borderColor = isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (NEXA Logo + Notification Bell)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/nexa_logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none_outlined, color: textPrimary, size: 26),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF43F5E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. USER PROFILE HERO CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar Box
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: NotixaPalette.purpleBadge,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'MM',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: NotixaPalette.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'M MÃKRÃM',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'mohamedahmedmkram...',
                                style: TextStyle(fontSize: 12, color: textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Personal Edition',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: NotixaPalette.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NotixaPalette.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. PERSONAL NOTES CARD (Replacing usage quotas with personal notes)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Personal Notes',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textPrimary),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: NotixaPalette.purpleBadge,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_personalNotes.length}',
                                style: const TextStyle(
                                  color: NotixaPalette.purpleBadgeText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _openCreateNoteModal,
                          icon: const Icon(Icons.add, size: 16, color: NotixaPalette.primary),
                          label: const Text(
                            'Write Note',
                            style: TextStyle(color: NotixaPalette.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_personalNotes.isNotEmpty) ...[
                      ...List.generate(_personalNotes.length, (nIdx) {
                        final n = _personalNotes[nIdx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? NotixaPalette.darkSurface : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: const BoxDecoration(
                                  color: NotixaPalette.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title'] ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      n['content'] ?? '',
                                      style: TextStyle(fontSize: 12, color: textMuted),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['date'] ?? '',
                                      style: TextStyle(fontSize: 10, color: textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _personalNotes.removeAt(nIdx);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'لا توجد ملاحظات مكتوبة حالياً. اضغط "Write Note" لإضافة ملاحظة.',
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. PREFERENCES SECTION
              Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Language Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildIconCircle(Icons.language, NotixaPalette.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                                Text('English / Arabic', style: TextStyle(fontSize: 11, color: textMuted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? NotixaPalette.darkSurface : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                _buildTogglePill('English', _language == 'English', () {
                                  setState(() => _language = 'English');
                                  widget.onLocaleChanged(const Locale('en'));
                                }),
                                _buildTogglePill('Arabic', _language == 'Arabic', () {
                                  setState(() => _language = 'Arabic');
                                  widget.onLocaleChanged(const Locale('ar'));
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: borderColor),

                    // Theme Mode Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildIconCircle(Icons.brightness_medium, NotixaPalette.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Theme Mode',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? NotixaPalette.darkSurface : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                _buildIconPill(Icons.wb_sunny_rounded, !_isDark, () {
                                  setState(() => _isDark = false);
                                  widget.onThemeChanged(ThemeMode.light);
                                }),
                                _buildIconPill(Icons.nightlight_round, _isDark, () {
                                  setState(() => _isDark = true);
                                  widget.onThemeChanged(ThemeMode.dark);
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: borderColor),

                    // Currency Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildIconCircle(Icons.attach_money, NotixaPalette.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                                Text('Used for expenses', style: TextStyle(fontSize: 11, color: textMuted)),
                              ],
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currency,
                              icon: Icon(Icons.arrow_drop_down, color: textMuted),
                              style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 14),
                              items: const [
                                DropdownMenuItem(value: 'EGP', child: Text('🇪🇬 EGP')),
                                DropdownMenuItem(value: 'USD', child: Text('🇺🇸 USD')),
                                DropdownMenuItem(value: 'SAR', child: Text('🇸🇦 SAR')),
                                DropdownMenuItem(value: 'AED', child: Text('🇦🇪 AED')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _currency = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. ACCOUNT & SUPPORT SECTION
              Text(
                'ACCOUNT & SUPPORT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildSettingsRow(Icons.info_outline, 'About Nexa', null, textPrimary, textMuted, () {}),
                    Divider(height: 1, color: borderColor),
                    _buildSettingsRow(Icons.shield_outlined, 'Privacy Policy', null, textPrimary, textMuted, () {}),
                    Divider(height: 1, color: borderColor),
                    _buildSettingsRow(Icons.email_outlined, 'Contact Support', 'support@nexa.ai', textPrimary, textMuted, () {}),
                    Divider(height: 1, color: borderColor),
                    _buildSettingsRow(Icons.logout, 'Logout', null, const Color(0xFFEF4444), textMuted, () {}),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. DANGER ZONE SECTION
              Text(
                'DANGER ZONE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      _buildIconCircle(Icons.delete_outline, const Color(0xFFEF4444)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delete Account',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFEF4444)),
                            ),
                            Text(
                              'Permanently remove your account',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: textMuted, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 7. FOOTER VERSION
              Center(
                child: Text(
                  'Nexa v1.0.6',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildTogglePill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? NotixaPalette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildIconPill(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? NotixaPalette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    IconData icon,
    String title,
    String? subtitle,
    Color titleColor,
    Color subtitleColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconCircle(icon, titleColor == const Color(0xFFEF4444) ? const Color(0xFFEF4444) : Colors.grey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: subtitleColor)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: subtitleColor, size: 20),
          ],
        ),
      ),
    );
  }
}
