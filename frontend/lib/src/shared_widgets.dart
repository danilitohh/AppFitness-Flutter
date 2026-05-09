part of '../main.dart';

// -----------------------------------------------------------------------------
// Widgets visuales reutilizables.
// Componentes pequenos usados por varias pantallas y tarjetas del dashboard.
// -----------------------------------------------------------------------------
/// Tarjeta reutilizable para mostrar una metrica con barra de progreso.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget compacto para visualizar macros del dia.
class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Chip compacto para mostrar preferencias del Coach IA.
class _CoachChip extends StatelessWidget {
  const _CoachChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final maxWidth = math.min(MediaQuery.sizeOf(context).width * 0.72, 260.0);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _appOutline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 14, color: _appPrimaryDark),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linea de recomendacion en los bloques del Coach IA.
class _CoachSuggestionLine extends StatelessWidget {
  const _CoachSuggestionLine({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _appPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _WorkoutPlanSuggestionCard extends StatelessWidget {
  const _WorkoutPlanSuggestionCard({
    required this.suggestion,
    required this.onOpen,
  });

  final _WorkoutPlanSuggestion suggestion;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final template = suggestion.template;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: template.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: template.accent.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: template.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      template.icon,
                      color: template.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      template.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _appText,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: template.accent),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CoachChip(
                    icon: Icons.calendar_today_outlined,
                    label: suggestion.frequencyLabel,
                  ),
                  _CoachChip(
                    icon: Icons.schedule_outlined,
                    label: suggestion.cadenceLabel,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Ejercicios recomendados',
                style: TextStyle(fontWeight: FontWeight.w700, color: _appText),
              ),
              const SizedBox(height: 8),
              ...suggestion.exerciseNames.map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 16,
                        color: template.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          exercise,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _appText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suggestion.executionHint,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black.withValues(alpha: 0.66),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPlanSuggestionCard extends StatelessWidget {
  const _MealPlanSuggestionCard({required this.suggestion});

  final _MealPlanSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _appOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _appPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(suggestion.icon, color: _appPrimaryDark, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.slotLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.58),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _appText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CoachChip(
                icon: Icons.repeat_rounded,
                label: suggestion.frequencyLabel,
              ),
              _CoachChip(
                icon: Icons.schedule_outlined,
                label: suggestion.timingLabel,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ingredientes y cantidades',
            style: TextStyle(fontWeight: FontWeight.w700, color: _appText),
          ),
          const SizedBox(height: 8),
          ...suggestion.ingredients.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.kitchen_outlined,
                    size: 16,
                    color: _appPrimaryDark,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.black.withValues(alpha: 0.72),
                        ),
                        children: [
                          TextSpan(
                            text: '${item.amount} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _appText,
                            ),
                          ),
                          TextSpan(text: item.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suggestion.portionSummary,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper del grafico de peso.
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return const Center(
        child: Text('Registra al menos 2 pesos para ver la tendencia.'),
      );
    }

    return CustomPaint(
      painter: WeightChartPainter(entries),
      child: const SizedBox.expand(),
    );
  }
}

/// Painter custom para dibujar la linea de tendencia de peso.
class WeightChartPainter extends CustomPainter {
  WeightChartPainter(this.entries);

  final List<WeightEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..style = PaintingStyle.fill;

    const left = 22.0;
    const right = 10.0;
    const top = 8.0;
    const bottom = 24.0;

    canvas.drawLine(
      Offset(left, size.height - bottom),
      Offset(size.width - right, size.height - bottom),
      axisPaint,
    );
    canvas.drawLine(
      const Offset(left, top),
      Offset(left, size.height - bottom),
      axisPaint,
    );

    final weights = entries.map((e) => e.weightKg).toList();
    var minWeight = weights.reduce(math.min);
    var maxWeight = weights.reduce(math.max);
    if ((maxWeight - minWeight).abs() < 0.2) {
      minWeight -= 0.2;
      maxWeight += 0.2;
    }

    final availableWidth = size.width - left - right;
    final availableHeight = size.height - top - bottom;
    final count = entries.length;
    final path = Path();

    for (var i = 0; i < count; i++) {
      final x = count == 1 ? left : left + (availableWidth * i / (count - 1));
      final normalized =
          (entries[i].weightKg - minWeight) / (maxWeight - minWeight);
      final y = top + (1 - normalized) * availableHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 3.5, pointPaint);
    }

    canvas.drawPath(path, linePaint);

    final labelStyle = const TextStyle(color: Color(0xFF4B5563), fontSize: 11);
    _drawText(
      canvas,
      '${maxWeight.toStringAsFixed(1)} kg',
      const Offset(0, 0),
      labelStyle,
    );
    _drawText(
      canvas,
      '${minWeight.toStringAsFixed(1)} kg',
      Offset(0, size.height - bottom - 8),
      labelStyle,
    );

    _drawText(
      canvas,
      DateFormat('d MMM').format(entries.first.date),
      Offset(left, size.height - 18),
      labelStyle,
    );

    final endLabel = DateFormat('d MMM').format(entries.last.date);
    final painter = TextPainter(
      text: TextSpan(text: endLabel, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(size.width - painter.width - right, size.height - 18),
    );
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
