import 'package:flutter/material.dart';
import '../../domain/entities/device.dart';

void showDeviceDetailDialog(BuildContext context, Device device) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _DeviceDetailDialog(device: device),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 1 — Agregar planta  (frame 59-20)
// ─────────────────────────────────────────────────────────────────────────────

class _DeviceDetailDialog extends StatefulWidget {
  final Device device;
  const _DeviceDetailDialog({required this.device});

  @override
  State<_DeviceDetailDialog> createState() => _DeviceDetailDialogState();
}

class _DeviceDetailDialogState extends State<_DeviceDetailDialog> {
  final _nameCtrl = TextEditingController(text: 'Tomate cherry');
  String _slot = 'Slot 3 — libre';

  static const _slots = ['Slot 1 — libre', 'Slot 2 — libre', 'Slot 3 — libre', 'Slot 4 — libre'];

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: mq.size.width > 700 ? (mq.size.width - 564) / 2 : 24,
        vertical: 48,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 564, maxHeight: mq.size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                child: _buildContent(context),
              ),
            ),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Agregar planta', style: tt.headlineMedium?.copyWith(color: const Color(0xFF2D3D2C), fontWeight: FontWeight.w700)),
            _XBtn(onTap: () => Navigator.of(context).pop()),
          ],
        ),
        const SizedBox(height: 10),
        Text('Dale un nombre a tu nueva planta. La foto y la especie las completaremos automáticamente.',
            style: tt.bodySmall?.copyWith(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF31412F))),
        const SizedBox(height: 24),
        _Label('NOMBRE DE LA PLANTA'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(fontSize: 14, color: Color(0xFF3E5C48)),
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            prefixIcon: const Icon(Icons.eco_outlined, size: 16, color: Color(0xFF3E5C48)),
            hintText: 'Tomate cherry',
            hintStyle: const TextStyle(color: Color(0xFF3E5C48), fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF3E5C48), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF3E5C48), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF3E5C48), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
        const SizedBox(height: 4),
        Text('Ejemplo: «Tomate cherry del balcón»', style: tt.bodySmall?.copyWith(fontSize: 11, fontStyle: FontStyle.italic, color: const Color(0xFF556F5D))),
        const SizedBox(height: 16),
        _Label('DISPOSITIVO ASIGNADO'),
        const SizedBox(height: 6),
        _ReadField(icon: Icons.sensors_outlined, value: widget.device.name, suffix: const Icon(Icons.expand_more, size: 16, color: Color(0xFF3E5C48))),
        const SizedBox(height: 16),
        _Label('POSICIÓN EN EL SENSOR'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF556F5D)), borderRadius: BorderRadius.circular(6)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _slot,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, size: 16, color: Color(0xFF3E5C48)),
              style: const TextStyle(fontSize: 14, color: Color(0xFF3E5C48)),
              onChanged: (v) => setState(() => _slot = v ?? _slot),
              items: _slots.map((s) => DropdownMenuItem(value: s, child: Row(children: [
                const Icon(Icons.grid_4x4_outlined, size: 14, color: Color(0xFF3E5C48)),
                const SizedBox(width: 8),
                Text(s),
              ]))).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF5F3EF), borderRadius: BorderRadius.circular(6)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.auto_awesome_outlined, size: 14, color: Color(0xFF556F5D)),
            const SizedBox(width: 10),
            Expanded(child: Text('La foto y los umbrales sugeridos se obtendrán automáticamente al detectar la especie.',
                style: tt.bodySmall?.copyWith(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF556F5D)))),
          ]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => _EditPlantDialog(device: widget.device, plantName: _nameCtrl.text, slot: _slot),
              );
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: Text('Agregar planta', style: tt.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.28)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF556F5D), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF556F5D),
              side: const BorderSide(color: Color(0xFF31412F)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Cancelar', style: tt.bodyMedium?.copyWith(color: const Color(0xFF556F5D), fontWeight: FontWeight.w700, letterSpacing: 0.28)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 2 — Editar planta  (frame 61-21)
// ─────────────────────────────────────────────────────────────────────────────

class _EditPlantDialog extends StatefulWidget {
  final Device device;
  final String plantName;
  final String slot;
  const _EditPlantDialog({required this.device, required this.plantName, required this.slot});

  @override
  State<_EditPlantDialog> createState() => _EditPlantDialogState();
}

class _EditPlantDialogState extends State<_EditPlantDialog> {
  late final TextEditingController _nameCtrl;
  double _minH = 35, _maxH = 75;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.plantName.isEmpty ? 'Tomate cherry del balcón' : widget.plantName);
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: mq.size.width > 700 ? (mq.size.width - 564) / 2 : 24,
        vertical: 48,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 564, maxHeight: mq.size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                child: _buildContent(context),
              ),
            ),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const dark = Color(0xFF2D3D2C);
    const green = Color(0xFF31412F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título + X
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Editar planta', style: tt.headlineMedium?.copyWith(color: dark, fontWeight: FontWeight.w700)),
            _XBtn(onTap: () => Navigator.of(context).pop()),
          ],
        ),
        const SizedBox(height: 16),

        // Foto detectada
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72, height: 80,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.local_florist_outlined, size: 36, color: Color(0xFF556F5D)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FOTO DETECTADA',
                      style: tt.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: green)),
                  const SizedBox(height: 4),
                  Text('Solanum lycopersicum · 92% confianza',
                      style: tt.bodySmall?.copyWith(fontSize: 12, fontStyle: FontStyle.italic, color: dark)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _OutlineSmallBtn(label: 'Reemplazar', icon: Icons.swap_horiz, onPressed: () {}),
                    const SizedBox(width: 8),
                    _OutlineSmallBtn(label: 'Re-detectar', icon: Icons.refresh, onPressed: () {}),
                  ]),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // NOMBRE
        _Label('NOMBRE'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3D2C)),
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            prefixIcon: const Icon(Icons.eco_outlined, size: 16, color: Color(0xFF2D3D2C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF2D3D2C), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF2D3D2C), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF2D3D2C), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
        const SizedBox(height: 16),

        // DISPOSITIVO + SLOT (2 columnas)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('DISPOSITIVO'),
                const SizedBox(height: 6),
                _ReadField(icon: Icons.sensors_outlined, value: widget.device.name),
              ]),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('SLOT'),
                const SizedBox(height: 6),
                _ReadField(icon: Icons.grid_4x4_outlined, value: widget.slot.replaceAll('Slot ', '').split(' ')[0]),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // UMBRALES DE HUMEDAD
        Text('UMBRALES DE HUMEDAD',
            style: tt.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: green)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF5F3EF), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              // Mínima
              _HumiditySlider(
                label: 'Humedad mínima',
                value: _minH,
                color: dark,
                onChanged: (v) { if (v < _maxH) setState(() => _minH = v); },
              ),
              const SizedBox(height: 14),
              // Máxima
              _HumiditySlider(
                label: 'Humedad máxima',
                value: _maxH,
                color: dark,
                onChanged: (v) { if (v > _minH) setState(() => _maxH = v); },
              ),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.info_outline, size: 12, color: Color(0xFF31412F)),
                const SizedBox(width: 6),
                Text('Recomendado para tomates: 40 – 70%.',
                    style: tt.bodySmall?.copyWith(fontSize: 11, fontStyle: FontStyle.italic, color: green)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.save_outlined, size: 16, color: Colors.white),
            label: Text('Guardar cambios', style: tt.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.28)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3D2C), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF31412F)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
          child: Text('Cancelar', style: tt.bodyMedium?.copyWith(color: const Color(0xFF2D3D2C), fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        // Botón eliminar
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (_) => _DeleteConfirmDialog(plantName: _nameCtrl.text),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF2D3D2C)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          ),
          child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF2D3D2C)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 3 — Confirmar eliminación  (frame 61-22)
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  final String plantName;
  const _DeleteConfirmDialog({required this.plantName});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const dark = Color(0xFF2D3D2C);
    const red  = Color(0xFFB04040);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(999)),
                child: const Icon(Icons.delete_forever_outlined, size: 32, color: red),
              ),
              const SizedBox(height: 16),
              Text('¿Eliminar planta?',
                  style: tt.headlineMedium?.copyWith(color: dark, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('«$plantName» será eliminada del dispositivo. Esta acción no se puede deshacer.',
                  style: tt.bodySmall?.copyWith(fontSize: 13, fontStyle: FontStyle.italic, color: const Color(0xFF556F5D)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // Botón eliminar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0,
                  ),
                  child: Text('Sí, eliminar', style: tt.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              // Cancelar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF31412F)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancelar', style: tt.bodyMedium?.copyWith(color: dark, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets compartidos
// ─────────────────────────────────────────────────────────────────────────────

class _XBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _XBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x80B7BCB6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.close, size: 16, color: Colors.black54),
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: const Color(0xFF556F5D), letterSpacing: 0.24),
  );
}

class _ReadField extends StatelessWidget {
  final IconData icon;
  final String value;
  final Widget? suffix;
  const _ReadField({required this.icon, required this.value, this.suffix});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFF556F5D)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF3E5C48)),
      const SizedBox(width: 8),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF3E5C48)))),
      suffix ?? const SizedBox.shrink(),
    ]),
  );
}

class _OutlineSmallBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _OutlineSmallBtn({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 13, color: const Color(0xFF2D3D2C)),
    label: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF2D3D2C), fontWeight: FontWeight.w600, letterSpacing: 0.24)),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFF31412F)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}

class _HumiditySlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;
  const _HumiditySlider({required this.label, required this.value, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: tt.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF31412F))),
            Text('${value.round()}%', style: tt.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: const Color(0x1F31412F),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayColor: Colors.transparent,
            trackHeight: 6,
          ),
          child: Slider(min: 0, max: 100, value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
