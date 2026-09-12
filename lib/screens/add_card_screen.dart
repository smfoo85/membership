import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/card_repository.dart';
import '../models/code_format.dart';
import '../models/membership_card.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit card' : (_showForm ? 'Card details' : 'Add a card')),
        actions: [
          if (!_showForm)
            TextButton(
              onPressed: () => setState(() => _showForm = true),
              child: const Text('Enter manually', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _showForm ? _buildForm(context) : _buildScanner(context),
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
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Line up your card\'s barcode or QR code',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
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
            decoration: const InputDecoration(labelText: 'Store name', border: OutlineInputBorder()),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _codeValueController,
            decoration: const InputDecoration(labelText: 'Card number / code', border: OutlineInputBorder()),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CodeFormat>(
            value: _codeFormat,
            decoration: const InputDecoration(labelText: 'Code format', border: OutlineInputBorder()),
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
            decoration: const InputDecoration(labelText: 'Nickname (optional)', border: OutlineInputBorder()),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
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
