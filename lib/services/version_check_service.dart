import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();
  factory VersionCheckService() => _instance;
  VersionCheckService._internal();

  Future<void> checkVersion(BuildContext context) async {
    try {
      // 1. Get current installed version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      debugPrint("Current App Version: $currentVersion");

      // 2. Fetch latest version from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();

      if (!doc.exists) {
        debugPrint("Version config document not found in Firestore.");
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String latestVersion = data['latest_version'] ?? currentVersion;
      String updateMessage = data['update_message'] ?? "A new version is available!";
      bool forceUpdate = data['force_update'] ?? false;
      String storeUrl = data['store_url'] ?? "";

      debugPrint("Latest App Version from Firestore: $latestVersion");

      // 3. Compare versions
      if (_shouldUpdate(currentVersion, latestVersion)) {
        debugPrint("Update triggered: True");
        if (context.mounted) {
          _showUpdateDialog(context, updateMessage, forceUpdate, storeUrl);
        }
      } else {
        debugPrint("Update triggered: False");
      }
    } catch (e) {
      debugPrint("Error checking version: $e");
    }
  }

  bool _shouldUpdate(String currentVersion, String latestVersion) {
    List<String> currentParts = currentVersion.split('.');
    List<String> latestParts = latestVersion.split('.');

    for (int i = 0; i < latestParts.length; i++) {
      int latestPart = int.parse(latestParts[i]);
      int currentPart = i < currentParts.length ? int.parse(currentParts[i]) : 0;

      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }

  void _showUpdateDialog(BuildContext context, String message, bool forceUpdate, String storeUrl) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) => WillPopScope(
        onWillPop: () async => !forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Update Available",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Later"),
              ),
            ElevatedButton(
              onPressed: () => _launchURL(storeUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Update Now", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }
}
