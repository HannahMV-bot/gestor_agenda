import 'package:flutter/material.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/session_service.dart';
import '../../data/datasources/agenda_remote_data_source.dart';
import '../../data/repositories/agenda_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import 'task_form_page.dart';

class AgendaListPage extends StatefulWidget {
  const AgendaListPage({super.key});

  @override
  State<AgendaListPage> createState() => _AgendaListPageState();
}

class _AgendaListPageState extends State<AgendaListPage> {
  late final AgendaRepositoryImpl _repository;

  List<Task> _tasks = [];

  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedFilter = 'Todas';

  String _userName = 'Hannah';

  @override
  void initState() {
    super.initState();

    final apiService = ApiService();

    final remoteDataSource = AgendaRemoteDataSource(
      apiService: apiService,
    );

    _repository = AgendaRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    _loadUser();
    _loadTasks();
  }

  // ============================================================
  // USUARIO
  // ============================================================

  Future<void> _loadUser() async {
    try {
      final sessionService = SessionService();

      final name = await sessionService.getUserName();

      if (!mounted) return;

      if (name != null && name.trim().isNotEmpty) {
        setState(() {
          _userName = name.trim();
        });
      }
    } catch (_) {
      // Mantiene Hannah como nombre de respaldo.
    }
  }

  // ============================================================
  // CARGAR TAREAS
  // ============================================================

