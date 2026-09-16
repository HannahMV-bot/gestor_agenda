import 'package:flutter/material.dart';

import 'package:gestor_agenda/core/services/api_service.dart';
import 'package:gestor_agenda/core/services/session_service.dart';

import 'package:gestor_agenda/features/agenda/data/datasources/agenda_remote_data_source.dart';
import 'package:gestor_agenda/features/agenda/data/repositories/agenda_repository_impl.dart';

import 'package:gestor_agenda/features/agenda/domain/entities/task.dart';

class TaskFormPage extends StatefulWidget {
  final Map<String, dynamic>? task;

  const TaskFormPage({
    super.key,
    this.task,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _priority = 'Media';
  String _status = 'Pendiente';

  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final task = widget.task!;

      _titleController.text =
          task['title']?.toString() ?? '';

      _descriptionController.text =
          task['description']?.toString() ?? '';

      _priority =
          task['priority']?.toString() ?? 'Media';

      _status =
          task['status']?.toString() ?? 'Pendiente';

      // ========================================================
      // CARGAR FECHA EXISTENTE
      // ========================================================

      final String dateText =
          task['date']?.toString() ?? '';

      if (dateText.isNotEmpty) {
        try {
          _selectedDate =
              DateTime.parse(dateText);
        } catch (_) {}
      }

      // ========================================================
      // CARGAR HORA EXISTENTE
      // ========================================================

      final String timeText =
          task['time']?.toString() ?? '';

      if (timeText.isNotEmpty) {
        _selectedTime =
            _parseTime(timeText);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // CONVERTIR HORA
  // ============================================================

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.trim().split(' ');

      if (parts.isEmpty) {
        return null;
      }

      final hourMinute =
          parts[0].split(':');

      if (hourMinute.length < 2) {
        return null;
      }

      int hour =
          int.parse(hourMinute[0]);

      final int minute =
          int.parse(hourMinute[1]);

      if (parts.length > 1) {
        final period =
            parts[1].toUpperCase();

        if (period == 'PM' && hour != 12) {
          hour += 12;
        }

        if (period == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // FECHA
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime now =
        DateTime.now();

    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? now,
      firstDate: now,
      lastDate:
          DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme:
                const ColorScheme.dark(
              primary:
                  Color(0xFF8B5CF6),
              surface:
                  Color(0xFF151624),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ============================================================
  // HORA
  // ============================================================

  Future<void> _selectTime() async {
    final TimeOfDay? picked =
        await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ??
              TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme:
                const ColorScheme.dark(
              primary:
                  Color(0xFF8B5CF6),
              surface:
                  Color(0xFF151624),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showMessage(
        'Selecciona una fecha',
      );
      return;
    }

    if (_selectedTime == null) {
      _showMessage(
        'Selecciona una hora',
      );
      return;
    }

    // IMPORTANTE:
    // Se obtiene el formato de hora ANTES del primer await.
    // Esto evita la advertencia use_build_context_synchronously.
    final String formattedTime =
        _selectedTime!.format(context);

    setState(() {
      _isSaving = true;
    });

    try {
      // ========================================================
      // SESIÓN
      // ========================================================

      final sessionService =
          SessionService();

      final String? userId =
          await sessionService.getUserId();

      if (userId == null ||
          userId.isEmpty) {
        throw Exception(
          'No se encontró la sesión del usuario.',
        );
      }

      // ========================================================
      // CREAR OBJETO TASK
      // ========================================================

      final task = Task(
        id: _isEditing
            ? widget.task!['id']
                    ?.toString() ??
                ''
            : '',
        userId: userId,
        title:
            _titleController.text.trim(),
        description:
            _descriptionController.text
                .trim(),
        date: _formatDateForApi(
          _selectedDate!,
        ),
        time: formattedTime,
        status: _status,
        priority: _priority,
      );

      // ========================================================
      // API
      // ========================================================

      final apiService =
          ApiService();

      final remoteDataSource =
          AgendaRemoteDataSource(
        apiService: apiService,
      );

      final repository =
          AgendaRepositoryImpl(
        remoteDataSource:
            remoteDataSource,
      );

      // ========================================================
      // CREAR TAREA
      // ========================================================

      if (!_isEditing) {
        await repository.createTask(
          task,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isSaving = false;
        });

        _showMessage(
          'Tarea creada correctamente',
        );

        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );

        if (!mounted) {
          return;
        }

        Navigator.pop(
          context,
          {
            'saved': true,
          },
        );

        return;
      }

      // ========================================================
      // EDITAR TAREA
      // ========================================================

      await repository.updateTask(
        task,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Tarea actualizada correctamente',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        {
          'saved': true,
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'No se pudo guardar la tarea: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // MENSAJE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            const Color(0xFF25263A),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FECHA PARA API
  // ============================================================

  String _formatDateForApi(
    DateTime date,
  ) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // FECHA PARA MOSTRAR
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _dateText() {
    if (_selectedDate == null) {
      return 'Seleccionar fecha';
    }

    return _formatDate(
      _selectedDate!,
    );
  }

  String _timeText() {
    if (_selectedTime == null) {
      return 'Seleccionar hora';
    }

    return _selectedTime!.format(
      context,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF090A13),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0B0C16),
        elevation: 0,
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(
          _isEditing
              ? 'Editar tarea'
              : 'Nueva tarea',
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) {
            final bool isDesktop =
                constraints.maxWidth >=
                    850;

            return Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(
                  maxWidth:
                      isDesktop
                          ? 850
                          : 600,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal:
                        isDesktop
                            ? 35
                            : 20,
                    vertical: 14,
                  ),
                  child: _buildForm(
                    isDesktop,
                    constraints
                        .maxHeight,
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
  // FORMULARIO
  // ============================================================

  Widget _buildForm(
    bool isDesktop,
    double availableHeight,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(
            height: 15,
          ),

          if (isDesktop)
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      _buildTitleField(),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child:
                      _buildPriorityField(),
                ),
              ],
            )
          else
            _buildTitleField(),

          if (!isDesktop)
            const SizedBox(
              height: 12,
            ),

          if (!isDesktop)
            _buildPriorityField(),

          const SizedBox(
            height: 12,
          ),

          _buildDescriptionField(),

          const SizedBox(
            height: 12,
          ),

          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child:
                      _buildDateField(),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child:
                      _buildTimeField(),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildDateField(),
                const SizedBox(
                  height: 12,
                ),
                _buildTimeField(),
              ],
            ),

          const SizedBox(
            height: 12,
          ),

          _buildStatusField(),

          const SizedBox(
            height: 15,
          ),

          _buildSaveButton(),
        ],
      ),
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            gradient:
                const LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF6D28D9),
              ],
            ),
          ),
          child: const Icon(
            Icons.task_alt_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),

        const SizedBox(
          width: 14,
        ),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Organiza una nueva actividad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                'Completa la información de tu tarea.',
                style: TextStyle(
                  color:
                      Color(0xFF85889D),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  Widget _buildTitleField() {
    return _buildTextField(
      controller:
          _titleController,
      label: 'Título',
      hint:
          'Ej. Estudiar Flutter',
      icon:
          Icons.title_rounded,
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Ingresa un título';
        }

        return null;
      },
    );
  }

  // ============================================================
  // DESCRIPCIÓN
  // ============================================================

  Widget _buildDescriptionField() {
    return _buildTextField(
      controller:
          _descriptionController,
      label: 'Descripción',
      hint:
          'Describe brevemente la tarea...',
      icon:
          Icons.notes_rounded,
      maxLines: 2,
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Ingresa una descripción';
        }

        return null;
      },
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)?
        validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
          ),
          decoration:
              InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(
              color:
                  Color(0xFF66697D),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color:
                  const Color(
                      0xFF8B5CF6),
              size: 19,
            ),
            filled: true,
            fillColor:
                const Color(
                    0xFF151624),
            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF292B40),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF292B40),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF8B5CF6),
                width: 1.5,
              ),
            ),
            errorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFFF87171),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRIORIDAD
  // ============================================================

  Widget _buildPriorityField() {
    return _buildDropdownField(
      label: 'Prioridad',
      icon:
          Icons.flag_rounded,
      value: _priority,
      items: const [
        'Alta',
        'Media',
        'Baja',
      ],
      onChanged: (value) {
        setState(() {
          _priority = value;
        });
      },
    );
  }

  // ============================================================
  // ESTADO
  // ============================================================

  Widget _buildStatusField() {
    return _buildDropdownField(
      label: 'Estado',
      icon:
          Icons.check_circle_outline_rounded,
      value: _status,
      items: const [
        'Pendiente',
        'Completada',
      ],
      onChanged: (value) {
        setState(() {
          _status = value;
        });
      },
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String)
        onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        PopupMenuButton<String>(
          initialValue: value,
          color:
              const Color(0xFF151624),
          elevation: 12,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            side:
                const BorderSide(
              color:
                  Color(0xFF292B40),
            ),
          ),
          onSelected: onChanged,
          itemBuilder:
              (context) {
            return items.map(
              (item) {
                return PopupMenuItem<
                    String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color:
                            const Color(
                                0xFF8B5CF6),
                        size: 19,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        item,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList();
          },
          child: Container(
            height: 50,
            width:
                double.infinity,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                      0xFF151624),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                        0xFF292B40),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      const Color(
                          0xFF8B5CF6),
                  size: 20,
                ),

                const SizedBox(
                  width: 11,
                ),

                Expanded(
                  child: Text(
                    value,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 13.5,
                    ),
                  ),
                ),

                const Icon(
                  Icons
                      .keyboard_arrow_down_rounded,
                  color:
                      Color(0xFF85889D),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FECHA
  // ============================================================

  Widget _buildDateField() {
    return _buildPickerField(
      label: 'Fecha',
      icon:
          Icons.calendar_today_rounded,
      text: _dateText(),
      onTap: _selectDate,
    );
  }

  // ============================================================
  // HORA
  // ============================================================

  Widget _buildTimeField() {
    return _buildPickerField(
      label: 'Hora',
      icon:
          Icons.access_time_rounded,
      text: _timeText(),
      onTap: _selectTime,
    );
  }

  // ============================================================
  // SELECTOR FECHA / HORA
  // ============================================================

  Widget _buildPickerField({
    required String label,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final bool selected =
        !text.startsWith(
      'Seleccionar',
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          child: Container(
            height: 50,
            width:
                double.infinity,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                      0xFF151624),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                        0xFF292B40),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      const Color(
                          0xFF8B5CF6),
                  size: 20,
                ),

                const SizedBox(
                  width: 11,
                ),

                Expanded(
                  child: Text(
                    text,
                    style:
                        TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFF66697D),
                      fontSize: 13,
                    ),
                  ),
                ),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color:
                      Color(0xFF66697D),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTÓN
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width:
          double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration:
            BoxDecoration(
          gradient:
              const LinearGradient(
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF6D28D9),
            ],
          ),
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(
                0xFF8B5CF6,
              ).withValues(
                alpha: 0.22,
              ),
              blurRadius: 16,
              offset:
                  const Offset(
                0,
                7,
              ),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
              _isSaving
                  ? null
                  : _saveTask,
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.transparent,
            disabledBackgroundColor:
                Colors.transparent,
            shadowColor:
                Colors.transparent,
            foregroundColor:
                Colors.white,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color:
                        Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Icon(
                      _isEditing
                          ? Icons
                              .save_rounded
                          : Icons
                              .add_task_rounded,
                      size: 19,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      _isEditing
                          ? 'Guardar cambios'
                          : 'Crear tarea',
                      style:
                          const TextStyle(
                        fontSize: 14.5,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}