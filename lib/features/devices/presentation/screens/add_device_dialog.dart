import 'dart:async';
import 'package:flutter/material.dart';

void showAddDeviceDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const _WizardDialog(),
  );
}

class _WizardDialog extends StatefulWidget {
  const _WizardDialog();
  @override
  State<_WizardDialog> createState() => _WizardDialogState();
}

class _WizardDialogState extends State<_WizardDialog> {
  int _step = 1;
  static const int _total = 7;

  String _ssid = '', _password = '', _name = '', _location = '', _crop = '';
  double _minHumidity = 35, _maxHumidity = 75;

  void _next() => scheduleMicrotask(() {
        if (!mounted) return;
        if (_step < _total) {
          setState(() => _step++);
        } else {
          Navigator.of(context).pop();
        }
      });

  void _back() => scheduleMicrotask(() {
        if (!mounted) return;
        if (_step > 1) {
          setState(() => _step--);
        } else {
          Navigator.of(context).pop();
        }
      });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 40,
        vertical: mq.size.height * 0.06,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: mq.size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperBar(total: _total, current: _step),
            Flexible(
              child: SingleChildScrollView(child: _buildContent()),
            ),
            _BottomButtons(
              onBack: _back,
              onNext: _step == 7 ? () {
                // En paso 7 "Agregar Otro" reinicia el wizard
                setState(() {
                  _step = 1;
                  _ssid = ''; _password = '';
                  _name = ''; _location = ''; _crop = '';
                  _minHumidity = 35; _maxHumidity = 75;
                });
              } : _next,
              nextLabel: _step == 7 ? 'Agregar Otro' : 'Continuar',
            ),
          ],
        ),
      ),
    );
  }

  // Solo el contenido del paso, sin botones
  Widget _buildContent() {
    switch (_step) {
      case 1: return _Step1();
      case 2: return _Step2(
        ssid: _ssid, password: _password,
        onSsid: (v) => setState(() => _ssid = v),
        onPassword: (v) => setState(() => _password = v),
      );
      case 3: return _Step3();
      case 4: return _Step4(
        name: _name, location: _location, crop: _crop,
        onName:     (v) => setState(() => _name = v),
        onLocation: (v) => setState(() => _location = v),
        onCrop:     (v) => setState(() => _crop = v),
      );
      case 5: return _Step5(
        minHumidity: _minHumidity,
        maxHumidity: _maxHumidity,
        onMinChanged: (v) => setState(() => _minHumidity = v),
        onMaxChanged: (v) => setState(() => _maxHumidity = v),
      );
      case 6: return const _Step6();
      case 7: return _Step7(
        name: _name,
        location: _location,
        crop: _crop,
        minHumidity: _minHumidity,
        maxHumidity: _maxHumidity,
      );
      default: return _StepPlaceholderContent(step: _step);
    }
  }
}

// ── Stepper ───────────────────────────────────────────────────────────────────

class _StepperBar extends StatelessWidget {
  final int total, current;
  const _StepperBar({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    const active  = Color(0xFF12480E);
    const passive = Color(0x6031412F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF94BC9A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: List.generate(total * 2 - 1, (i) {
          if (i.isOdd) {
            final right = i ~/ 2 + 2;
            return Expanded(child: Container(height: 2, color: right <= current ? active : passive));
          }
          final step = i ~/ 2 + 1;
          final done = step < current;
          final cur  = step == current;
          return Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (done || cur) ? active : Colors.white,
              border: Border.all(color: (done || cur) ? active : passive),
            ),
            child: done ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
          );
        }),
      ),
    );
  }
}

// ── Shell: solo header + contenido ───────────────────────────────────────────

class _Shell extends StatelessWidget {
  final String label, title;
  final String? subtitle;
  final Widget body;

  const _Shell({
    required this.label,
    required this.title,
    this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      color: const Color(0xFF94BC9A),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: tt.bodySmall?.copyWith(color: Colors.black87, fontSize: 12)),
          const SizedBox(height: 4),
          Text(title, style: tt.headlineMedium?.copyWith(color: const Color(0xFF2D3D2C))),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: tt.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: const Color(0xFF2D3D2C))),
          ],
          const SizedBox(height: 16),
          body,
        ],
      ),
    );
  }
}

