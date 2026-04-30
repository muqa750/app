import 'package:flutter/services.dart';

/// Discovers bundled image paths using Flutter's official [AssetManifest] API.
///
/// `AssetManifest.json` is no longer generated; the tool uses `AssetManifest.bin`
/// (see Flutter breaking change). Loading the JSON file fails on web and new SDKs.
class AppAssetManifest {
  AppAssetManifest._();

  static List<String>? _keys;

  static Future<List<String>> _allKeys() async {
    if (_keys != null) return _keys!;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _keys = manifest.listAssets()..sort();
    return _keys!;
  }

  static Future<List<String>> imagePathsUnder(String prefix) async {
    final keys = await _allKeys();
    return keys.where(_isImagePath).where((k) => k.startsWith(prefix)).toList();
  }

  static bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }
}
