import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../domain/entities/device.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/device_list_card.dart';
import 'device_detail_dialog.dart';
import 'esp32_provisioning_dialog.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DevicesBloc>().add(const LoadDevices());
  }

  @override
  Widget build(BuildContext context) => const _DevicesContent();
}

class _DevicesContent extends StatelessWidget {
  const _DevicesContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppHeader(title: l10n.t('navDevices')),
          Expanded(
            child: BlocConsumer<DevicesBloc, DevicesState>(
              listenWhen: (previous, current) =>
                  current is DevicesLoaded &&
                  current.lastError != null &&
                  (previous is! DevicesLoaded ||
                      previous.lastError != current.lastError),
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text((state as DevicesLoaded).lastError!),
                  ),
                );
              },
              builder: (context, state) {
                if (state is DevicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DevicesFailureState) {
                  return Center(child: Text(state.message));
                }

                final devices = state is DevicesLoaded
                    ? state.devices
                    : <Device>[];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spaceLg,
                    AppDimensions.spaceLg,
                    AppDimensions.spaceLg,
                    AppDimensions.spaceXl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth >= 660;
                          return wide
                              ? _WideGrid(devices: devices)
                              : _NarrowList(devices: devices);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WideGrid extends StatelessWidget {
  final List<Device> devices;

  const _WideGrid({required this.devices});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 28,
      runSpacing: 28,
      children: [
        ...devices.map(
          (device) => SizedBox(
            width: 430,
            child: DeviceListCard(
              device: device,
              isActive: _isActive(context, device),
              onEdit: () => _showDeviceDialog(context, device: device),
              onSetActive: () =>
                  context.read<DevicesBloc>().add(SelectActiveDevice(device.id)),
              onViewDetails: () => showDeviceDetailDialog(context, device),
            ),
          ),
        ),
        SizedBox(
          width: 430,
          height: 236,
          child: _AddDeviceCard(
            onTap: () => _showDeviceOnboardingDialog(context),
          ),
        ),
      ],
    );
  }

  bool _isActive(BuildContext context, Device device) {
    final state = context.watch<DevicesBloc>().state;
    return state is DevicesLoaded && state.activeDevice.id == device.id;
  }
}

class _NarrowList extends StatelessWidget {
  final List<Device> devices;

  const _NarrowList({required this.devices});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...devices.map(
          (device) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
            child: DeviceListCard(
              device: device,
              isActive: _isActive(context, device),
              onEdit: () => _showDeviceDialog(context, device: device),
              onSetActive: () =>
                  context.read<DevicesBloc>().add(SelectActiveDevice(device.id)),
              onViewDetails: () => showDeviceDetailDialog(context, device),
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: _AddDeviceCard(
            onTap: () => _showDeviceOnboardingDialog(context),
          ),
        ),
      ],
    );
  }

  bool _isActive(BuildContext context, Device device) {
    final state = context.watch<DevicesBloc>().state;
    return state is DevicesLoaded && state.activeDevice.id == device.id;
  }
}

class _AddDeviceCard extends StatefulWidget {
  final VoidCallback onTap;

  const _AddDeviceCard({required this.onTap});

  @override
  State<_AddDeviceCard> createState() => _AddDeviceCardState();
}