  Future<void> _loadTasks() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final tasks = await _repository.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron cargar las tareas.',
          ),
          backgroundColor: const Color(0xFFE05260),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // ============================================================
  // TAREAS FILTRADAS
  // ============================================================

  List<Task> get _filteredTasks {
    List<Task> result = List<Task>.from(_tasks);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();

      result = result.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }).toList();
    }

    switch (_selectedFilter) {
      case 'Pendientes':
        result = result.where((task) {
          return task.status.toLowerCase() == 'pendiente';
        }).toList();
        break;

      case 'Completadas':
        result = result.where((task) {
          return task.status.toLowerCase() == 'completada' ||
              task.status.toLowerCase() == 'completado';
        }).toList();
        break;

      case 'Alta':
        result = result.where((task) {
          return task.priority.toLowerCase() == 'alta';
        }).toList();
        break;

      case 'Media':
        result = result.where((task) {
          return task.priority.toLowerCase() == 'media';
        }).toList();
        break;

      case 'Baja':
        result = result.where((task) {
          return task.priority.toLowerCase() == 'baja';
        }).toList();
        break;
    }

    return result;
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  int get _pendingCount {
    return _tasks.where((task) {
      return task.status.toLowerCase() == 'pendiente';
    }).length;
  }

  int get _completedCount {
    return _tasks.where((task) {
      return task.status.toLowerCase() == 'completada' ||
          task.status.toLowerCase() == 'completado';
    }).length;
  }

  int get _highPriorityCount {
    return _tasks.where((task) {
      return task.priority.toLowerCase() == 'alta';
    }).length;
  }

  // ============================================================
  // CREAR
  // ============================================================

  Future<void> _openCreateTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TaskFormPage(),
      ),
    );

    if (!mounted) return;

    if (result is Map && result['saved'] == true) {
      await _loadTasks();
    }
  }

  // ============================================================
  // EDITAR
  // ============================================================

  Future<void> _openEditTask(Task task) async {
final taskData = <String, dynamic>{
  'id': task.id,
  'user_id': task.userId,
  'title': task.title,
  'description': task.description,
  'date': task.date,
  'time': task.time,
  'status': task.status,
  'priority': task.priority,
};

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(
          task: taskData,
        ),
      ),
    );

    if (!mounted) return;

    if (result is Map && result['saved'] == true) {
      await _loadTasks();
    }
  }

  // ============================================================
  // ELIMINAR
  // ============================================================

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19152A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Eliminar tarea',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            '¿Deseas eliminar "${task.title}"?',
            style: const TextStyle(
              color: Colors.white60,
              height: 1.5,
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
                  color: Colors.white54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE05260),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _repository.deleteTask(task.id);

      if (!mounted) return;

      setState(() {
        _tasks.removeWhere(
          (item) => item.id == task.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tarea eliminada correctamente',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo eliminar la tarea.',
          ),
          backgroundColor: Color(0xFFE05260),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19152A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            '¿Quieres cerrar tu sesión?',
            style: TextStyle(
              color: Colors.white60,
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
                  color: Colors.white54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final sessionService = SessionService();

    await sessionService.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // IR A PERFIL
  // ============================================================

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfilePage(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0913),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            if (isMobile) {
              return _buildMobileLayout();
            }

            return _buildDesktopLayout();
          },
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return const SizedBox.shrink();
          }

          return _buildBottomNavigation();
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),

        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildDesktopHeader(),
              ),
              SliverToBoxAdapter(
                child: _buildToolbar(false),
              ),
              SliverToBoxAdapter(
                child: _buildFilters(false),
              ),
              SliverToBoxAdapter(
                child: _buildStatistics(false),
              ),
              SliverToBoxAdapter(
                child: _buildSectionTitle(false),
              ),
              _buildTaskContent(false),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildMobileHeader(),
        ),
        SliverToBoxAdapter(
          child: _buildToolbar(true),
        ),
        SliverToBoxAdapter(
          child: _buildFilters(true),
        ),
        SliverToBoxAdapter(
          child: _buildStatistics(true),
        ),
        SliverToBoxAdapter(
          child: _buildSectionTitle(true),
        ),
        _buildTaskContent(true),
      ],
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Container(
      width: 235,
      decoration: BoxDecoration(
        color: const Color(0xFF100D1B),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // LOGO
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFFB45CFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 11),

                const Expanded(
                  child: Text(
                    'Gestor de Agenda',
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // MENÚ
          _buildSidebarItem(
            icon: Icons.dashboard_rounded,
            label: 'Mi agenda',
            selected: true,
            onTap: () {},
          ),

          _buildSidebarItem(
            icon: Icons.person_outline_rounded,
            label: 'Mi perfil',
            selected: false,
            onTap: _openProfile,
          ),

          const Spacer(),

          // USUARIO
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF19152A),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFFB45CFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    _userName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  color: const Color(0xFF211B38),
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white38,
                    size: 19,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _logout();
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFE05260),
                              size: 18,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: Color(0xFFE05260),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 3,
      ),
      child: Material(
        color: selected
            ? const Color(0xFF8B5CF6)
                .withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: selected
                  ? Border.all(
                      color: const Color(0xFF8B5CF6)
                          .withValues(alpha: 0.12),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? const Color(0xFFB45CFF)
                      : Colors.white38,
                  size: 20,
                ),

                const SizedBox(width: 12),

                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white54,
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER DESKTOP
  // ============================================================

  Widget _buildDesktopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        38,
        28,
        38,
        22,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFFB45CFF),
                ],
              ),
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6)
                      .withValues(alpha: 0.20),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi agenda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Organiza tus tareas y mantén todo bajo control',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _buildRefreshButton(),

          const SizedBox(width: 10),

          _buildUserChip(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER MOBILE
  // ============================================================

  Widget _buildMobileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        22,
        18,
        18,
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFFB45CFF),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi agenda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Organiza tu día',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          _buildRefreshButton(),

          const SizedBox(width: 8),

          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFF19152A),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFFB45CFF),
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Widget _buildRefreshButton() {
    return Material(
      color: const Color(0xFF19152A),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _loadTasks,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.white60,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // USUARIO
  // ============================================================

  Widget _buildUserChip() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF19152A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFB45CFF),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSCADOR
  // ============================================================

  Widget _buildToolbar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 38,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF15111F),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                cursorColor: const Color(0xFFB45CFF),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF15111F),
                  hoverColor: Colors.transparent,
                  hintText: 'Buscar tareas...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white38,
                            size: 18,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF8B5CF6),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          if (!isMobile)
            _buildNewTaskButton()
          else
            _buildMobileNewTaskButton(),
        ],
      ),
    );
  }

  // ============================================================
  // BOTÓN NUEVA TAREA DESKTOP
  // ============================================================

  Widget _buildNewTaskButton() {
    return SizedBox(
      width: 145,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _openCreateTask,
        icon: const Icon(
          Icons.add_rounded,
          size: 19,
        ),
        label: const Text(
          'Nueva tarea',
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(145, 50),
          maximumSize: const Size(145, 50),
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTÓN NUEVA TAREA MOBILE
  // ============================================================

  Widget _buildMobileNewTaskButton() {
    return Material(
      color: const Color(0xFF8B5CF6),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: _openCreateTask,
        borderRadius: BorderRadius.circular(15),
        child: const SizedBox(
          width: 50,
          height: 50,
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTROS
  // ============================================================

  Widget _buildFilters(bool isMobile) {
    const filters = [
      'Todas',
      'Pendientes',
      'Completadas',
      'Alta',
      'Media',
      'Baja',
    ];

    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 4,
      ),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 38,
          ),
          itemCount: filters.length,
          separatorBuilder: (_, _) {
            return const SizedBox(
              width: 8,
            );
          },
          itemBuilder: (context, index) {
            final filter = filters[index];
            final selected = _selectedFilter == filter;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF171327),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white54,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  Widget _buildStatistics(bool isMobile) {
    final statistics = [
      _StatisticData(
        title: 'Total',
        value: _tasks.length,
        icon: Icons.calendar_today_rounded,
      ),
      _StatisticData(
        title: 'Pendientes',
        value: _pendingCount,
        icon: Icons.schedule_rounded,
      ),
      _StatisticData(
        title: 'Completadas',
        value: _completedCount,
        icon: Icons.check_circle_outline_rounded,
      ),
      _StatisticData(
        title: 'Alta prioridad',
        value: _highPriorityCount,
        icon: Icons.priority_high_rounded,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 38,
        20,
        isMobile ? 18 : 38,
        20,
      ),
      child: isMobile
          ? SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statistics.length,
                separatorBuilder: (_, _) {
                  return const SizedBox(
                    width: 9,
                  );
                },
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 145,
                    child: _buildStatisticCard(
                      statistics[index],
                    ),
                  );
                },
              ),
            )
          : Row(
              children: [
                for (int i = 0; i < statistics.length; i++) ...[
                  Expanded(
                    child: _buildStatisticCard(
                      statistics[i],
                    ),
                  ),
                  if (i < statistics.length - 1)
                    const SizedBox(
                      width: 11,
                    ),
                ],
              ],
            ),
    );
  }

  Widget _buildStatisticCard(
    _StatisticData data,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF15111F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              data.icon,
              color: const Color(0xFFB45CFF),
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  Widget _buildSectionTitle(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 38,
        0,
        isMobile ? 18 : 38,
        12,
      ),
      child: Row(
        children: [
          const Text(
            'Tareas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '${_filteredTasks.length}',
              style: const TextStyle(
                color: Color(0xFFB45CFF),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const Spacer(),

          if (_filteredTasks.isNotEmpty)
            Text(
              '${_filteredTasks.length} tareas',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENIDO DE TAREAS
  // ============================================================

  Widget _buildTaskContent(bool isMobile) {
    if (_isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9B5CFF),
          ),
        ),
      );
    }

    if (_filteredTasks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 38,
        0,
        isMobile ? 18 : 38,
        35,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final task = _filteredTasks[index];

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: _buildTaskCard(
                task,
                isMobile,
              ),
            );
          },
          childCount: _filteredTasks.length,
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA
  // ============================================================

  Widget _buildTaskCard(
    Task task,
    bool isMobile,
  ) {
    return Material(
      color: const Color(0xFF15111F),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openEditTask(task),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(
            isMobile ? 15 : 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),
          child: isMobile
              ? _buildMobileTask(task)
              : _buildDesktopTask(task),
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DESKTOP
  // ============================================================

  Widget _buildDesktopTask(Task task) {
    return Row(
      children: [
        _buildTaskIcon(task),

        const SizedBox(width: 15),

        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                task.description.isEmpty
                    ? 'Sin descripción'
                    : task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: _buildDateInfo(
                  Icons.calendar_today_rounded,
                  _formatDate(task.date),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildDateInfo(
                  Icons.access_time_rounded,
                  _formatTime(task.time),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        _buildStatusBadge(task.status),

        const SizedBox(width: 7),

        _buildPriorityBadge(task.priority),

        const SizedBox(width: 3),

        _buildTaskMenu(task),
      ],
    );
  }

  // ============================================================
  // TARJETA MOBILE
  // ============================================================

  Widget _buildMobileTask(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskIcon(task),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    task.description.isEmpty
                        ? 'Sin descripción'
                        : task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            _buildTaskMenu(task),
          ],
        ),

        const SizedBox(height: 13),

        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _buildStatusBadge(task.status),
            _buildPriorityBadge(task.priority),
          ],
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: _buildDateInfo(
                Icons.calendar_today_rounded,
                _formatDate(task.date),
              ),
            ),

            Expanded(
              child: _buildDateInfo(
                Icons.access_time_rounded,
                _formatTime(task.time),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ICONO TAREA
  // ============================================================

  Widget _buildTaskIcon(Task task) {
    IconData icon;

    switch (task.priority.toLowerCase()) {
      case 'alta':
        icon = Icons.priority_high_rounded;
        break;

      case 'media':
        icon = Icons.timelapse_rounded;
        break;

      default:
        icon = Icons.task_alt_rounded;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C3AED),
            Color(0xFFB45CFF),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 21,
      ),
    );
  }

  // ============================================================
  // ESTADO
  // ============================================================

  Widget _buildStatusBadge(String status) {
    final completed =
        status.toLowerCase() == 'completada' ||
            status.toLowerCase() == 'completado';

    final color = completed
        ? const Color(0xFF34D399)
        : const Color(0xFFFBBF24);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            size: 12,
            color: color,
          ),

          const SizedBox(width: 5),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIORIDAD
  // ============================================================

  Widget _buildPriorityBadge(String priority) {
    Color textColor;

    switch (priority.toLowerCase()) {
      case 'alta':
        textColor = const Color(0xFFFF6B81);
        break;

      case 'media':
        textColor = const Color(0xFFFBBF24);
        break;

      default:
        textColor = const Color(0xFF60A5FA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // FECHA / HORA
  // ============================================================

  Widget _buildDateInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white38,
          size: 14,
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MENÚ TAREA
  // ============================================================

  Widget _buildTaskMenu(Task task) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones',
      color: const Color(0xFF211B38),
      elevation: 8,
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Colors.white38,
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          _openEditTask(task);
        }

        if (value == 'delete') {
          _deleteTask(task);
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 10),
                Text(
                  'Editar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE05260),
                  size: 18,
                ),
                SizedBox(width: 10),
                Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Color(0xFFE05260),
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================

  Widget _buildEmptyState() {
    String title = 'No hay tareas';

    String subtitle =
        'Crea una tarea para comenzar a organizar tu agenda.';

    if (_searchQuery.trim().isNotEmpty) {
      title = 'Sin resultados';

      subtitle =
          'No encontramos tareas que coincidan con tu búsqueda.';
    } else if (_selectedFilter != 'Todas') {
      title = 'No hay tareas aquí';

      subtitle =
          'Prueba seleccionando otro filtro.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: Color(0xFFB45CFF),
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            SizedBox(
              width: 350,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_tasks.isEmpty)
              SizedBox(
                width: 145,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: _openCreateTask,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Crear tarea',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BARRA INFERIOR MOBILE
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF100D1B),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomItem(
            icon: Icons.dashboard_rounded,
            label: 'Agenda',
            selected: true,
            onTap: () {},
          ),

          _buildBottomItem(
            icon: Icons.add_circle_outline_rounded,
            label: 'Nueva',
            selected: false,
            onTap: _openCreateTask,
          ),

          _buildBottomItem(
            icon: Icons.person_outline_rounded,
            label: 'Perfil',
            selected: false,
            onTap: _openProfile,
          ),

          _buildBottomItem(
            icon: Icons.logout_rounded,
            label: 'Salir',
            selected: false,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFFB45CFF)
                  : Colors.white38,
              size: 21,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFB45CFF)
                    : Colors.white38,
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMATO FECHA
  // ============================================================

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      const months = [
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic',
      ];

      return '${parsedDate.day} '
          '${months[parsedDate.month - 1]} '
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // FORMATO HORA
  // ============================================================

  String _formatTime(String time) {
    try {
      final cleanTime = time.trim().toUpperCase();

      if (cleanTime.endsWith('AM') ||
          cleanTime.endsWith('PM')) {
        return cleanTime;
      }

      final parts = cleanTime.split(':');

      if (parts.length < 2) {
        return time;
      }

      int hour = int.parse(parts[0]);

      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }
}

// ============================================================
// MODELO DE ESTADÍSTICA
// ============================================================

class _StatisticData {
  final String title;
  final int value;
  final IconData icon;

  const _StatisticData({
    required this.title,
    required this.value,
    required this.icon,
  });
}