import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';

/// Pantalla Historial — frame 63-25.
/// Tabla de riegos con 8 columnas.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Mock data inline — estructura = history.json
  static const _records = [
    _IrrigRecord('09 May · 06:30', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 07:15', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 08:00', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 09:45', 'Sector A', 'Tomate', false, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 11:30', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 13:00', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 14:30', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 16:00', 'Sector A', 'Tomate', false, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 17:45', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
    _IrrigRecord('09 May · 19:00', 'Sector A', 'Tomate', true, 8, 1.4, 38, 62),
  ];

  static const _headers = [
    'Fecha y hora',
    'Dispositivo',
    'Cultivo',
    'Tipo',
    'Duración',
    'Litros',
    'Humedad antes',
    'Humedad después',
  ];

  @override
  Widget build(BuildContext context) {
    final tt = AppTextStyles.of(context);
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 800;
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : 'Usuario';
    final avatarUrl = authState is AuthAuthenticated
        ? authState.user.avatarUrl
        : null;

    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────────────────
        Container(
          height: isWide ? 80 : 60,
          padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial',
                style: tt.displayMedium?.copyWith(
                  color: const Color(0xFF2D3D2C),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: cs.onSurface,
                      size: isWide ? 28 : 22,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  UserAvatar(
                    name: userName,
                    avatarUrl: avatarUrl,
                    radius: isWide ? 24 : 18,
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Body ─────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isWide ? AppDimensions.spaceLg : AppDimensions.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de riegos',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                _IrrigTable(records: _records, headers: _headers),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _IrrigRecord {
  final String datetime, device, crop;
  final bool isAuto;
  final int durationMin, humBefore, humAfter;
  final double liters;

  const _IrrigRecord(
    this.datetime,
    this.device,
    this.crop,
    this.isAuto,
    this.durationMin,
    this.liters,
    this.humBefore,
    this.humAfter,
  );
}

// ── Anchos fijos por columna — garantizan alineación header/filas ─────────────

const _colWidths = [150.0, 110.0, 100.0, 90.0, 90.0, 80.0, 120.0, 130.0];
const _colPad = EdgeInsets.symmetric(horizontal: 14, vertical: 12);

// ── Table ─────────────────────────────────────────────────────────────────────

class _IrrigTable extends StatelessWidget {
  final List<_IrrigRecord> records;
  final List<String> headers;

  const _IrrigTable({required this.records, required this.headers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              color: const Color(0xFFF5F3EF),
              child: Row(
                children: [
                  for (int i = 0; i < headers.length; i++)
                    _HeaderCell(text: headers[i], width: _colWidths[i]),
                ],
              ),
            ),
            // ── Rows ────────────────────────────────────────────────
            ...records.map(
              (r) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: const Color(0xFF31412F).withValues(alpha: 0.2),
                  ),
                  Row(
                    children: [
                      _Cell(r.datetime, _colWidths[0]),
                      _Cell(r.device, _colWidths[1]),
                      _Cell(r.crop, _colWidths[2]),
                      _BadgeCell(isAuto: r.isAuto, width: _colWidths[3]),
                      _Cell('${r.durationMin} min', _colWidths[4]),
                      _Cell('${r.liters} L', _colWidths[5]),
                      _Cell('${r.humBefore}%', _colWidths[6]),
                      _Cell('${r.humAfter}%', _colWidths[7]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;
  const _HeaderCell({required this.text, required this.width});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Padding(
      padding: _colPad,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    ),
  );
}

class _Cell extends StatelessWidget {
  final String text;
  final double width;
  const _Cell(this.text, this.width);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Padding(
      padding: _colPad,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontSize: 13, color: Colors.black),
      ),
    ),
  );
}

class _BadgeCell extends StatelessWidget {
  final bool isAuto;
  final double width;
  const _BadgeCell({required this.isAuto, required this.width});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: Padding(
        padding: _colPad,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAuto
                ? const Color(0xFF599974).withValues(alpha: 0.15)
                : const Color(0xFFF5F3EF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isAuto ? 'Auto' : 'Manual',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAuto ? const Color(0xFF2D5C3A) : const Color(0xFF5C5C5C),
            ),
          ),
        ),
      ),
    );
  }
}