class _AddDeviceCardState extends State<_AddDeviceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _hovered ? 1.012 : 1,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _hovered
                  ? cs.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              border: Border.all(
                color: cs.primary.withValues(alpha: _hovered ? 0.72 : 0.58),
                width: 1.8,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hovered
                        ? cs.primary.withValues(alpha: 0.14)
                        : Colors.transparent,
                    border: Border.all(color: cs.primary, width: 2.8),
                  ),
                  child: Icon(Icons.add_rounded, size: 34, color: cs.primary),
                ),
                const SizedBox(height: 44),
                Text(
                  l10n.t('addDevice'),
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add device onboarding ───────────────────────────────────────────────────

Future<void> _showDeviceOnboardingDialog(BuildContext context) async {
  const totalSteps = 7;
  var step = 1;
  var selectedSsid = '';
  var rememberNetwork = true;
  var crop = 'Plantas de vegetales';
  var minHumidity = 50.0;
  var maxHumidity = 80.0;
  _PlaceResult? selectedPlace;

  // Estado de aprovisionamiento real del ESP32. Si el usuario vincula el
  // dispositivo en el paso WiFi, aqui queda el id que genero el backend, para
  // no volver a crear el dispositivo al finalizar el wizard.
  String? provisionedDeviceId;
  bool deviceLinked = false;

  final l10n = AppLocalizations.of(context);
  final passwordCtrl = TextEditingController(text: 'aquasave123');
  final nameCtrl = TextEditingController(text: 'Mi huerto terraza');
  final plantCountCtrl = TextEditingController(text: '5');
  final descriptionCtrl = TextEditingController();

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool validateCurrentStep() {
    if (step == 2 && !deviceLinked && selectedSsid.trim().isEmpty) {
      showMessage(
        'Vincula el dispositivo (botón "Vincular dispositivo") o continúa '
        'sin vincular para configurarlo luego.',
      );
      return false;
    }
    if (step == 4) {
      if (nameCtrl.text.trim().length < 3) {
        showMessage(l10n.t('invalidName'));
        return false;
      }
      final plants = int.tryParse(plantCountCtrl.text.trim());
      if (plants == null || plants < 1) {
        showMessage(l10n.t('invalidPlantCount'));
        return false;
      }
      if (selectedPlace == null) {
        showMessage(l10n.t('invalidLocation'));
        return false;
      }
    }
    return true;
  }

  void addDevice(BuildContext dialogContext) {
    final place = selectedPlace;
    final location = place?.displayName.trim() ?? '';
    final plantCount = int.tryParse(plantCountCtrl.text.trim()) ?? 1;
    final description = descriptionCtrl.text.trim();

    if (location.isEmpty) {
      showMessage(l10n.t('invalidLocation'));
      return;
    }

    final localeMap = place == null || place.byLocale.isEmpty
        ? null
        : Map<String, String>.from(place.byLocale);

    if (provisionedDeviceId != null) {
      // El dispositivo ya se creo en el backend al vincularlo en el paso WiFi.
      // Aqui solo actualizamos sus datos finales (nombre, ubicacion, cultivo).
      context.read<DevicesBloc>().add(
        EditDeviceRequested(
          deviceId: provisionedDeviceId!,
          name: nameCtrl.text.trim(),
          location: location,
          plantCount: plantCount,
          latitude: place?.latitude,
          longitude: place?.longitude,
          description: description.isEmpty ? null : description,
          locationByLocale: localeMap,
        ),
      );
    } else {
      // Flujo sin vincular ESP32: se crea el dispositivo normalmente.
      context.read<DevicesBloc>().add(
        AddDeviceRequested(
          name: nameCtrl.text.trim(),
          location: location,
          plantCount: plantCount,
          latitude: place?.latitude,
          longitude: place?.longitude,
          description: description.isEmpty ? null : description,
          locationByLocale: localeMap,
        ),
      );
    }
    Navigator.of(dialogContext).pop();
  }

  // Vincula el ESP32: crea el dispositivo en el backend (para obtener su id) y
  // abre el flujo de aprovisionamiento (scan + connect) con ese id. Devuelve
  // true si el dispositivo quedo conectado a WiFi. Se llama desde el paso 2.
  Future<bool> linkDevice(
    void Function(void Function()) setWizardState,
  ) async {
    if (deviceLinked) return true;

    final repo = context.read<DevicesBloc>().devicesRepository;
    final tentativeName = nameCtrl.text.trim().isEmpty
        ? 'Dispositivo AquaSave'
        : nameCtrl.text.trim();

    // 1. Crear el dispositivo en el backend para obtener su id (uuid).
    final created = await repo.addDevice(
      name: tentativeName,
      location: 'Pendiente de configurar',
      plantCount: 1,
    );

    final device = created.fold((failure) {
      showMessage(failure.message);
      return null;
    }, (device) => device);
    if (device == null) return false;

    if (!context.mounted) return false;

    // 2. Abrir el flujo real de aprovisionamiento con el id recien creado.
    final result = await showEsp32ProvisioningDialog(
      context,
      deviceId: device.id,
    );

    if (result == null) {
      // El usuario cancelo el aprovisionamiento: revertir el device creado
      // para no dejar dispositivos huerfanos.
      await repo.deleteDevice(device.id);
      return false;
    }

    setWizardState(() {
      provisionedDeviceId = device.id;
      deviceLinked = true;
      selectedSsid = result.ssid;
      passwordCtrl.text = result.password;
    });
    showMessage('Dispositivo vinculado y conectado a "${result.ssid}".');
    return true;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setWizardState) {
          final cs = Theme.of(dialogContext).colorScheme;
          final mq = MediaQuery.sizeOf(dialogContext);
          final compact = mq.width < 720;

          void next() {
            if (!validateCurrentStep()) return;
            if (step == totalSteps) {
              addDevice(dialogContext);
              return;
            }
            setWizardState(() => step++);
          }

          void back() {
            if (step == 1) {
              Navigator.of(dialogContext).pop();
              return;
            }
            setWizardState(() => step--);
          }

          Widget content() {
            return switch (step) {
              1 => const _WizardPrepStep(),
              2 => _WizardWifiStep(
                ssid: selectedSsid,
                passwordCtrl: passwordCtrl,
                rememberNetwork: rememberNetwork,
                deviceLinked: deviceLinked,
                onSsidChanged: (value) =>
                    setWizardState(() => selectedSsid = value),
                onRememberChanged: (value) =>
                    setWizardState(() => rememberNetwork = value),
                onLinkDevice: () => linkDevice(setWizardState),
              ),
              3 => const _WizardVerificationStep(),
              4 => _WizardGardenStep(
                nameCtrl: nameCtrl,
                plantCountCtrl: plantCountCtrl,
                descriptionCtrl: descriptionCtrl,
                crop: crop,
                selectedPlace: selectedPlace,
                onCropChanged: (value) => setWizardState(() => crop = value),
                onPlaceChanged: (value) =>
                    setWizardState(() => selectedPlace = value),
              ),
              5 => _WizardThresholdStep(
                minHumidity: minHumidity,
                maxHumidity: maxHumidity,
                crop: crop,
                onChanged: (values) {
                  setWizardState(() {
                    minHumidity = values.start;
                    maxHumidity = values.end;
                  });
                },
                onPreset: (min, max, label) {
                  setWizardState(() {
                    minHumidity = min;
                    maxHumidity = max;
                    crop = label;
                  });
                },
              ),
              6 => const _WizardSensorStep(),
              7 => _WizardReadyStep(
                name: nameCtrl.text.trim().isEmpty
                    ? 'Mi huerto terraza'
                    : nameCtrl.text.trim(),
                location: selectedPlace?.displayName ?? '',
                crop: crop,
                minHumidity: minHumidity,
                maxHumidity: maxHumidity,
              ),
              _ => const SizedBox.shrink(),
            };
          }

          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 36,
              vertical: compact ? 18 : 32,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 920,
                maxHeight: mq.height * 0.92,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 18 : 28,
                      18,
                      compact ? 10 : 18,
                      6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _WizardStepper(
                            total: totalSteps,
                            current: step,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: l10n.t('close'),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 18 : 28,
                        10,
                        compact ? 18 : 28,
                        0,
                      ),
                      child: _WizardPanel(
                        stepLabel: 'Paso $step de $totalSteps',
                        child: content(),
                      ),
                    ),
                  ),
                  _WizardFooter(
                    onBack: back,
                    onNext: next,
                    backLabel: step == 1 ? l10n.t('cancel') : 'Atrás',
                    nextLabel: step == totalSteps
                        ? l10n.t('addDevice')
                        : 'Continuar',
                    muted: cs.outline.withValues(alpha: 0.24),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  passwordCtrl.dispose();
  nameCtrl.dispose();
  plantCountCtrl.dispose();
  descriptionCtrl.dispose();
}

class _WizardStepper extends StatelessWidget {
  final int total;
  final int current;

  const _WizardStepper({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= current ? cs.primary : cs.surface,
              border: Border.all(
                color: i <= current
                    ? cs.primary
                    : cs.outline.withValues(alpha: 0.62),
              ),
            ),
            child: i < current
                ? Icon(Icons.check_rounded, size: 14, color: cs.onPrimary)
                : null,
          ),
          if (i != total)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: i < current
                    ? cs.primary
                    : cs.outline.withValues(alpha: 0.45),
              ),
            ),
        ],
      ],
    );
  }
}