// ── Botones fijos en la parte inferior ───────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  final VoidCallback onNext, onBack;
  final String nextLabel;
  const _BottomButtons({required this.onNext, required this.onBack, this.nextLabel = 'Continuar'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF94BC9A),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Color(0x6031412F), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onBack,
                child: const Text('Atrás', style: TextStyle(color: Colors.black87)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF44594E),
                ),
                child: Text(nextLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Paso 1 ────────────────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1();

  @override
  Widget build(BuildContext context) {
    return _Shell(
      label: 'Paso 1 de 7',
      title: 'Conecta tu ESP32 a AquaSave',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ESP32 illustration
          Container(
            width: 180, height: 140,
            decoration: BoxDecoration(color: const Color(0xFFFFFBF5), borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Container(
                width: 110, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 6))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    _Dot(on: true), const SizedBox(width: 4),
                    _Dot(on: false), const SizedBox(width: 4),
                    _Dot(on: false),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Antes de continuar:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF2D3D2C))),
                const SizedBox(height: 10),
                _Check(icon: Icons.light_mode_outlined,          text: 'El ESP32 está encendido (LED azul fijo).'),
                const SizedBox(height: 6),
                _Check(icon: Icons.wifi,                          text: 'Estás cerca del router WiFi.'),
                const SizedBox(height: 6),
                _Check(icon: Icons.broadcast_on_personal_outlined, text: 'Tu computadora está en la misma red.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool on;
  const _Dot({required this.on});
  @override
  Widget build(BuildContext context) => Container(
    width: 6, height: 6,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: on ? const Color(0xFF599974) : const Color(0xFF444444),
      boxShadow: on ? const [BoxShadow(color: Color(0xFF599974), blurRadius: 6)] : null,
    ),
  );
}

class _Check extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Check({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFF5F3EF), borderRadius: BorderRadius.circular(6)),
    child: Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF2D3D2C)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, color: Colors.black))),
    ]),
  );
}

// ── Paso 2 ────────────────────────────────────────────────────────────────────

class _Step2 extends StatefulWidget {
  final String ssid, password;
  final ValueChanged<String> onSsid, onPassword;
  const _Step2({required this.ssid, required this.password, required this.onSsid, required this.onPassword});
  @override State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  late final TextEditingController _pw;
  bool _obs = true;

  static const _nets = [('CASA_VERA_5G', 4), ('CASA_VERA_2.4', 4), ('VECINO_2.4', 2)];

