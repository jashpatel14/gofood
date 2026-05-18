import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final AddressModel? addressToEdit;

  const AddAddressScreen({super.key, this.addressToEdit});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLineController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  
  String _addressType = 'Home';
  final List<String> _addressTypes = ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    final addr = widget.addressToEdit;
    _nameController = TextEditingController(text: addr?.fullName ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _addressLineController = TextEditingController(text: addr?.addressLine ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _stateController = TextEditingController(text: addr?.state ?? '');
    _pincodeController = TextEditingController(text: addr?.pincode ?? '');
    _addressType = addr?.addressType ?? 'Home';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = AddressModel(
        id: widget.addressToEdit?.id ?? '',
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        addressType: _addressType,
        isDefault: widget.addressToEdit?.isDefault ?? false,
      );

      if (widget.addressToEdit == null) {
        ref.read(addressProvider.notifier).addAddress(newAddress);
      } else {
        ref.read(addressProvider.notifier).updateAddress(newAddress);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(widget.addressToEdit == null ? 'Add New Address' : 'Edit Address'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Please enter full name' : null,
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? 'Please enter valid phone number' : null,
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Address Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressLineController,
                label: 'House No., Building, Street, Area',
                icon: Icons.home_outlined,
                validator: (v) => v!.isEmpty ? 'Please enter address line' : null,
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      cardColor: cardColor,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: 'State',
                      icon: Icons.map_outlined,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      cardColor: cardColor,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.length < 5 ? 'Invalid pincode' : null,
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Save As',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 16),
              Row(
                children: _addressTypes.map((type) {
                  final isSelected = _addressType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _addressType = type),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          type,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Save Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subColor, fontSize: 14),
        prefixIcon: Icon(icon, color: subColor, size: 22),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
