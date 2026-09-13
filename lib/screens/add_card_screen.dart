import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/card_repository.dart';
import '../models/code_format.dart';
import '../models/membership_card.dart';
import '../theme/app_theme.dart';
import '../utils/format_mapper.dart';
import '../widgets/scanner_overlay.dart';

const List<int> _swatchColors = [
  0xFF1976D2, // blue
  0xFFD32F2F, // red
  0xFF388E3C, // green
  0xFFF57C00, // orange
  0xFF7B1FA2, // purple
  0xFF00838F, // teal
  0xFF5D4037, // brown
  0xFF455A64, // blue grey
];

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key, required this.repository, this.existingCard});

  final CardRepository repository;

  /// When set, the screen edits this card in place instead of creating a
  /// new one, and skips straight to the form (no scanning).
  final MembershipCard? existingCard;

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  late bool _showForm = widget.existingCard != null;

  final _formKey = GlobalKey<FormState>();
  late final _storeNameController = TextEditingController(text: widget.existingCard?.storeName);
  late final _codeValueController = TextEditingController(text: widget.existingCard?.codeValue);
  late final _nicknameController = TextEditingController(text: widget.existingCard?.nickname);
  late final _notesController = TextEditingController(text: widget.existingCard?.notes);

  late CodeFormat _codeFormat = widget.existingCard?.codeFormat ?? CodeFormat.code128;
  late int _colorValue = widget.existingCard?.colorValue ?? _swatchColors.first;
  String? _logoPath;
  MobileScannerController? _scannerController;

  bool get _isEditing => widget.existingCard != null;

  @override
  void initState() {
    super.initState();
    _logoPath = widget.existingCard?.logoPath;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _codeValueController.dispose();
    _nicknameController.dispose();
    _notesController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_showForm) return; // already moved to the form, ignore further scans
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _codeValueController.text = rawValue;
      _codeFormat = mapScannerFormat(barcode!.format);
      _showForm = true;
    });
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final extension = picked.path.split('.').last;
    final savedPath = '${docsDir.path}/logo_${const Uuid().v4()}.$extension';
    await File(picked.path).copy(savedPath);

    setState(() => _logoPath = savedPath);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nickname = _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    final existing = widget.existingCard;
    if (existing != null) {
      existing
        ..storeName = _storeNameController.text.trim()
        ..codeValue = _codeValueController.text.trim()
        ..codeFormat = _codeFormat
        ..logoPath = _logoPath
        ..colorValue = _colorValue
        ..nickname = nickname
        ..notes = notes;
      await widget.repository.update(existing);
    } else {
      final card = MembershipCard(
        id: const Uuid().v4(),
        storeName: _storeNameController.text.trim(),
        codeValue: _codeValueController.text.trim(),
        codeFormat: _codeFormat,
        logoPath: _logoPath,
        colorValue: _colorValue,
        nickname: nickname,
        dateAdded: DateTime.now(),
        notes: notes,
      );
      await widget.repository.add(card);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showForm) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(child: _buildScanner(context)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit card' : 'Card details'),
      ),
      body: _buildForm(context),
    );
  }

  Widget _buildScanner(BuildContext context) {
    _scannerController ??= MobileScannerController();
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
          overlayBuilder: (context, constraints) => const ScannerOverlay(),
          errorBuilder: (context, error, child) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Camera unavailable: ${error.errorDetails?.message ?? error.errorCode.name}\n\n'
                'You can still add a card manually.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        // Top toolbar: close, sensor status, torch.
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassIconButton(
                icon: Icons.close,
                tooltip: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SENSOR ACTIVE',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: _scannerController!,
                builder: (context, state, _) {
                  final torchOn = state.torchState == TorchState.on;
                  return _GlassIconButton(
                    icon: torchOn ? Icons.flash_on : Icons.flash_off,
                    tooltip: 'Toggle torch',
                    active: torchOn,
                    onPressed: () => _scannerController!.toggleTorch(),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Align barcode or QR code within the frame',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Hold steady • Auto-captures instantly',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  color: AppColors.surfaceHigh.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _showForm = true),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            "Can't scan? Enter card numbers manually",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 13, color: Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Text(
                    'Secure local processing on device',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickLogo,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(_colorValue),
                backgroundImage: _logoPath != null ? FileImage(File(_logoPath!)) : null,
                child: _logoPath == null
                    ? const Icon(Icons.add_a_photo_outlined, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _pickLogo,
              child: Text(_logoPath == null ? 'Add logo (optional)' : 'Change logo'),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _storeNameController,
            decoration: const InputDecoration(
              labelText: 'Store name',
              prefixIcon: Icon(Icons.storefront_outlined, size: 20),
            ),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _codeValueController,
            style: AppTheme.codeDisplay,
            decoration: const InputDecoration(
              labelText: 'Card number / code',
              prefixIcon: Icon(Icons.tag, size: 20),
            ),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CodeFormat>(
            value: _codeFormat,
            decoration: const InputDecoration(labelText: 'Code format'),
            items: CodeFormat.values
                .map((format) => DropdownMenuItem(value: format, child: Text(format.label)))
                .toList(),
            onChanged: (format) {
              if (format != null) setState(() => _codeFormat = format);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(labelText: 'Nickname (optional)'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: _swatchColors.map((value) {
              final selected = value == _colorValue;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = value),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(value),
                  child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Save card'),
          )),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.tertiary : AppColors.cardSurface.withValues(alpha: 0.8),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, size: 20, color: active ? AppColors.onSurface : Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