  @override void initState() { super.initState(); _pw = TextEditingController(text: widget.password); }
  @override void dispose()   { _pw.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return _Shell(
      label: 'Paso 2 de 7', title: 'Conectar a WiFi',
      subtitle: 'Selecciona la red. Recomendamos 2.4 GHz.',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Column(
                children: _nets.map((n) {
                  final (name, bars) = n;
                  final sel = name == widget.ssid;
                  return Material(
                    color: sel ? const Color(0xFFC7DEC3) : Colors.white,
                    child: InkWell(
                      onTap: () => widget.onSsid(name),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(children: [
                          const Icon(Icons.wifi, size: 16, color: Color(0xFF2D3D2C)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(name, style: tt.bodySmall?.copyWith(fontSize: 12, color: Colors.black))),
                          ...List.generate(4, (i) => Container(
                            width: 3, height: 4.0 + i * 3, margin: const EdgeInsets.only(left: 2),
                            color: i < bars ? const Color(0xFF286241) : const Color(0x33000000),
                          )),
                          if (sel) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check, size: 13, color: Color(0xFF286241))),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RED SELECCIONADA', style: tt.bodySmall?.copyWith(fontSize: 10, color: Colors.black)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF5F3EF), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF94BC9A))),
                  child: Row(children: [
                    const Icon(Icons.wifi, size: 13),
                    const SizedBox(width: 6),
                    Expanded(child: Text(widget.ssid.isEmpty ? '—' : widget.ssid, style: tt.bodySmall?.copyWith(fontSize: 11, color: Colors.black))),
                  ]),
                ),
                const SizedBox(height: 10),
                Text('CONTRASEÑA', style: tt.bodySmall?.copyWith(fontSize: 10, color: Colors.black)),
                const SizedBox(height: 4),
                TextField(
                  controller: _pw,
                  obscureText: _obs,
                  onChanged: widget.onPassword,
                  style: tt.bodySmall?.copyWith(fontSize: 12, color: Colors.black),
                  decoration: InputDecoration(
                    filled: true, fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline, size: 14),
                    suffixIcon: IconButton(icon: Icon(_obs ? Icons.visibility_off : Icons.visibility, size: 14), onPressed: () => setState(() => _obs = !_obs)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Paso 3 ────────────────────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  const _Step3();

  static const _checks = ['Conexión WiFi', 'Asignación IP', 'Servidor AquaSave', 'Sincronización inicial'];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return _Shell(
      label: 'Paso 3 de 7', title: 'Verificación',
      subtitle: 'Comprobando la conexión del ESP32.',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0x4031412F))),
              child: Column(children: [
                Container(width: 60, height: 60, decoration: const BoxDecoration(color: Color(0xFF12480E), shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 30)),
                const SizedBox(height: 10),
                Text('Dispositivo conectado', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF2D3D2C))),
                const SizedBox(height: 4),
                Text('AquaSave-D7E1 en línea.', style: tt.bodySmall?.copyWith(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54), textAlign: TextAlign.center),
              ]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: _checks.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.7)), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c, style: tt.bodySmall?.copyWith(fontSize: 12, color: Colors.black)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(999)),
                      child: Text('OK', style: tt.bodySmall?.copyWith(fontSize: 10, color: Colors.black)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Paso 4 ────────────────────────────────────────────────────────────────────

class _Step4 extends StatefulWidget {
  final String name, location, crop;
  final ValueChanged<String> onName, onLocation, onCrop;
  const _Step4({required this.name, required this.location, required this.crop, required this.onName, required this.onLocation, required this.onCrop});
  @override State<_Step4> createState() => _Step4State();
}

class _Step4State extends State<_Step4> {
  late final TextEditingController _nc, _lc;
  static const _crops = ['Hortalizas mixtas', 'Hierbas aromáticas', 'Suculentas / cactus', 'Vegetales de hoja'];

  @override void initState() { super.initState(); _nc = TextEditingController(text: widget.name); _lc = TextEditingController(text: widget.location); }
  @override void dispose()   { _nc.dispose(); _lc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return _Shell(
      label: 'Paso 4 de 7', title: 'Configuración básica',
      subtitle: 'Nombre del dispositivo y tipo de cultivo.',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TF(label: 'NOMBRE', ctrl: _nc, icon: Icons.devices_outlined, onChanged: widget.onName),
                const SizedBox(height: 10),
                _TF(label: 'UBICACIÓN', ctrl: _lc, icon: Icons.location_on_outlined, onChanged: widget.onLocation),
                const SizedBox(height: 10),
                Text('ZONA HORARIA', style: tt.bodySmall?.copyWith(fontSize: 10, color: Colors.black)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [
                    const Icon(Icons.access_time_outlined, size: 13, color: Color(0xFF2D3D2C)),
                    const SizedBox(width: 6),
                    Text('América/Lima (UTC-5)', style: tt.bodySmall?.copyWith(fontSize: 11, color: Colors.black)),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TIPO DE CULTIVO', style: tt.bodySmall?.copyWith(fontSize: 10, color: Colors.black)),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: _Radio(label: _crops[0], sel: widget.crop == _crops[0], onTap: () => widget.onCrop(_crops[0]))),
                  const SizedBox(width: 6),
                  Expanded(child: _Radio(label: _crops[1], sel: widget.crop == _crops[1], onTap: () => widget.onCrop(_crops[1]))),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: _Radio(label: _crops[2], sel: widget.crop == _crops[2], onTap: () => widget.onCrop(_crops[2]))),
                  const SizedBox(width: 6),
                  Expanded(child: _Radio(label: _crops[3], sel: widget.crop == _crops[3], onTap: () => widget.onCrop(_crops[3]))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TF extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const _TF({required this.label, required this.ctrl, required this.icon, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: tt.bodySmall?.copyWith(fontSize: 10, color: Colors.black)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl, onChanged: onChanged,
        style: tt.bodySmall?.copyWith(fontSize: 12, color: Colors.black),
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white,
          prefixIcon: Icon(icon, size: 14, color: const Color(0xFF2D3D2C)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    ]);
  }
}

class _Radio extends StatelessWidget {
  final String label;
  final bool sel;
  final VoidCallback onTap;
  const _Radio({required this.label, required this.sel, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFFFFF2DD) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: sel ? Border.all(color: const Color(0xFF12480E)) : null,
          ),
          child: Row(children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: sel ? const Color(0xFF12480E) : const Color(0xFF31412F))),
              child: sel ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF12480E)))) : null,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.black), overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ),
    );
  }
}

