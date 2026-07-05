import 'package:flutter/material.dart';

import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/remote/esp32_provisioning_datasource.dart';

/// Resultado del aprovisionamiento del ESP32 (para que el wizard sepa que
/// SSID/password se usaron y con que IP quedo el dispositivo).
class ProvisioningResult {
  final String ssid;
  final String password;
  final String deviceIp;

  const ProvisioningResult({
    required this.ssid,
    required this.password,
    required this.deviceIp,
  });
}

/// Abre el flujo real de aprovisionamiento del ESP32.
///
/// Requiere el `deviceId` ya creado en el backend (es el mismo id que el
/// dispositivo usara en sus topicos MQTT). El usuario debe estar conectado a
/// la red WiFi `AquaSave-XXXX` del ESP32.
///
/// Devuelve un [ProvisioningResult] si el ESP32 confirmo la conexion, o `null`
/// si el usuario cancelo.
Future<ProvisioningResult?> showEsp32ProvisioningDialog(
  BuildContext context, {
  required String deviceId,
  Esp32ProvisioningDataSource? dataSource,
  // true cuando se reconecta un dispositivo ya aprovisionado (cambio de red):
  // las instrucciones incluyen como volverlo a modo configuracion (BOOT 3 s).
  bool reconnect = false,
}) {
  return showDialog<ProvisioningResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProvisioningDialog(
      deviceId: deviceId,
      dataSource: dataSource ?? Esp32ProvisioningDataSourceImpl(),
      reconnect: reconnect,
    ),
  );
}

class _ProvisioningDialog extends StatefulWidget {
  final String deviceId;
  final Esp32ProvisioningDataSource dataSource;
  final bool reconnect;

  const _ProvisioningDialog({
    required this.deviceId,
    required this.dataSource,
    this.reconnect = false,
  });

  @override
  State<_ProvisioningDialog> createState() => _ProvisioningDialogState();
}

enum _Phase { intro, scanning, pickNetwork, connecting, backToWifi, error }

class _ProvisioningDialogState extends State<_ProvisioningDialog> {
  _Phase _phase = _Phase.intro;
  List<WifiNetwork> _networks = const [];
  WifiNetwork? _selected;
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String _error = '';
  ProvisioningResult? _pendingResult;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _phase = _Phase.scanning;
      _error = '';
    });
    try {
      final networks = await widget.dataSource.scanNetworks();
      if (!mounted) return;
      setState(() {
        _networks = networks;
        _phase = _Phase.pickNetwork;
      });
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _phase = _Phase.error;
      });
    }
  }

  Future<void> _connect() async {
    final selected = _selected;
    if (selected == null) return;

    setState(() {
      _phase = _Phase.connecting;
      _error = '';
    });
    try {
      final ip = await widget.dataSource.connect(
        ssid: selected.ssid,
        password: _passwordCtrl.text,
        deviceId: widget.deviceId,
      );
      if (!mounted) return;
      // El ESP32 confirmo la conexion y se esta reiniciando para unirse a tu
      // WiFi. Guardamos el resultado pero NO cerramos todavia: primero el
      // usuario debe volver a una red con internet para que la app pueda
      // finalizar el registro en el backend.
      setState(() {
        _pendingResult = ProvisioningResult(
          ssid: selected.ssid,
          password: _passwordCtrl.text,
          deviceIp: ip,
        );
        _phase = _Phase.backToWifi;
      });
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _phase = _Phase.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wifi_tethering_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Conectar tu dispositivo a AquaSave',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(child: SingleChildScrollView(child: _body(cs))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(ColorScheme cs) {
    switch (_phase) {
      case _Phase.intro:
        return _intro(cs);
      case _Phase.scanning:
        return _loading('Buscando redes WiFi cercanas...');
      case _Phase.pickNetwork:
        return _pickNetwork(cs);
      case _Phase.connecting:
        return _loading('Enviando credenciales al dispositivo...');
      case _Phase.backToWifi:
        return _backToWifi(cs);
      case _Phase.error:
        return _errorView(cs);
    }
  }

  Widget _backToWifi(ColorScheme cs) {
    final ssid = _pendingResult?.ssid ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: cs.onPrimary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'El dispositivo se conectó a "$ssid"',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _Step(
          n: 1,
          text: 'El dispositivo ya está en tu WiFi. Ahora vuelve a conectar tu '
              'teléfono a una red CON internet (tu WiFi normal o datos '
              'móviles).',
        ),
        const _Step(
          n: 2,
          text: 'Cuando tengas internet de nuevo, pulsa "Finalizar" para '
              'terminar el registro.',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La red "AquaSave-XXXX" desaparecerá sola: el dispositivo ya '
                  'no la necesita.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(_pendingResult),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Finalizar'),
          ),
        ),
      ],
    );
  }

  Widget _intro(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Step(
          n: 1,
          text: widget.reconnect
              ? 'Con el dispositivo encendido, mantén pulsado su botón BOOT '
                    'durante 3 segundos: olvidará la red anterior y volverá a '
                    'crear su red WiFi propia.'
              : 'Enciende el dispositivo. La primera vez crea su propia red '
                    'WiFi.',
        ),
        const _Step(
          n: 2,
          text: 'En los ajustes WiFi de tu equipo, conéctate a la red '
              '"AquaSave-XXXX" (clave: aquasave123).',
        ),
        const _Step(
          n: 3,
          text: 'Vuelve aquí y pulsa "Buscar redes" para que el dispositivo '
              'escanee tu WiFi.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'En navegador web servido por HTTPS, la conexión al '
                  'dispositivo puede bloquearse. Usa la app móvil o sirve la '
                  'web por HTTP para el aprovisionamiento.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _scan,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Buscar redes'),
          ),
        ),
      ],
    );
  }

  Widget _loading(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 18),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _pickNetwork(ColorScheme cs) {
    if (_networks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('El dispositivo no encontró redes WiFi cercanas.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _scan,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Redes encontradas por el dispositivo',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            IconButton(
              tooltip: 'Volver a escanear',
              onPressed: _scan,
              icon: const Icon(Icons.refresh_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _networks.length,
            itemBuilder: (_, i) {
              final n = _networks[i];
              final sel = n.ssid == _selected?.ssid;
              return ListTile(
                dense: true,
                selected: sel,
                selectedTileColor: cs.primary.withValues(alpha: 0.10),
                leading: Icon(
                  n.bars >= 3
                      ? Icons.wifi_rounded
                      : n.bars >= 1
                      ? Icons.wifi_2_bar_rounded
                      : Icons.wifi_1_bar_rounded,
                  color: cs.primary,
                ),
                title: Text(n.ssid),
                trailing: n.secure
                    ? const Icon(Icons.lock_outline_rounded, size: 16)
                    : const Icon(Icons.lock_open_rounded, size: 16),
                onTap: () => setState(() => _selected = n),
              );
            },
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 14),
          Text(
            'Contraseña de "${_selected!.ssid}"',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              hintText: 'Contraseña WiFi',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _connect,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Conectar dispositivo'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _errorView(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error),
            const SizedBox(width: 8),
            Text(
              'No se pudo completar',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(_error),
        const SizedBox(height: 18),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _phase = _Phase.intro),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int n;
  final String text;

  const _Step({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: cs.primary,
            child: Text(
              '$n',
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
