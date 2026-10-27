import 'package:flutter/material.dart';

/// Foto de la planta, con icono de respaldo.
///
/// La URL viene del backend (Wikipedia). Puede faltar o fallar la descarga, y
/// en la demo puede no haber red: en cualquiera de esos casos se muestra el
/// icono en lugar de un hueco roto.
class PlantPhoto extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;

  const PlantPhoto({
    super.key,
    required this.imageUrl,
    this.size = 56,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = imageUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url.isEmpty
            ? _Placeholder(size: size)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Placeholder(size: size),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: cs.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: size * 0.3,
                      height: size * 0.3,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double size;

  const _Placeholder({required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.primary.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Icon(
        Icons.local_florist_rounded,
        size: size * 0.5,
        color: cs.primary.withValues(alpha: 0.7),
      ),
    );
  }
}