// ── Paso 5: Umbrales de humedad ───────────────────────────────────────────────

class _Step5 extends StatefulWidget {
  final double minHumidity, maxHumidity;
  final ValueChanged<double> onMinChanged, onMaxChanged;
  const _Step5({
    required this.minHumidity, required this.maxHumidity,
    required this.onMinChanged, required this.onMaxChanged,
  });
  @override State<_Step5> createState() => _Step5State();
}

class _Step5State extends State<_Step5> {
  late double _min, _max;

  static const _presets = [
    ('Hortalizas (mixto)',  35.0, 75.0),
    ('Hierbas aromáticas',  35.0, 75.0),
    ('Suculentas / cactus', 20.0, 50.0),
    ('Vegetales de hoja',   50.0, 80.0),
  ];

  @override
  void initState() {
    super.initState();
    _min = widget.minHumidity;
    _max = widget.maxHumidity;
  }

  void _applyPreset(double min, double max) {
    setState(() { _min = min; _max = max; });
    widget.onMinChanged(min);
    widget.onMaxChanged(max);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const trackColor  = Color(0xFF44594E);
    const trackBg     = Color(0x1F31412F);

    final sliders = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicadores visuales mín/máx
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: trackBg,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // Rango activo
            LayoutBuilder(builder: (_, c) {
              final w = c.maxWidth;
              final left  = w * (_min / 100);
              final right = w * (1 - _max / 100);
              return Positioned(
                left: left, right: right, top: 0, bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ],
        ),
        // Etiquetas 0% 25% 50% 75% 100%
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['0%', '25%', '50%', '75%', '100%']
                .map((l) => Text(l, style: tt.bodySmall?.copyWith(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.black)))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Text('Humedad mínima — alertar y regar',
            style: tt.bodySmall?.copyWith(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF2D3D2C))),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: trackColor,
            inactiveTrackColor: trackBg,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayColor: Colors.transparent,
            trackHeight: 6,
          ),
          child: Slider(
            min: 0, max: 100, value: _min,
            onChanged: (v) {
              if (v >= _max) return;
              setState(() => _min = v);
              widget.onMinChanged(v);
            },
          ),
        ),
        Text('Humedad máxima — detener riego',
            style: tt.bodySmall?.copyWith(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF2D3D2C))),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: trackColor,
            inactiveTrackColor: trackBg,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayColor: Colors.transparent,
            trackHeight: 6,
          ),
          child: Slider(
            min: 0, max: 100, value: _max,
            onChanged: (v) {
              if (v <= _min) return;
              setState(() => _max = v);
              widget.onMaxChanged(v);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3EF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Sugerimos ${_min.round()}–${_max.round()}% para hortalizas mixtas.  Usar valores sugeridos',
            style: tt.bodySmall?.copyWith(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black),
          ),
        ),
      ],
    );

    final presets = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3EF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Presets por cultivo',
              style: tt.bodySmall?.copyWith(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black)),
          const SizedBox(height: 6),
          ..._presets.map((p) {
            final (name, min, max) = p;
            final selected = _min == min && _max == max;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _applyPreset(min, max),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: selected ? Border.all(color: const Color(0xFF94BC9A)) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: tt.bodySmall?.copyWith(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black)),
                      Text('${min.round()} – ${max.round()}%', style: tt.bodySmall?.copyWith(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );

    return _Shell(
      label: 'Paso 5 de 7',
      title: 'Umbrales de humedad',
      subtitle: 'Define el rango óptimo. AquaSave alertará y regará dentro de este rango.',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: sliders),
          const SizedBox(width: 16),
          SizedBox(width: 220, child: presets),
        ],
      ),
    );
  }
}

