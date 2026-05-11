import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEditing = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  static const _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFields());
  }

  void _syncFields() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _bioCtrl.text = user.bio ?? '';
      _phoneCtrl.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AvatarSourceSheet(),
    );
    if (source == null || !mounted) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.uploadAvatar(File(picked.path));

    if (!mounted) return;
    if (!success) {
      _showSnack(auth.error ?? 'Failed to upload photo.', Colors.red.shade700);
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      name: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      setState(() => _isEditing = false);
      _showSnack('Profile updated successfully!', Colors.green.shade600);
    } else {
      _showSnack(
        auth.error ?? 'Failed to update profile.',
        Colors.red.shade700,
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) _syncFields();
      _isEditing = !_isEditing;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(auth, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(user),
                    const SizedBox(height: 24),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _isEditing
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: _buildInfoSection(user),
                      secondChild: _buildEditSection(auth),
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsCard(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(AuthProvider auth, UserModel user) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(
            _isEditing ? Icons.close_rounded : Icons.edit_rounded,
            color: Colors.white,
          ),
          onPressed: _toggleEdit,
          tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF3B37C8)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                AvatarWidget(
                  photoUrl: user.photoUrl,
                  name: user.name,
                  radius: 52,
                  onTap: _pickAvatar,
                  showEditIcon: true,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.calendar_month_rounded,
          label: 'Member Since',
          value: _formatDate(user.createdAt),
        ),
        const SizedBox(width: 12),
        const _StatCard(
          icon: Icons.verified_rounded,
          label: 'Account Status',
          value: 'Active',
          valueColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInfoSection(UserModel user) {
    if (user.bio == null && user.phone == null) {
      return _EmptyInfoBanner(onTap: _toggleEdit);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Info',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (user.bio != null && user.bio!.isNotEmpty)
          _InfoTile(
            icon: Icons.info_outline_rounded,
            label: 'Bio',
            value: user.bio!,
          ),
        if (user.phone != null && user.phone!.isNotEmpty)
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone!,
          ),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
      ],
    );
  }

  Widget _buildEditSection(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _nameCtrl,
          label: 'Full Name',
          hint: 'Your name',
          icon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _bioCtrl,
          label: 'Bio',
          hint: 'Tell something about yourself…',
          icon: Icons.info_outline_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _phoneCtrl,
          label: 'Phone',
          hint: '+7 700 000 0000',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Save Changes',
          isLoading: auth.isLoading,
          onPressed: _saveProfile,
          icon: Icons.check_rounded,
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return _SettingsCard(
      items: [
        _SettingsItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: () {
            _showSnack('Notifications settings coming soon 🔔', Colors.blue);
          },
        ),

        _SettingsItem(
          icon: Icons.security_outlined,
          label: 'Privacy & Security',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Privacy & Security 🔒'),
                content: const Text(
                  'Your data is encrypted and securely stored.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),

        _SettingsItem(
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Help & Support 🆘'),
                content: const Text(
                  'Email: support@smarttask.app\n'
                  'Phone: +7 700 690 1946',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),

        _SettingsItem(
          icon: Icons.info_outline_rounded,
          label: 'About SmartTask',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'SmartTask',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2026 SmartTask Team',
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade400, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ── Bottom sheet for picking avatar source ─────────────────────────────────

class _AvatarSourceSheet extends StatelessWidget {
  const _AvatarSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Change Profile Photo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _SourceTile(
            icon: Icons.camera_alt_rounded,
            label: 'Take a Photo',
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          _SourceTile(
            icon: Icons.photo_library_rounded,
            label: 'Choose from Gallery',
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF6C63FF)),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyInfoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyInfoBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.person_add_alt_rounded,
              color: Color(0xFF6C63FF),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Complete your profile',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Add a bio and phone number to personalize your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.indexed.map((entry) {
          final (index, item) = entry;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 18,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
                onTap: item.onTap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
