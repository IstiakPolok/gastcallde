import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService extends GetxService {
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.createInstance();

  final RxBool isConnected = true.obs;
  StreamSubscription<InternetConnectionStatus>? _subscription;
  bool _isDialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    // Check initial connection status
    _checkConnection();

    // Listen to connectivity changes
    _subscription = _connectionChecker.onStatusChange.listen((
      InternetConnectionStatus status,
    ) {
      final connected = status == InternetConnectionStatus.connected;

      if (isConnected.value != connected) {
        isConnected.value = connected;

        if (connected) {
          _dismissNoInternetDialog();
        } else {
          _showNoInternetDialog();
        }
      }
    });
  }

  Future<void> _checkConnection() async {
    final connected = await _connectionChecker.hasConnection;
    isConnected.value = connected;

    if (!connected) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dismissing by back button
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Message
              Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Loading indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Waiting for connection...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Retry button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Recheck connection
                    final connected = await _connectionChecker.hasConnection;
                    if (connected) {
                      _dismissNoInternetDialog();
                    } else {
                      Get.snackbar(
                        'Still Offline',
                        'Please check your internet connection',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: Duration(seconds: 2),
                        icon: Icon(Icons.wifi_off, color: Colors.white),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      name: 'no_internet_dialog',
    );
  }

  void _dismissNoInternetDialog() {
    if (_isDialogShowing) {
      _isDialogShowing = false;

      // Close the dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Show reconnection success message
      Get.snackbar(
        'Connected',
        'Internet connection restored',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.wifi_rounded, color: Colors.white),
      );
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