class _WizardPanel extends StatelessWidget {
  final String stepLabel;
  final Widget child;

  const _WizardPanel({required this.stepLabel, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
      decoration: BoxDecoration(
        color: isDark
            ? cs.primary.withValues(alpha: 0.16)
            : cs.primary.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String backLabel;
  final String nextLabel;
  final Color muted;

  const _WizardFooter({
    required this.onBack,
    required this.onNext,
    required this.backLabel,
    required this.nextLabel,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: muted),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 132,
                child: OutlinedButton(
                  onPressed: onBack,
                  child: Text(backLabel),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 190,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: Text(nextLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WizardPrepStep extends StatelessWidget {
  const _WizardPrepStep();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _WizardResponsiveRow(
      left: _Esp32Illustration(color: cs.onSurface),
      right: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conecta tu ESP32 a AquaSave',
            style: tt.headlineMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Antes de continuar:',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _WizardCheckRow(
            icon: Icons.light_mode_outlined,
            text: 'El ESP32 está encendido con el LED azul fijo.',
          ),
          const SizedBox(height: 9),
          const _WizardCheckRow(
            icon: Icons.wifi_rounded,
            text: 'Estás cerca del router WiFi.',
          ),
          const SizedBox(height: 9),
          const _WizardCheckRow(
            icon: Icons.settings_input_antenna_rounded,
            text: 'Tu computadora está conectada a la misma red.',
          ),
        ],
      ),
    );
  }
}

class _WizardWifiStep extends StatefulWidget {
  final String ssid;
  final TextEditingController passwordCtrl;
  final bool rememberNetwork;
  final bool deviceLinked;
  final ValueChanged<String> onSsidChanged;
  final ValueChanged<bool> onRememberChanged;
  final Future<bool> Function() onLinkDevice;

  const _WizardWifiStep({
    required this.ssid,
    required this.passwordCtrl,
    required this.rememberNetwork,
    required this.deviceLinked,
    required this.onSsidChanged,
    required this.onRememberChanged,
    required this.onLinkDevice,
  });

  @override
  State<_WizardWifiStep> createState() => _WizardWifiStepState();
}

class _WizardWifiStepState extends State<_WizardWifiStep> {
  bool _linking = false;

  Future<void> _link() async {
    setState(() => _linking = true);
    try {
      await widget.onLinkDevice();
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conectar el dispositivo a WiFi',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vincula tu ESP32 para que escanee tu red WiFi y se conecte. '
          'Recomendamos una red de 2.4 GHz.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.74),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        if (widget.deviceLinked)
          _LinkedBanner(ssid: widget.ssid)
        else
          _LinkPrompt(linking: _linking, onLink: _link),
      ],
    );
  }
}

class _LinkPrompt extends StatelessWidget {
  final bool linking;
  final VoidCallback onLink;

  const _LinkPrompt({required this.linking, required this.onLink});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.router_outlined, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Antes de vincular:',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WizardCheckRow(
            icon: Icons.power_settings_new_rounded,
            text: 'El ESP32 está encendido. La primera vez crea su red '
                '"AquaSave-XXXX".',
          ),
          const SizedBox(height: 6),
          _WizardCheckRow(
            icon: Icons.wifi_rounded,
            text: 'Conéctate a esa red WiFi desde tu equipo (clave: '
                'aquasave123).',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: linking ? null : onLink,
              icon: linking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link_rounded),
              label: Text(linking ? 'Vinculando...' : 'Vincular dispositivo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedBanner extends StatelessWidget {
  final String ssid;

  const _LinkedBanner({required this.ssid});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: cs.onPrimary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispositivo vinculado',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conectado a la red "$ssid". Continúa para configurar tu '
                  'huerto.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
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

class _WizardVerificationStep extends StatelessWidget {
  const _WizardVerificationStep();

  static const _checks = [
    'Conexión WiFi',
    'Asignación IP',
    'Servidor AquaSave',
    'Sincronización inicial',
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verificación',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Estamos comprobando la conexión del ESP32 con AquaSave.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.74),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 680;
            final success = Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: cs.onPrimary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Dispositivo conectado',
                    style: tt.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AQUASAVE-D7E1 está en línea y reportando.',
                    textAlign: TextAlign.center,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.58),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
            final list = Column(
              children: [
                for (final check in _checks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _VerificationRow(label: check),
                  ),
              ],
            );

            if (compact) {
              return Column(
                children: [success, const SizedBox(height: 16), list],
              );
            }
            return Row(
              children: [
                Expanded(child: success),
                const SizedBox(width: 24),
                Expanded(child: list),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WizardGardenStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController plantCountCtrl;
  final TextEditingController descriptionCtrl;
  final String crop;
  final _PlaceResult? selectedPlace;
  final ValueChanged<String> onCropChanged;
  final ValueChanged<_PlaceResult?> onPlaceChanged;

  const _WizardGardenStep({
    required this.nameCtrl,
    required this.plantCountCtrl,
    required this.descriptionCtrl,
    required this.crop,
    required this.selectedPlace,
    required this.onCropChanged,
    required this.onPlaceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos del huerto',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'La ubicación se guardará con coordenadas exactas para consultar el clima del huerto.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.74),
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final fields = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del huerto',
                    prefixIcon: Icon(Icons.sensors_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: plantCountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de plantas',
                    prefixIcon: Icon(Icons.eco_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: descriptionCtrl,
                  minLines: 2,
                  maxLines: 3,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Una nota corta sobre este huerto',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 6),
                _WizardUpperLabel('TIPO DE PLANTAS'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in const [
                      'Plantas de vegetales',
                      'Plantas con frutos',
                      'Hierbas aromáticas',
                      'Suculentas y cactus',
                    ])
                      ChoiceChip(
                        label: Text(item),
                        selected: crop == item,
                        onSelected: (_) => onCropChanged(item),
                      ),
                  ],
                ),
              ],
            );
            final location = _LocationSearchPanel(
              initialSelection: selectedPlace,
              onChanged: onPlaceChanged,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  fields,
                  const SizedBox(height: 20),
                  location,
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: fields),
                  const SizedBox(width: 18),
                  Expanded(flex: 7, child: location),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WizardThresholdStep extends StatelessWidget {
  final double minHumidity;
  final double maxHumidity;
  final String crop;
  final ValueChanged<RangeValues> onChanged;
  final void Function(double min, double max, String label) onPreset;

  const _WizardThresholdStep({
    required this.minHumidity,
    required this.maxHumidity,
    required this.crop,
    required this.onChanged,
    required this.onPreset,
  });

  static const _presets = [
    ('Plantas de vegetales', 50.0, 80.0),
    ('Plantas con frutos', 35.0, 75.0),
    ('Hierbas aromáticas', 35.0, 70.0),
    ('Suculentas y cactus', 20.0, 50.0),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Umbrales de humedad',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Define el rango óptimo. AquaSave alertará y regará dentro de este rango.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.74),
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final slider = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ValuePill(label: 'Mínimo', value: minHumidity),
                    _ValuePill(label: 'Máximo', value: maxHumidity),
                  ],
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  min: 0,
                  max: 100,
                  divisions: 100,
                  labels: RangeLabels(
                    '${minHumidity.round()}%',
                    '${maxHumidity.round()}%',
                  ),
                  values: RangeValues(minHumidity, maxHumidity),
                  onChanged: (values) {
                    if (values.end - values.start < 10) return;
                    onChanged(values);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['0%', '25%', '50%', '75%', '100%']
                        .map(
                          (value) => Text(
                            value,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.62),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),
                _WizardCheckRow(
                  icon: Icons.tips_and_updates_outlined,
                  text:
                      'Sugerimos ${minHumidity.round()}-${maxHumidity.round()}% para $crop.',
                ),
              ],
            );
            final presets = Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Presets por cultivo',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final preset in _presets)
                    _PresetTile(
                      label: preset.$1,
                      min: preset.$2,
                      max: preset.$3,
                      selected:
                          crop == preset.$1 &&
                          minHumidity == preset.$2 &&
                          maxHumidity == preset.$3,
                      onTap: () => onPreset(preset.$2, preset.$3, preset.$1),
                    ),
                ],
              ),
            );

            if (compact) {
              return Column(
                children: [slider, const SizedBox(height: 18), presets],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: slider),
                const SizedBox(width: 28),
                Expanded(flex: 4, child: presets),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WizardSensorStep extends StatelessWidget {
  const _WizardSensorStep();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final cards = const [
      _WizardSensorCard(
        icon: Icons.water_drop_rounded,
        label: 'Humedad de suelo',
        value: '62%',
        color: Color(0xFF52A7D8),
      ),
      _WizardSensorCard(
        icon: Icons.thermostat_rounded,
        label: 'Temperatura',
        value: '24.3°C',
        color: Color(0xFFE25E4F),
      ),
      _WizardSensorCard(
        icon: Icons.light_mode_rounded,
        label: 'Luminosidad',
        value: '48 200 lx',
        color: Color(0xFFD7B850),
      ),
      _WizardSensorCard(
        icon: Icons.opacity_rounded,
        label: 'Humedad ambiental',
        value: '58%',
        color: Color(0xFF5FA06E),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prueba de sensores',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vamos a leer los sensores conectados al ESP32 para verificar que funcionan.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.74),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 620 ? 1 : 2;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: columns == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 14) / 2,
                    child: card,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WizardReadyStep extends StatelessWidget {
  final String name;
  final String location;
  final String crop;
  final double minHumidity;
  final double maxHumidity;

  const _WizardReadyStep({
    required this.name,
    required this.location,
    required this.crop,
    required this.minHumidity,
    required this.maxHumidity,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final rows = [
      ('Nombre', name),
      ('Código', 'AQUASAVE-D7E1-2026'),
      ('Ubicación', location.isEmpty ? 'Pendiente' : location),
      ('Tipo de espacio', 'Balcón'),
      ('Cultivo', crop),
      ('Umbrales', '${minHumidity.round()}% - ${maxHumidity.round()}%'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Todo listo',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tu dispositivo ya forma parte de tu huerto AquaSave.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.74),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            final illustration = Container(
              height: 230,
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_florist_rounded,
                        color: cs.primary,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Conectado',
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
            final summary = _SummaryTable(rows: rows);

            if (compact) {
              return Column(
                children: [illustration, const SizedBox(height: 16), summary],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: illustration),
                const SizedBox(width: 24),
                Expanded(flex: 6, child: summary),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WizardResponsiveRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _WizardResponsiveRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 20), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: left),
            const SizedBox(width: 28),
            Expanded(flex: 7, child: right),
          ],
        );
      },
    );
  }
}

class _Esp32Illustration extends StatelessWidget {
  final Color color;

  const _Esp32Illustration({required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 188,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Container(
          width: 170,
          height: 86,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1D1C),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LedDot(on: true, color: cs.primary),
              const SizedBox(width: 7),
              const _LedDot(on: false, color: Colors.white),
              const SizedBox(width: 7),
              const _LedDot(on: false, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _LedDot extends StatelessWidget {
  final bool on;
  final Color color;

  const _LedDot({required this.on, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: on ? 8 : 6,
      height: on ? 8 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? color : Colors.white.withValues(alpha: 0.18),
        boxShadow: on
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.7),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

class _WizardCheckRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WizardCheckRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  final String label;

  const _VerificationRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.surface.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardUpperLabel extends StatelessWidget {
  final String text;

  const _WizardUpperLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  final String label;
  final double value;

  const _ValuePill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
      ),
      child: Text(
        '$label: ${value.round()}%',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  final String label;
  final double min;
  final double max;
  final bool selected;
  final VoidCallback onTap;

  const _PresetTile({
    required this.label,
    required this.min,
    required this.max,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? cs.primary.withValues(alpha: 0.12)
            : cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? cs.primary.withValues(alpha: 0.48)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${min.round()} - ${max.round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WizardSensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WizardSensorCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: tt.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
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

class _SummaryTable extends StatelessWidget {
  final List<(String, String)> rows;

  const _SummaryTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 118,
                    child: Text(
                      rows[i].$1,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              Divider(color: cs.outline.withValues(alpha: 0.34)),
          ],
        ],
      ),
    );
  }
}

// ── Add / edit device dialog ─────────────────────────────────────────────────

Future<void> _showDeviceDialog(BuildContext context, {Device? device}) async {
  final editing = device != null;
  final nameCtrl = TextEditingController(text: device?.name ?? '');
  final plantCountCtrl = TextEditingController(
    text: (device?.plantCount ?? 1).toString(),
  );
  final formKey = GlobalKey<FormState>();
  final l10n = AppLocalizations.of(context);

  _PlaceResult? selectedPlace =
      (device?.latitude != null && device?.longitude != null)
      ? _PlaceResult(
          name: device!.location,
          displayName: device.location,
          country: '',
          countryCode: '',
          latitude: device.latitude!,
          longitude: device.longitude!,
          byLocale: device.locationByLocale ?? const {},
        )
      : null;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final tt = Theme.of(dialogContext).textTheme;
      final cs = Theme.of(dialogContext).colorScheme;
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final compact = screenWidth < 560;

      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 32,
              vertical: 24,
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            actionsPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    editing ? Icons.edit_outlined : Icons.add_link_outlined,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    editing ? l10n.t('editDevice') : l10n.t('registerDevice'),
                    style: tt.headlineMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.58,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.16),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 520;
                            final nameField = _DeviceDialogField(
                              controller: nameCtrl,
                              label: l10n.t('gardenName'),
                              icon: Icons.sensors_outlined,
                              validator: (value) {
                                if (value == null || value.trim().length < 3) {
                                  return l10n.t('invalidName');
                                }
                                return null;
                              },
                            );
                            final plantField = _DeviceDialogField(
                              controller: plantCountCtrl,
                              label: l10n.t('plantCount'),
                              icon: Icons.eco_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final parsed = int.tryParse(value ?? '');
                                if (parsed == null || parsed < 1) {
                                  return l10n.t('invalidPlantCount');
                                }
                                return null;
                              },
                            );

                            if (stacked) {
                              return Column(
                                children: [
                                  nameField,
                                  const SizedBox(height: 12),
                                  plantField,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(flex: 3, child: nameField),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: plantField),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _LocationSearchPanel(
                        initialSelection: selectedPlace,
                        onChanged: (place) =>
                            setDialogState(() => selectedPlace = place),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              _DeviceDialogFooter(
                compact: compact,
                cancelLabel: l10n.t('cancel'),
                submitLabel: editing
                    ? l10n.t('saveChanges')
                    : l10n.t('register'),
                onCancel: () => Navigator.of(dialogContext).pop(),
                onSubmit: () {
                  final resolvedName = selectedPlace?.displayName.trim();
                  final location =
                      (resolvedName != null && resolvedName.isNotEmpty)
                      ? resolvedName
                      : (device?.location ?? '');
                  final byLocale =
                      selectedPlace == null || selectedPlace!.byLocale.isEmpty
                      ? null
                      : Map<String, String>.from(selectedPlace!.byLocale);
                  _submitDeviceDialog(
                    context,
                    dialogContext,
                    formKey,
                    nameCtrl,
                    location,
                    plantCountCtrl,
                    device,
                    l10n,
                    latitude: selectedPlace?.latitude,
                    longitude: selectedPlace?.longitude,
                    locationByLocale: byLocale,
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );

  nameCtrl.dispose();
  plantCountCtrl.dispose();
}

void _submitDeviceDialog(
  BuildContext pageContext,
  BuildContext dialogContext,
  GlobalKey<FormState> formKey,
  TextEditingController nameCtrl,
  String location,
  TextEditingController plantCountCtrl,
  Device? device,
  AppLocalizations l10n, {
  double? latitude,
  double? longitude,
  Map<String, String>? locationByLocale,
}) {
  if (!formKey.currentState!.validate()) return;
  if (location.trim().length < 3) {
    ScaffoldMessenger.of(
      pageContext,
    ).showSnackBar(SnackBar(content: Text(l10n.t('invalidLocation'))));
    return;
  }

  final name = nameCtrl.text.trim();
  final plantCount = int.parse(plantCountCtrl.text.trim());

  if (device == null) {
    pageContext.read<DevicesBloc>().add(
      AddDeviceRequested(
        name: name,
        location: location,
        plantCount: plantCount,
        latitude: latitude,
        longitude: longitude,
        locationByLocale: locationByLocale,
      ),
    );
  } else {
    pageContext.read<DevicesBloc>().add(
      EditDeviceRequested(
        deviceId: device.id,
        name: name,
        location: location,
        plantCount: plantCount,
        latitude: latitude,
        longitude: longitude,
        locationByLocale: locationByLocale,
      ),
    );
  }

  Navigator.of(dialogContext).pop();
}

// ── Location search panel ────────────────────────────────────────────────────

class _LocationSearchPanel extends StatefulWidget {
  final _PlaceResult? initialSelection;
  final ValueChanged<_PlaceResult?> onChanged;

  const _LocationSearchPanel({this.initialSelection, required this.onChanged});

  @override
  State<_LocationSearchPanel> createState() => _LocationSearchPanelState();
}

class _LocationSearchPanelState extends State<_LocationSearchPanel> {
  final TextEditingController _ctrl = TextEditingController();
  Timer? _debounce;
  List<_PlaceResult> _results = const [];
  bool _loading = false;
  bool _error = false;
  _PlaceResult? _selected;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
    if (_selected != null) _ctrl.text = _selected!.displayName;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (_selected != null) {
      _selected = null;
      widget.onChanged(null);
    }
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = false;
    });
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(query));
  }

  /// Two-step location resolution.
  ///
  /// Geocoding: turn the user's free text into precise coordinates.
  /// We query OpenStreetMap / Nominatim first — it indexes neighbourhoods,
  /// suburbs and districts worldwide far better than the Open-Meteo geocoder
  /// (the reason "Miraflores" used to resolve to a neighbouring district) — and
  /// fall back to Open-Meteo's geocoder if Nominatim returns nothing.
  /// Whatever the user picks, the exact lat/lon is stored on the device, so the
  /// weather forecast is requested by coordinates and is always for that point.
  Future<void> _search(String query) async {
    final id = ++_requestId;
    final lang = AppLocalizations.of(context).locale.languageCode;

    final fromNominatim = await _fetchNominatim(query, lang);
    if (!mounted || id != _requestId) return;

    List<_PlaceResult>? results = fromNominatim;
    if (results == null || results.isEmpty) {
      final fromOpenMeteo = await _fetchOpenMeteo(query, lang);
      if (!mounted || id != _requestId) return;
      if (fromOpenMeteo != null) results = fromOpenMeteo;
    }

    if (results == null) {
      setState(() {
        _loading = false;
        _error = true;
        _results = const [];
      });
      return;
    }

    setState(() {
      _loading = false;
      _error = false;
      _results = results!;
    });
  }

  /// Returns `null` on a network/parse error, or a (possibly empty) list on a
  /// successful response.
  Future<List<_PlaceResult>?> _fetchNominatim(String query, String lang) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '8',
      'accept-language': lang,
    });
    try {
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent': 'AquaSave/1.0 (smart irrigation app)',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];
      final out = <_PlaceResult>[];
      final seen = <String>{};
      for (final item in decoded.whereType<Map<String, dynamic>>()) {
        final place = _PlaceResult.fromNominatim(item);
        if (place == null) continue;
        final key =
            '${place.latitude.toStringAsFixed(3)},${place.longitude.toStringAsFixed(3)}';
        if (!seen.add(key)) continue;
        out.add(place);
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<_PlaceResult>?> _fetchOpenMeteo(String query, String lang) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '8',
      'language': lang,
      'format': 'json',
    });
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final payload = jsonDecode(response.body);
      final rawResults = payload is Map<String, dynamic>
          ? (payload['results'] as List<dynamic>? ?? const [])
          : const [];
      return rawResults
          .whereType<Map<String, dynamic>>()
          .map(_PlaceResult.fromOpenMeteo)
          .whereType<_PlaceResult>()
          .toList();
    } catch (_) {
      return null;
    }
  }

  void _select(_PlaceResult place) {
    _debounce?.cancel();
    final lang = AppLocalizations.of(context).locale.languageCode;
    final seeded = place.withByLocale({lang: place.displayName});
    setState(() {
      _selected = seeded;
      _results = const [];
      _ctrl.text = seeded.displayName;
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    });
    widget.onChanged(seeded);
    FocusScope.of(context).unfocus();
    // En background, traemos también los otros idiomas soportados para que el
    // string se traduzca solo al cambiar de idioma sin tener que re-elegir.
    _hydrateOtherLocales(seeded, lang);
  }

  Future<void> _hydrateOtherLocales(_PlaceResult base, String currentLang) async {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .where((l) => l != currentLang)
        .toList();
    final updated = Map<String, String>.from(base.byLocale);
    for (final lang in supported) {
      final reverse = await _reverseGeocodeNominatim(
        base.latitude,
        base.longitude,
        lang,
      );
      if (!mounted) return;
      if (reverse != null && reverse.displayName.isNotEmpty) {
        updated[lang] = reverse.displayName;
      }
    }
    if (!mounted) return;
    final current = _selected;
    if (current == null) return;
    // Solo aplicamos si el usuario sigue con la misma ubicación elegida.
    if (current.latitude != base.latitude || current.longitude != base.longitude) {
      return;
    }
    final hydrated = current.withByLocale(updated);
    setState(() => _selected = hydrated);
    widget.onChanged(hydrated);
  }

  Future<_PlaceResult?> _reverseGeocodeNominatim(
    double lat,
    double lon,
    String lang,
  ) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'format': 'jsonv2',
      'addressdetails': '1',
      'accept-language': lang,
    });
    try {
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent': 'AquaSave/1.0 (smart irrigation app)',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return _PlaceResult.fromNominatim(decoded);
    } catch (_) {
      return null;
    }
  }

  void _clearSelection() {
    _debounce?.cancel();
    setState(() {
      _selected = null;
      _ctrl.clear();
      _results = const [];
      _error = false;
      _loading = false;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.travel_explore_outlined, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.t('locationSearchTitle'),
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('locationSearchSubtitle'),
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.64),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: l10n.t('locationSearchHint'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _ctrl.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.t('locationChange'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clearSelection,
                    ),
              filled: true,
              fillColor: cs.surface.withValues(alpha: 0.92),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: cs.outline.withValues(alpha: 0.22),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.primary, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildBody(context, l10n, cs, tt),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme tt,
  ) {
    if (_selected != null) {
      final place = _selected!;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('locationConfirmed'),
                    style: tt.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.displayName,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.t('locationCoordinates')}: '
                    '${place.latitude.toStringAsFixed(3)}, '
                    '${place.longitude.toStringAsFixed(3)}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _clearSelection,
              child: Text(l10n.t('locationChange')),
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.t('locationSearching'),
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.62),
            ),
          ),
        ],
      );
    }

    if (_error) {
      return _InfoBanner(
        icon: Icons.wifi_off_rounded,
        color: cs.error,
        text: l10n.t('locationError'),
      );
    }

    final query = _ctrl.text.trim();
    if (query.length < 2) {
      return _InfoBanner(
        icon: Icons.info_outline_rounded,
        color: cs.primary,
        text: l10n.t('locationPickHint'),
      );
    }

    if (_results.isEmpty) {
      return _InfoBanner(
        icon: Icons.search_off_rounded,
        color: cs.error,
        text: l10n.t('locationNoMatches'),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _results.length; i++) ...[
          if (i != 0) const SizedBox(height: 8),
          _PlaceTile(place: _results[i], onTap: () => _select(_results[i])),
        ],
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.74),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final _PlaceResult place;
  final VoidCallback onTap;

  const _PlaceTile({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final secondary = place.secondaryLine;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  place.flagEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (secondary.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        secondary,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.add_location_alt_outlined,
                color: cs.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared dialog widgets ────────────────────────────────────────────────────

class _DeviceDialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _DeviceDialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: cs.surface.withValues(alpha: 0.88),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
      ),
    );
  }
}

