import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

var LoadedAds = {AdManager.interstitialVideoAdPlacementId: false};

class Ads {
  bool iscorrect_platform = Platform.isAndroid || Platform.isIOS;
  static Ads_init() async {
    if (Ads().iscorrect_platform) {
      await UnityAds.init(
        gameId: AdManager.gameId,
        onComplete: () {
          print('Initialization Complete');
          Ads.Load_Interstitial_Ads();
        },
        onFailed: (error, message) =>
            print('Initialization Failed: $error $message'),
      );
    }
  }

  static Widget Show_Banner_Ads() {
    if (Ads().iscorrect_platform) {
      return UnityBannerAd(
        placementId: AdManager.bannerAdPlacementId,
        onLoad: (placementId) => print('Banner loaded: $placementId'),
        onClick: (placementId) => print('Banner clicked: $placementId'),
        onShown: (placementId) => print('Banner shown: $placementId'),
        onFailed: (placementId, error, message) =>
            print('Banner Ad $placementId failed: $error $message'),
      );
    }
    return const Center();
  }

  static Load_Interstitial_Ads() async {
    if (Ads().iscorrect_platform) {
      await UnityAds.load(
        placementId: AdManager.interstitialVideoAdPlacementId,
        onComplete: (placementId) {
          print('Load Complete $placementId');
          LoadedAds[AdManager.interstitialVideoAdPlacementId] = true;
        },
        onFailed: (placementId, error, message) =>
            print('Load Failed $placementId: $error $message'),
      );
    }
  }

  static show_Interstitial_Ads() async {
    if (Ads().iscorrect_platform) {
      UnityAds.showVideoAd(
        placementId: AdManager.interstitialVideoAdPlacementId,
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) {
          print('Video Ad $placementId skipped');
          LoadedAds[AdManager.interstitialVideoAdPlacementId] = false;
          Load_Interstitial_Ads();
        },
        onComplete: (placementId) {
          print('Video Ad $placementId completed');
          LoadedAds[AdManager.interstitialVideoAdPlacementId] = false;
          Load_Interstitial_Ads();
        },
        onFailed: (placementId, error, message) =>
            print('Video Ad $placementId failed: $error $message'),
      );
    }
  }
}

class AdManager {
  static String get gameId {
    if (Platform.isAndroid) {
      return 'xxxxxxx';
    }
    if (Platform.isIOS) {
      return 'xxxxxxx';
    }
    return '';
  }

  static String get bannerAdPlacementId {
    if (Platform.isAndroid) {
      return 'Banner_Android';
    }
    if (Platform.isIOS) {
      return 'Banner_iOS';
    }
    return '';
  }

  static String get interstitialVideoAdPlacementId {
    if (Platform.isAndroid) {
      return 'Interstitial_Android';
    }
    if (Platform.isIOS) {
      return 'Interstitial_iOS';
    }
    return '';
  }

  static String get rewardedVideoAdPlacementId {
    if (Platform.isAndroid) {
      return 'Rewarded_Android';
    }
    if (Platform.isIOS) {
      return 'Rewarded_iOS';
    }
    return '';
  }
}
