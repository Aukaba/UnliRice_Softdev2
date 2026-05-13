import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserOfflineScreen extends StatefulWidget {
  final Widget child;
  const UserOfflineScreen({super.key, required this.child});

  @override
  State<UserOfflineScreen> createState() => _UserOfflineScreenState();
}

class _UserOfflineScreenState extends State<UserOfflineScreen> {
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final offline = results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);
    if (mounted) setState(() => _isOffline = offline);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return _OfflineFallback(onRetry: _checkConnectivity);
    }
    return widget.child;
  }
}

class _OfflineFallback extends StatelessWidget {
  final VoidCallback onRetry;
  const _OfflineFallback({required this.onRetry});

  static const Color _darkBlue = Color(0xFF1A2E4A);
  static const Color _yellowOrange = Color(0xFFF5A623);
  static const Color _greyBlue = Color(0xFF7A8FA6);
  static const Color _borderGrey = Color(0xFFDDE3EA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/AutoMate_logo.png',
                width: 172,
                height: 172,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 0),
              Image.asset(
                'assets/images/nointernet.png',
                width: 266,
                height: 266,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              Text(
                'No Internet Connection',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Try these steps to get back online:',
                style: GoogleFonts.inriaSans(
                  fontSize: 14,
                  color: _greyBlue,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInstructionCard('Check your modem and router'),
              const SizedBox(height: 12),
              _buildInstructionCard('Reconnect to Wi-Fi'),
              const SizedBox(height: 24),
              _buildRetryButton(),
              const SizedBox(height: 24),
              _buildSupportCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderGrey, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank, color: _darkBlue, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inriaSans(
                fontSize: 15,
                color: _greyBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: _darkBlue.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _darkBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Retry Connection',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderGrey, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'Still need help?',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_outlined, color: _yellowOrange, size: 22),
              const SizedBox(width: 8),
              Text(
                'Call: 0988-889-976',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _yellowOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Our support team is available 24/7',
            style: GoogleFonts.inriaSans(
              fontSize: 13,
              color: _greyBlue,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
