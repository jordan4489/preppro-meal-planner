import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _loaded = false;

  static String _bannerId() {
    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
      return '';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-8700408294196968/3599699469';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-8700408294196968/3371368672';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb ||
        !(defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return;
    }

    _banner = BannerAd(
      adUnitId: _bannerId(),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _loaded = true);
          }
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) return const SizedBox.shrink();
    return SizedBox(
      height: _banner!.size.height.toDouble(),
      width: _banner!.size.width.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}