class _DeviceDialogFooter extends StatelessWidget {
  final bool compact;
  final String cancelLabel;
  final String submitLabel;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _DeviceDialogFooter({
    required this.compact,
    required this.cancelLabel,
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: cs.outline.withValues(alpha: 0.14)),
        ),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeviceSubmitButton(label: submitLabel, onPressed: onSubmit),
                const SizedBox(height: 10),
                _DeviceCancelButton(label: cancelLabel, onPressed: onCancel),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 160,
                  child: _DeviceCancelButton(
                    label: cancelLabel,
                    onPressed: onCancel,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 190,
                  child: _DeviceSubmitButton(
                    label: submitLabel,
                    onPressed: onSubmit,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DeviceCancelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DeviceCancelButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.close),
      label: Text(label),
    );
  }
}

class _DeviceSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DeviceSubmitButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.check_circle_outline),
      label: Text(label),
    );
  }
}

// ── Geocoding result model ───────────────────────────────────────────────────

class _PlaceResult {
  final String name;
  final String displayName;
  final String? region;
  final String country;
  final String countryCode;
  final double latitude;
  final double longitude;
  // Versiones del displayName indexadas por código de idioma. Se rellena al
  // seleccionar (idioma actual de inmediato, otros en background).
  final Map<String, String> byLocale;

