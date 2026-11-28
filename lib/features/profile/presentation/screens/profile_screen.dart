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
              // 1. TOP HEADER (Logo + Notification Bell)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: NotixaPalette.purpleBadge,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.all_inclusive, color: NotixaPalette.primary, size: 22),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Notixa',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NotixaPalette.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
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
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NotixaPalette.purpleBadge,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'FREE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: NotixaPalette.primary,
                                  ),
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

              // 3. USAGE STATS CARD
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
                    // Daily Usage
                    Text(
                      'Daily Usage',
                      style: TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 / 20',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const Text(
                          '95% remaining',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NotixaPalette.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 1 / 20,
                        backgroundColor: NotixaPalette.purpleBadge,
                        valueColor: AlwaysStoppedAnimation<Color>(NotixaPalette.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Monthly Usage
                    Text(
                      'Monthly Usage',
                      style: TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2 / 200',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const Text(
                          '99% remaining',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NotixaPalette.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 2 / 200,
                        backgroundColor: NotixaPalette.purpleBadge,
                        valueColor: AlwaysStoppedAnimation<Color>(NotixaPalette.primary),
                        minHeight: 6,
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
                    _buildSettingsRow(Icons.info_outline, 'About Notixa', null, textPrimary, textMuted, () {}),
                    Divider(height: 1, color: borderColor),
                    _buildSettingsRow(Icons.shield_outlined, 'Privacy Policy', null, textPrimary, textMuted, () {}),
                    Divider(height: 1, color: borderColor),
                    _buildSettingsRow(Icons.email_outlined, 'Contact Support', 'support@notixa.ai', textPrimary, textMuted, () {}),
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
                  'Notixa v1.0.6',
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
