import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;
  String _selectedAvatarUrl = '';

  // Curator high-quality foodie/minimalist avatars
  final List<Map<String, String>> _avatarPresets = [
    {
      'name': 'Chef Mascot',
      'url': 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Tasty Burger',
      'url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Fresh Pizza',
      'url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Cool Ice Cream',
      'url': 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Coffee Love',
      'url': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Sweet Donut',
      'url': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Sushi Master',
      'url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Avocado Toast',
      'url': 'https://images.unsplash.com/photo-1541532713592-79a0317b6b77?w=150&auto=format&fit=crop&q=80'
    },
    {
      'name': 'Hot Ramen',
      'url': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=150&auto=format&fit=crop&q=80'
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _avatarController = TextEditingController(text: user?.avatarUrl ?? '');
    _selectedAvatarUrl = user?.avatarUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkDivider : AppColors.divider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.face_retouching_natural_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Choose an Avatar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a fun food icon that matches your personality',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Grid
                  Expanded(
                    child: GridView.builder(
                      itemCount: _avatarPresets.length,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final avatar = _avatarPresets[index];
                        final isSelected = _selectedAvatarUrl == avatar['url'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedAvatarUrl = avatar['url']!;
                              _avatarController.text = avatar['url']!;
                            });
                            setState(() {
                              _selectedAvatarUrl = avatar['url']!;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10)]
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundImage: NetworkImage(avatar['url']!),
                              backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider),
                  const SizedBox(height: 12),
                  Text(
                    'Or Paste Custom Image URL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _avatarController,
                    hintText: 'Enter image URL (http...)',
                    prefixIcon: Icons.link_outlined,
                    onChanged: (val) {
                      setModalState(() {
                        _selectedAvatarUrl = val.trim();
                      });
                      setState(() {
                        _selectedAvatarUrl = val.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Confirm Avatar',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          avatarUrl: _selectedAvatarUrl.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Profile updated successfully!', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Text(error ?? 'Failed to update profile'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundImage: _selectedAvatarUrl.isNotEmpty ? NetworkImage(_selectedAvatarUrl) : null,
                        backgroundColor: isDark ? AppColors.darkDivider : AppColors.divider,
                        child: _selectedAvatarUrl.isEmpty
                            ? Icon(Icons.person_rounded, size: 64, color: isDark ? Colors.white70 : Colors.black45)
                            : null,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ).animate().scale(delay: 200.ms, duration: 300.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Form fields card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Name',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Email Address',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Enter your email address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Email is required';
                        if (!val.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Mobile Number',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: 'Enter mobile number',
                      prefixIcon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Phone number is required' : null,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Save Changes',
                isLoading: authState.isLoading,
                onPressed: _handleSave,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