  const _PlaceResult({
    required this.name,
    required this.displayName,
    this.region,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    this.byLocale = const {},
  });

  _PlaceResult withByLocale(Map<String, String> map) => _PlaceResult(
    name: name,
    displayName: displayName,
    region: region,
    country: country,
    countryCode: countryCode,
    latitude: latitude,
    longitude: longitude,
    byLocale: map,
  );

  /// Builds a result from an Open-Meteo geocoding entry.
  static _PlaceResult? fromOpenMeteo(Map<String, dynamic> json) {
    final name = (json['name'] as String? ?? '').trim();
    final lat = (json['latitude'] as num?)?.toDouble();
    final lon = (json['longitude'] as num?)?.toDouble();
    if (name.isEmpty || lat == null || lon == null) return null;

    final admin1 = (json['admin1'] as String? ?? '').trim();
    final admin2 = (json['admin2'] as String? ?? '').trim();
    final country = (json['country'] as String? ?? '').trim();
    final code = (json['country_code'] as String? ?? '').trim().toUpperCase();

    return _build(
      name: name,
      regionCandidates: [admin2, admin1],
      country: country,
      countryCode: code,
      latitude: lat,
      longitude: lon,
    );
  }

  /// Builds a result from an OpenStreetMap / Nominatim entry. Nominatim exposes
  /// a structured `address` object, so we can pick the most specific component
  /// (neighbourhood / suburb / district) reliably anywhere in the world.
  static _PlaceResult? fromNominatim(Map<String, dynamic> json) {
    final lat = double.tryParse('${json['lat'] ?? ''}');
    final lon = double.tryParse('${json['lon'] ?? ''}');
    if (lat == null || lon == null) return null;

    final address = json['address'] is Map
        ? Map<String, dynamic>.from(json['address'] as Map)
        : const <String, dynamic>{};
    String pick(List<String> keys) {
      for (final key in keys) {
        final value = address[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return '';
    }

    final primary = pick([
      'neighbourhood',
      'suburb',
      'quarter',
      'city_district',
      'borough',
      'town',
      'village',
      'hamlet',
      'city',
      'municipality',
      'county',
    ]);
    final city = pick(['city', 'town', 'municipality', 'village']);
    final state = pick(['state', 'region', 'province', 'state_district']);
    final country = pick(['country']);
    final code = (address['country_code'] as String? ?? '')
        .trim()
        .toUpperCase();

    var name = primary;
    if (name.isEmpty) {
      final rawName = (json['name'] as String? ?? '').trim();
      name = rawName.isNotEmpty
          ? rawName
          : (json['display_name'] as String? ?? '').split(',').first.trim();
    }
    if (name.isEmpty) return null;

    return _build(
      name: name,
      regionCandidates: [city, state],
      country: country,
      countryCode: code,
      latitude: lat,
      longitude: lon,
    );
  }

  static _PlaceResult _build({
    required String name,
    required List<String> regionCandidates,
    required String country,
    required String countryCode,
    required double latitude,
    required double longitude,
  }) {
    bool sameAs(String a, String b) => a.toLowerCase() == b.toLowerCase();

    final regionParts = <String>[];
    for (final part in regionCandidates) {
      if (part.isEmpty || sameAs(part, name)) continue;
      if (regionParts.any((e) => sameAs(e, part))) continue;
      regionParts.add(part);
    }

    final displayParts = <String>[name];
    for (final part in [...regionParts, country]) {
      if (part.isEmpty) continue;
      if (displayParts.any((e) => sameAs(e, part))) continue;
      displayParts.add(part);
    }

    return _PlaceResult(
      name: name,
      displayName: displayParts.join(', '),
      region: regionParts.isEmpty ? null : regionParts.join(', '),
      country: country,
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  String get secondaryLine {
    final parts = <String>[];
    if (region != null && region!.isNotEmpty) parts.add(region!);
    if (country.isNotEmpty &&
        !parts.any((e) => e.toLowerCase() == country.toLowerCase())) {
      parts.add(country);
    }
    return parts.join(' · ');
  }

  String get flagEmoji {
    if (countryCode.length != 2) return '🌍';
    final upper = countryCode.toUpperCase();
    final a = upper.codeUnitAt(0);
    final b = upper.codeUnitAt(1);
    if (a < 65 || a > 90 || b < 65 || b > 90) return '🌍';
    const base = 0x1F1E6;
    return String.fromCharCode(base + (a - 65)) +
        String.fromCharCode(base + (b - 65));
  }
}
