import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:gestor_agenda/core/services/api_service.dart';
import 'package:gestor_agenda/features/agenda/presentation/pages/agenda_list_page.dart';
import 'package:gestor_agenda/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gestor_agenda/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gestor_agenda/core/services/session_service.dart';

import 'register_page.dart';
import 'forgot_pass_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();

      final remoteDataSource = AuthRemoteDataSource(
        apiService: apiService,
      );

      final repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );

final response = await repository.loginWithToken(
  _emailController.text.trim(),
  _passwordController.text,
);

final user = response['user'];

final token = response['token'];

final sessionService = SessionService();

await sessionService.saveSession(
  token: token,
  userId: user['id'],
  name: user['name'],
  lastName: user['last_name'],
  email: user['email'],
);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AgendaListPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2A183F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPassPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF090712),
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
          flex: 6,
          child: _buildSpacePanel(),
        ),
        Expanded(
          flex: 5,
          child: _buildLoginPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 330,
            child: _buildSpacePanel(),
          ),
          _buildLoginPanel(),
        ],
      ),
    );
  }

  Widget _buildSpacePanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF17102A),
            Color(0xFF0B0815),
            Color(0xFF07060D),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SpacePainter(),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF9B5CFF),
                          Color(0xFF5B21B6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF8B5CF6,
                          ).withValues(alpha: 0.35),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Gestor de Agenda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Organiza tu tiempo.\n'
                    'Cumple tus objetivos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.65,
                      ),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6)
                          .withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6)
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text(
                      '✨ Tu tiempo, bajo control',
                      style: TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPanel() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D0A16),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 35,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido de nuevo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.55,
                      ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Correo electrónico',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 9),

                  TextFormField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: _inputDecoration(
                      hint: 'correo@ejemplo.com',
                      icon: Icons.email_outlined,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }

                      if (!value.contains('@')) {
                        return 'Ingresa un correo válido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 9),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: _inputDecoration(
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white
                              .withValues(alpha: 0.45),
                          size: 20,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : _openForgotPassword,
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Color(0xFFA78BFA),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF6D28D9),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8B5CF6,
                            ).withValues(alpha: 0.22),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Colors.transparent,
                          shadowColor:
                              Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'INICIAR SESIÓN',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white
                              .withValues(alpha: 0.10),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          '¿Aún no tienes cuenta?',
                          style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white
                              .withValues(alpha: 0.10),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : _openRegister,
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFFC4B5FD),
                        side: BorderSide(
                          color: const Color(
                            0xFF8B5CF6,
                          ).withValues(alpha: 0.45),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'CREAR CUENTA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'Al continuar aceptas nuestros términos y condiciones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.32),
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.25),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFA78BFA),
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFF15111F),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF8B5CF6),
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
        ),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFF87171),
        fontSize: 11,
      ),
    );
  }
}

class SpacePainter extends CustomPainter {
  final math.Random random = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6);

    for (int i = 0; i < 90; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.3;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        starPaint,
      );
    }

    final planetPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFA78BFA),
          Color(0xFF5B21B6),
          Color(0xFF1E1038),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(100, 100),
          radius: 100,
        ),
      );

    final planetCenter = Offset(
      size.width * 0.18,
      size.height * 0.22,
    );

    canvas.drawCircle(
      planetCenter,
      58,
      planetPaint,
    );

    final ringPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
          .withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawOval(
      Rect.fromCenter(
        center: planetCenter,
        width: 155,
        height: 38,
      ),
      ringPaint,
    );

    final moonPaint = Paint()
      ..color = const Color(0xFFE9D5FF)
          .withValues(alpha: 0.75);

    canvas.drawCircle(
      Offset(
        size.width * 0.82,
        size.height * 0.78,
      ),
      24,
      moonPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}