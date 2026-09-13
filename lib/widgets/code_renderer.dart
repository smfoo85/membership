import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/code_format.dart';
import '../models/membership_card.dart';
import '../utils/format_mapper.dart';

/// Renders the card's code live from its stored value/format — nothing is
/// ever persisted as an image, so it always scales crisply.
class CodeRenderer extends StatelessWidget {
  const CodeRenderer({super.key, required this.card, this.size, this.formatOverride});

  final MembershipCard card;

  /// Roughly the width/height budget available for the code. Defaults to
  /// filling the available width.
  final double? size;

  /// Renders the card's code value in a different format than the one it
  /// was stored with — a pure display-mode switch (e.g. a barcode/QR toggle)
  /// that doesn't touch the persisted [card.codeFormat].
  final CodeFormat? formatOverride;

  @override
  Widget build(BuildContext context) {
    final format = formatOverride ?? card.codeFormat;
    if (format == CodeFormat.qr) {
      return QrImageView(
        data: card.codeValue,
        version: QrVersions.auto,
        size: size ?? 250,
        backgroundColor: Colors.white,
      );
    }

    return BarcodeWidget(
      barcode: toBarcodeWidgetType(format),
      data: card.codeValue,
      width: size ?? 300,
      height: (size ?? 300) * 0.4,
      color: Colors.black,
      backgroundColor: Colors.white,
      errorBuilder: (context, error) => Center(
        child: Text(
          'Unable to render this code.\n$error',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
