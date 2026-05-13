import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatefulWidget {
  final Widget destination;
  final Duration delay;

  const LoadingScreen({
    super.key,
    required this.destination,
    this.delay = const Duration(milliseconds: 2500),
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  static const Color _darkBlue = Color(0xFF1A2E4A);
  static const Color _yellowOrange = Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.destination),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -size.width * 0.22,
            right: -size.width * 0.12,
            child: Container(
              width: size.width * 0.58,
              height: size.width * 0.58,
              decoration: const BoxDecoration(
                color: _yellowOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.42,
            left: -size.width * 0.22,
            child: Container(
              width: size.width * 0.92,
              height: size.width * 0.92,
              decoration: const BoxDecoration(
                color: _yellowOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/AutoMate_logo.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
