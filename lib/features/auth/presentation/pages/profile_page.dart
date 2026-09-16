import 'package:flutter/material.dart';

import '../../../../core/services/session_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SessionService _sessionService = SessionService();

  bool _notifications = true;
  bool _darkMode = true;

  String _name = 'Usuario';
  String _lastName = '';
  String _email = '';

  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _sessionService.getUserName();
    final lastName = await _sessionService.getUserLastName();
    final email = await _sessionService.getUserEmail();

    if (!mounted) return;

    setState(() {
      _name = name?.isNotEmpty == true ? name! : 'Usuario';
      _lastName = lastName ?? '';
      _email = email ?? '';
      _loadingProfile = false;
    });
  }

  String get _fullName {
    final fullName = '$_name $_lastName'.trim();

    if (fullName.isEmpty) {
      return 'Usuario';
    }

    return fullName;
  }

  String get _initial {
    if (_name.trim().isEmpty) {
      return 'U';
    }

    return _name.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C16),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 850;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 950 : 600,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 35 : 20,
                    vertical: 20,
                  ),
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: _buildProfileHeader(),
        ),
        const SizedBox(width: 25),
        Expanded(
          child: _buildSettings(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 25),
        Expanded(
          child: _buildSettings(),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF151624),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF292B40),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFA78BFA),
                  Color(0xFF6D28D9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: _loadingProfile
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 17),

          Text(
            _loadingProfile ? 'Cargando...' : _fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _loadingProfile
                ? 'Cargando información...'
                : (_email.isNotEmpty ? _email : 'Correo no disponible'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF85889D),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(
                Icons.edit_rounded,
                size: 17,
              ),
              label: const Text(
                'Editar perfil',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFA78BFA),
                side: const BorderSide(
                  color: Color(0xFF493574),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        _buildSettingTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notificaciones',
          subtitle: 'Recibir recordatorios de mis tareas',
          trailing: Switch(
            value: _notifications,
            activeThumbColor: const Color(0xFF8B5CF6),
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
        ),

        const SizedBox(height: 10),

        _buildSettingTile(
          icon: Icons.dark_mode_outlined,
          title: 'Modo oscuro',
          subtitle: 'Usar el tema oscuro de la aplicación',
          trailing: Switch(
            value: _darkMode,
            activeThumbColor: const Color(0xFF8B5CF6),
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
        ),

        const SizedBox(height: 10),

        _buildSettingTile(
          icon: Icons.lock_outline_rounded,
          title: 'Cambiar contraseña',
          subtitle: 'Actualiza la contraseña de tu cuenta',
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF777A91),
          ),
          onTap: _changePassword,
        ),

        const SizedBox(height: 10),

        _buildSettingTile(
          icon: Icons.help_outline_rounded,
          title: 'Ayuda y soporte',
          subtitle: 'Obtén ayuda con Gestor de Agenda',
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF777A91),
          ),
          onTap: _showHelp,
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              size: 19,
            ),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF87171),
              side: const BorderSide(
                color: Color(0xFF63333A),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Center(
          child: Text(
            'Gestor de Agenda • Versión 1.0.0',
            style: TextStyle(
              color: Color(0xFF55586B),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF151624),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFF292B40),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: const Color(0xFF211A38),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFA78BFA),
                  size: 21,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF777A91),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile() {
    _showMessage(
      'La edición de perfil estará disponible próximamente',
    );
  }

  void _changePassword() {
    _showMessage(
      'El cambio de contraseña estará disponible próximamente',
    );
  }

  void _showHelp() {
    _showMessage(
      'Centro de ayuda disponible próximamente',
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151624),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            style: TextStyle(
              color: Color(0xFF9698AA),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF9698AA),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Color(0xFFF87171),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _sessionService.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF25263A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}