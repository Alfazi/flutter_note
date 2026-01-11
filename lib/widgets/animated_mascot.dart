import 'package:flutter/material.dart';

enum MascotState { idle, typing, coveringEyes, loading, success, failed }

class AnimatedMascot extends StatefulWidget {
  final MascotState state;

  const AnimatedMascot({super.key, required this.state});

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _blinkController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Idle animation - continuous floating
    _idleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Blink animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Bounce animation for success/failed
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.1),
        ).animate(
          CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
        );

    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.state != MascotState.coveringEyes) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      if (widget.state == MascotState.success ||
          widget.state == MascotState.failed) {
        _bounceController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: RotationTransition(
          turns: _rotationAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientColors(),
              ),
              boxShadow: [
                BoxShadow(
                  color: _getGradientColors()[0].withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(child: _buildFace()),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (widget.state) {
      case MascotState.success:
        return [Colors.green.shade400, Colors.green.shade700];
      case MascotState.failed:
        return [Colors.red.shade400, Colors.red.shade700];
      case MascotState.loading:
        return [Colors.orange.shade400, Colors.orange.shade700];
      default:
        return [Colors.blue.shade400, Colors.blue.shade700];
    }
  }

  Widget _buildFace() {
    switch (widget.state) {
      case MascotState.idle:
      case MascotState.typing:
        return _buildDefaultFace();
      case MascotState.coveringEyes:
        return _buildCoveringEyesFace();
      case MascotState.loading:
        return _buildLoadingFace();
      case MascotState.success:
        return _buildSuccessFace();
      case MascotState.failed:
        return _buildFailedFace();
    }
  }

  Widget _buildDefaultFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEye(false),
            const SizedBox(width: 20),
            _buildEye(false),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: 40,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildEye(bool isClosed) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final blinkValue = _blinkController.value;
        return Container(
          width: 15,
          height: isClosed || blinkValue > 0 ? 15 * (1 - blinkValue) : 15,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  Widget _buildCoveringEyesFace() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEye(true),
                    const SizedBox(width: 20),
                    _buildEye(true),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: 30,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 30 - (10 * value),
              left: 20,
              right: 20,
              child: Opacity(
                opacity: value,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text('🙈', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * 3.14159,
              child: const Icon(
                Icons.hourglass_empty,
                color: Colors.white,
                size: 40,
              ),
            );
          },
          onEnd: () {
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildSuccessFace() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHappyEye(value),
                const SizedBox(width: 20),
                _buildHappyEye(value),
              ],
            ),
            const SizedBox(height: 10),
            Transform.scale(
              scale: value,
              child: CustomPaint(
                size: const Size(50, 25),
                painter: SmilePainter(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHappyEye(double animationValue) {
    return Transform.scale(
      scale: animationValue,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.star, color: Colors.yellow, size: 10),
        ),
      ),
    );
  }

  Widget _buildFailedFace() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: value,
                  child: const Text(
                    'X',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Transform.scale(
                  scale: value,
                  child: const Text(
                    'X',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Transform.scale(
              scale: value,
              child: CustomPaint(
                size: const Size(50, 25),
                painter: FrownPainter(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
