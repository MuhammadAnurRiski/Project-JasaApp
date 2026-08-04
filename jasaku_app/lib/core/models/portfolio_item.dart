import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

enum PortfolioType { image, file, link }

class PortfolioItem {
  final PortfolioType type;
  final String url;
  final String label;

  const PortfolioItem({
    required this.type,
    required this.url,
    this.label = '',
  });

  bool get isImage => type == PortfolioType.image;
  bool get isFile => type == PortfolioType.file;
  bool get isLink => type == PortfolioType.link;

  String get displayLabel {
    final t = label.trim();
    if (t.isNotEmpty) return t;
    return url;
  }

  factory PortfolioItem.fromEncoded(dynamic raw) {
    Map<String, dynamic>? map;
    if (raw is Map) {
      map = Map<String, dynamic>.from(raw);
    } else if (raw is String) {
      final t = raw.trim();
      if (t.startsWith('{')) {
        try {
          final decoded = jsonDecode(t);
          if (decoded is Map) {
            map = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
      if (map == null) {
        return PortfolioItem(type: PortfolioType.image, url: t);
      }
    } else {
      return const PortfolioItem(type: PortfolioType.image, url: '');
    }
    final typeStr = (map['type'] as String?) ?? 'image';
    final type = typeStr == 'file'
        ? PortfolioType.file
        : typeStr == 'link'
            ? PortfolioType.link
            : PortfolioType.image;
    return PortfolioItem(
      type: type,
      url: (map['url'] as String?) ?? '',
      label: (map['label'] as String?) ?? '',
    );
  }

  String encode() => jsonEncode({
        'type': type.name,
        'url': url,
        'label': label,
      });

  Future<bool> open() async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class NewPortfolioFile {
  final File file;
  final PortfolioType type;
  final String label;

  const NewPortfolioFile({
    required this.file,
    required this.type,
    this.label = '',
  });
}