// ── Paso 6: Prueba de sensores ────────────────────────────────────────────────

class _Step6 extends StatelessWidget {
  const _Step6();

  static const _sensors = [
    (Icons.water_drop_outlined,  'Humedad de suelo',  '62%',      Color(0xFFADD8E6)),
    (Icons.thermostat_outlined,  'Temperatura',        '24.3°C',   Color(0xFFFFB347)),
    (Icons.light_mode_outlined,  'Luminosidad',        '48 200lx', Color(0xFFFFD700)),
    (Icons.water,                'Humedad ambiental', '58%',      Color(0xFF90EE90)),
  ];

  @override
  Widget build(BuildContext context) {
    return _Shell(
      label: 'Paso 6 de 7',
      title: 'Prueba de sensores',
      subtitle: 'Vamos a leer los sensores conectados al ESP32 para verificar que funcionan.',
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SensorCard(
                icon: _sensors[0].$1,
                label: _sensors[0].$2,
                value: _sensors[0].$3,
              )),
              const SizedBox(width: 12),
              Expanded(child: _SensorCard(
                icon: _sensors[1].$1,
                label: _sensors[1].$2,
                value: _sensors[1].$3,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SensorCard(
                icon: _sensors[2].$1,
                label: _sensors[2].$2,
                value: _sensors[2].$3,
              )),
              const SizedBox(width: 12),
              Expanded(child: _SensorCard(
                icon: _sensors[3].$1,
                label: _sensors[3].$2,
                value: _sensors[3].$3,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SensorCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF44594E)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: tt.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
              const SizedBox(height: 2),
              Text(value, style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Paso 7: ¡Todo listo! ─────────────────────────────────────────────────────

class _Step7 extends StatelessWidget {
  final String name, location, crop;
  final double minHumidity, maxHumidity;

  const _Step7({
    required this.name,
    required this.location,
    required this.crop,
    required this.minHumidity,
    required this.maxHumidity,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final rows = [
      ('Nombre',        name.isEmpty     ? 'Mi Huerto Terraza'        : name),
      ('Código',        'AQUASAVE-D7E1-2026'),
      ('Ubicación',     location.isEmpty ? 'Balcón, Lima — 4.º piso'  : location),
      ('Tipo de espacio', 'Balcón'),
      ('Cultivos',      crop.isEmpty     ? 'Tomates, Lechuga, Albahaca': crop),
      ('Umbrales',      '${minHumidity.round()}% – ${maxHumidity.round()}%'),
      ('Estado',        '¡Conectado!'),
    ];

    return _Shell(
      label: 'Paso 7 de 7',
      title: '¡Todo listo!',
      subtitle: 'Tu dispositivo ya forma parte de tu huerto AquaSave.',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ilustración
          Container(
            width: 200,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_outlined, size: 64, color: Color(0xFF94BC9A)),
                const SizedBox(height: 8),
                Text('¡Conectado!',
                    style: tt.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF2D3D2C))),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Tabla resumen
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: rows.asMap().entries.map((e) {
                  final isLast = e.key == rows.length - 1;
                  final (label, value) = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label, style: tt.bodySmall?.copyWith(
                                fontSize: 12, color: Colors.black54)),
                            Flexible(
                              child: Text(value,
                                  style: tt.bodySmall?.copyWith(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) Divider(
                        height: 1,
                        color: const Color(0xFF31412F).withValues(alpha: 0.3),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder pasos pendientes ──────────────────────────────────────────────

class _StepPlaceholderContent extends StatelessWidget {
  final int step;
  const _StepPlaceholderContent({required this.step});
  @override
  Widget build(BuildContext context) => _Shell(
    label: 'Paso $step de 7', title: 'Próximamente...',
    body: const SizedBox(height: 40),
  );
}
