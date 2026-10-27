import 'package:flutter/material.dart';

import '../screens/assistant_screen.dart';
import 'kawaii_cactus.dart';

/// Burbuja flotante del asistente, siempre visible sobre la app.
///
/// Abre el chat en un panel, no cambia de pestana: asi el usuario puede
/// preguntar sin perder la pantalla donde estaba.
class AssistantBubble extends StatelessWidget {
  const AssistantBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Abrir asistente de plantas',
      child: Material(
        color: cs.surface,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => openAssistantPanel(context),
          child: Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const KawaiiCactus(size: 40),
          ),
        ),
      ),
    );
  }
}

/// Abre el chat: hoja inferior en pantallas angostas, dialogo en anchas.
Future<void> openAssistantPanel(BuildContext context) {
  final isWide = MediaQuery.sizeOf(context).width >= 760;

  if (isWide) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 32,
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
          child: const AssistantScreen(embedded: true),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.92,
      child: const AssistantScreen(embedded: true),
    ),
  );
}
