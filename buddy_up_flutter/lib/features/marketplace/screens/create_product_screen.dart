import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../providers/marketplace_provider.dart';

/// Create / edit a marketplace product (creator studio parity with web
/// `/marketplace/products/create`).
class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({super.key, this.editProductId});

  /// When set, the screen loads this product and performs an update.
  final String? editProductId;

  @override
  ConsumerState<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _affiliateUrlController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'equipment';
  bool _loading = false;
  bool _saving = false;
  Map<String, dynamic>? _existing;

  bool get _isEdit => widget.editProductId != null && widget.editProductId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _affiliateUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final res = await repo.getProduct(widget.editProductId!);
      final data = res['data'] as Map<String, dynamic>?;
      if (data != null && mounted) {
        setState(() {
          _existing = data;
          _nameController.text = (data['name'] ?? '') as String;
          _brandController.text = (data['brand'] ?? '') as String;
          _descriptionController.text = (data['description'] ?? '') as String;
          _imageUrlController.text = (data['image_url'] ?? '') as String;
          _affiliateUrlController.text = (data['affiliate_url'] ?? '') as String;
          _priceController.text = (data['price_display'] ?? '') as String;
          _category = (data['category'] ?? 'equipment') as String;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load product.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'brand': _brandController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _category,
      'affiliate_url': _affiliateUrlController.text.trim(),
      if (_imageUrlController.text.trim().isNotEmpty)
        'image_url': _imageUrlController.text.trim(),
      if (_priceController.text.trim().isNotEmpty)
        'price_display': _priceController.text.trim(),
    };
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      if (_isEdit) {
        await repo.updateProduct(widget.editProductId!, data);
      } else {
        await repo.createProduct(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Product updated.' : 'Product created.'),
          backgroundColor: BuddyColors.green,
        ),
      );
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      String message = 'Could not save the product.';
      try {
        final body = e.response?.data;
        if (body is Map && body['errors'] is Map) {
          final errors = body['errors'] as Map;
          message = errors.values.first.toString();
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuddyColors.surface,
      appBar: AppBar(
        backgroundColor: BuddyColors.surface,
        title: Text(_isEdit ? 'Edit Product' : 'Create Product'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: BuddyColors.green))
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Product name *'),
                      validator: (v) =>
                          (v == null || v.trim().length < 2) ? 'Name is required.' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _brandController,
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Brand *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Brand is required.' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      dropdownColor: BuddyColors.surface,
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'supplement', child: Text('Supplement')),
                        DropdownMenuItem(value: 'equipment', child: Text('Equipment')),
                        DropdownMenuItem(value: 'gear', child: Text('Gear')),
                        DropdownMenuItem(value: 'apparel', child: Text('Apparel')),
                        DropdownMenuItem(value: 'book', child: Text('Book / Guide')),
                        DropdownMenuItem(value: 'digital', child: Text('Digital Product')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _category = v ?? 'equipment'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _affiliateUrlController,
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Purchase / affiliate URL *',
                        hintText: 'https://…',
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'URL is required.';
                        final uri = Uri.tryParse(value);
                        if (uri == null || !uri.isAbsolute) return 'Enter a valid URL.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _imageUrlController,
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _priceController,
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Price display (optional)',
                        hintText: 'KSh 2,500',
                      ),
                    ),
                    const SizedBox(height: 24),
                    BuddyButton(
                      label: _isEdit ? 'Save changes' : 'Create product',
                      onPressed: _saving ? null : _save,
                      isLoading: _saving,
                    ),
                    if (_existing != null && (_existing!['affiliate_url'] ?? '') != '')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Product ID: ${_existing!['id']}',
                          style: const TextStyle(
                            color: BuddyColors.textSecondary,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ].map((w) => w).toList(),
                ),
              ),
            ),
    );
  }
}
