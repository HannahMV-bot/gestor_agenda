import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'login_page.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _recoverPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Si el correo está registrado, recibirás instrucciones para recuperar tu contraseña.',
        ),
        backgroundColor: const Color(0xFF6D28D9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _backToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF08070D),
      body: SafeArea(
        child: isMobile
            ? _buildMobileLayout()
            : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildSpacePanel(),
        ),
        Expanded(
          flex: 4,
          child: _buildRecoveryPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Positioned.fill(
          child: _buildSpaceBackground(),
        ),
        Positioned.fill(
          child: Container(
            color: const Color(0xFF08070D).withValues(alpha: 0.78),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildRecoveryContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpacePanel() {
    return Stack(
      children: [
        Positioned.fill(
          child: _buildSpaceBackground(),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF24104A).withValues(alpha: 0.25),
                  const Color(0xFF08070D).withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFFEC4899),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6)
                            .withValues(alpha: 0.35),
                        blurRadius: 35,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'GESTOR DE AGENDA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Organiza tu tiempo.\n'
                  'Alcanza tus metas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 35),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFA78BFA),
                        size: 18,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Tu tiempo, bajo control',
                        style: TextStyle(
                          color: Color(0xFFD8B4FE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryPanel() {
    return Container(
      color: const Color(0xFF0D0B14),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 55,
            vertical: 35,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: _buildRecoveryContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón volver
          InkWell(
            onTap: _backToLogin,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF17131F),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF2A2335),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFFA78BFA),
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Volver al inicio de sesión',
                    style: TextStyle(
                      color: Color(0xFFC4B5FD),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Recuperar contraseña',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Ingresa tu correo electrónico y te enviaremos '
            'las instrucciones para recuperar el acceso a tu cuenta.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Correo electrónico',
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 9),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'ejemplo@correo.com',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.28),
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF9B7EDE),
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFF15121D),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF292333),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF292333),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF8B5CF6),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu correo electrónico';
              }

              final emailRegex = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              );

              if (!emailRegex.hasMatch(value.trim())) {
                return 'Ingresa un correo válido';
              }

              return null;
            },
          ),

          const SizedBox(height: 24),

          // Botón recuperar
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFFEC4899),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6)
                        .withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _recoverPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 9),
                          Text(
                            'ENVIAR INSTRUCCIONES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Center(
            child: TextButton(
              onPressed: _backToLogin,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFA78BFA),
              ),
              child: const Text(
                '¿Recordaste tu contraseña? Inicia sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceBackground() {
    return CustomPaint(
      painter: _SpacePainter(),
    );
  }
}

class _SpacePainter extends CustomPainter {
  final math.Random _random = math.Random(8);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55);

    for (int i = 0; i < 120; i++) {
      final double x = _random.nextDouble() * size.width;
      final double y = _random.nextDouble() * size.height;
      final double radius = _random.nextDouble() * 1.4 + 0.2;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        starPaint,
      );
    }

    final Paint planetPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFA78BFA),
          Color(0xFF4C1D95),
          Color(0xFF160B2D),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.78,
            size.height * 0.22,
          ),
          radius: 95,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * 0.78,
        size.height * 0.22,
      ),
      75,
      planetPaint,
    );

    final Paint smallPlanetPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFF0ABFC),
          Color(0xFF701A75),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.16,
            size.height * 0.78,
          ),
          radius: 50,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * 0.16,
        size.height * 0.78,
      ),
      38,
      smallPlanetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}