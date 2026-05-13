import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de Análisis — frame 62-24.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // ── Mock data (estructura = analytics.json) ──────────────────────────────
  static const _stableLiters = 980;
  static const _coveredDays = 9.8;

  static const _dailyData = [
    68,
    72,
    65,
    88,
    71,
    60,
    78,
    70,
    54,
    66,
    84,
    72,
    68,
    90,
  ];
  static const _dailyLabels = [
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '39',
  ];

  static const _cumulativeUse = [
    10.0,
    25.0,
    45.0,
    70.0,
    100.0,
    140.0,
    190.0,
    250.0,
    320.0,
    400.0,
    490.0,
    590.0,
    700.0,
    820.0,
    980.0,
  ];

  static const _crops = [
    ('Tomate', 580, Color(0xFF12480E)),
    ('Lechuga', 420, Color(0xFF599974)),
    ('Pimiento', 400, Color(0xFF7AB28E)),
    ('Albahaca', 250, Color(0xFFE6DACA)),
    ('Espinaca', 230, Color(0xFFA8C9B5)),
    ('Otros', 230, Color(0xFFD4C9B8)),
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
        // ── Top bar ──────────────────────────────────────────────────────
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
                'Análisis',
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

        // ── Body ─────────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isWide ? AppDimensions.spaceLg : AppDimensions.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI cards
                _KpiRow(),
                const SizedBox(height: AppDimensions.spaceMd),

                // Gráfico de barras + consumo acumulado
                LayoutBuilder(
                  builder: (_, c) {
                    final wide = c.maxWidth >= 700;
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 14, child: _BarChartCard()),
                          const SizedBox(width: AppDimensions.spaceMd),
                          Expanded(flex: 10, child: _LineChartCard()),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _BarChartCard(),
                        const SizedBox(height: AppDimensions.spaceMd),
                        _LineChartCard(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                // Consumo por cultivo
                _CropCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── KPI Row ───────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  static const _kpis = [
    ('Consumo total', '2 130 L'),
    ('Promedio diario', '71 L'),
    ('Eficiencia de riego', '32%'),
    ('Eventos de riego', '184'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final wide = c.maxWidth >= 600;
        final cards = _kpis
            .map((k) => _KpiCard(label: k.$1, value: k.$2))
            .toList();
        if (wide) {
          return Row(
            children:
                cards
                    .expand(
                      (w) => [
                        Expanded(child: w),
                        const SizedBox(width: AppDimensions.spaceMd),
                      ],
                    )
                    .toList()
                  ..removeLast(),
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  const _KpiCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.bodySmall?.copyWith(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bar Chart ─────────────────────────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  static const _data = AnalyticsScreen._dailyData;
  static const _labels = AnalyticsScreen._dailyLabels;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final maxVal = _data.reduce((a, b) => a > b ? a : b).toDouble();
    final currentIdx = _data.length - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consumo por día',
            style: tt.headlineMedium?.copyWith(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_data.length, (i) {
                final pct = _data[i] / maxVal;
                final isNow = i == currentIdx;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: pct,
                            child: Container(
                              width: 22,
                              decoration: BoxDecoration(
                                color: isNow
                                    ? const Color(0xFF12480E)
                                    : const Color(0xFF599974),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _labels[i],
                        style: tt.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Line Chart (consumo acumulado) ────────────────────────────────────────────

class _LineChartCard extends StatelessWidget {
  static const _data = AnalyticsScreen._cumulativeUse;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consumo acumulado',
            style: tt.headlineMedium?.copyWith(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _LinePainter(data: List<double>.from(_data)),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF599974).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'El sistema registró ${AnalyticsScreen._stableLiters.toInt()} L este mes, equivalente a ${AnalyticsScreen._coveredDays} días de riego.',
              style: tt.bodySmall?.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF2D3D2C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data;
  _LinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.last;
    final pts = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - (data[i] / maxVal) * size.height;
      return Offset(x, y);
    });

    // Área bajo la curva
    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(pts.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = const Color(0xFF599974).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );

    // Línea
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF2D3D2C)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Puntos
    final dotPaint = Paint()
      ..color = const Color(0xFF2D3D2C)
      ..style = PaintingStyle.fill;
    for (final p in pts) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(
        p,
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
    }

    // Líneas de referencia horizontales
    final refPaint = Paint()
      ..color = const Color(0xFF31412F).withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), refPaint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.data != data;
}

// ── Crop bars ─────────────────────────────────────────────────────────────────

class _CropCard extends StatelessWidget {
  static const _crops = AnalyticsScreen._crops;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final maxVal = _crops.map((c) => c.$2).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consumo por cultivo',
          style: tt.headlineMedium?.copyWith(fontSize: 20, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _crops.map((c) {
              final (name, val, color) = c;
              final pct = val / maxVal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${val}l',
                          style: tt.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (_, c) => Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF31412F,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
