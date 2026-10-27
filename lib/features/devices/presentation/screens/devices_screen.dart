import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/plant_species.dart';
import '../cubit/species_info_cubit.dart';
import '../widgets/plant_photo.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/device_list_card.dart';
import 'device_detail_dialog.dart';

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
  // Flujo: primero se registra la PLANTA (especie y datos), y el dispositivo
  // de riego se vincula despues. Una planta = un dispositivo; la planta puede
  // existir sin dispositivo y la app igual muestra su ficha y cuidados.
  //
  // El dispositivo llega con el WiFi en su firmware y se conecta solo, por eso
  // el wizard no pide red ni contraseña.
  const totalSteps = 4;
  var step = 1;
  PlantSpecies? selectedSpecies;
  _PlaceResult? selectedPlace;

  final l10n = AppLocalizations.of(context);
  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  // Nombre que escribe el usuario cuando elige "Otra planta".
  final otherNameCtrl = TextEditingController();

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool validateCurrentStep() {
    // Paso 1: elegir la especie.
    if (step == 1) {
      if (selectedSpecies == null) {
        showMessage('Elige qué planta vas a cuidar');
        return false;
      }
      // Sin nombre no hay con que buscar su foto ni sus cuidados.
      if (selectedSpecies!.isGeneric &&
          otherNameCtrl.text.trim().length < 3) {
        showMessage('Escribe el nombre de tu planta');
        return false;
      }
    }
    // Paso 2: datos de la planta.
    if (step == 2) {
      if (nameCtrl.text.trim().length < 3) {
        showMessage(l10n.t('invalidName'));
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
    final description = descriptionCtrl.text.trim();

    if (location.isEmpty) {
      showMessage(l10n.t('invalidLocation'));
      return;
    }

    final localeMap = place == null || place.byLocale.isEmpty
        ? null
        : Map<String, String>.from(place.byLocale);

    context.read<DevicesBloc>().add(
      AddDeviceRequested(
        name: nameCtrl.text.trim(),
        location: location,
        // Una planta por dispositivo de riego.
        plantCount: 1,
        latitude: place?.latitude,
        longitude: place?.longitude,
        // Con "Otra planta" el nombre escrito va como nota: el backend lo
        // usa para buscar su foto y ficha.
        description: _noteFor(selectedSpecies, otherNameCtrl, description),
        speciesId: selectedSpecies?.id,
        locationByLocale: localeMap,
      ),
    );
    Navigator.of(dialogContext).pop();
  }

  // Borra un dispositivo huerfano con reintentos. Se usa como rollback si el
  // aprovisionamiento no se completa, para no dejar basura en el backend.
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
              1 => _WizardSpeciesStep(
                selected: selectedSpecies,
                otherNameCtrl: otherNameCtrl,
                onChanged: (value) =>
                    setWizardState(() => selectedSpecies = value),
              ),
              2 => _WizardPlantStep(
                nameCtrl: nameCtrl,
                descriptionCtrl: descriptionCtrl,
                species: selectedSpecies,
                selectedPlace: selectedPlace,
                onPlaceChanged: (value) =>
                    setWizardState(() => selectedPlace = value),
              ),
              3 => const _WizardConnectStep(),
              4 => _WizardReadyStep(
                name: nameCtrl.text.trim().isEmpty
                    ? (selectedSpecies?.commonName ?? 'Mi planta')
                    : nameCtrl.text.trim(),
                location: selectedPlace?.displayName ?? '',
                species: selectedSpecies,
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

  nameCtrl.dispose();
  descriptionCtrl.dispose();
  otherNameCtrl.dispose();
}

/// Nota que se guarda en el dispositivo. Con "Otra planta" se antepone el
/// nombre que escribio el usuario, porque es con lo que el backend busca su
/// ficha en Wikipedia.
String? _noteFor(
  PlantSpecies? species,
  TextEditingController otherNameCtrl,
  String description,
) {
  final other = otherNameCtrl.text.trim();
  if (species?.isGeneric == true && other.isNotEmpty) {
    return description.isEmpty ? other : '$other. $description';
  }
  return description.isEmpty ? null : description;
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
        // Panel verde suave: acompaña sin competir con el contenido del paso.
        color: isDark
            ? cs.primary.withValues(alpha: 0.12)
            : cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
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

class _WizardSpeciesStep extends StatefulWidget {
  final PlantSpecies? selected;
  final TextEditingController otherNameCtrl;
  final ValueChanged<PlantSpecies> onChanged;

  const _WizardSpeciesStep({
    required this.selected,
    required this.otherNameCtrl,
    required this.onChanged,
  });

  @override
  State<_WizardSpeciesStep> createState() => _WizardSpeciesStepState();
}

class _WizardSpeciesStepState extends State<_WizardSpeciesStep> {
  final _searchCtrl = TextEditingController();
  PlantCategory? _category;

  @override
  void initState() {
    super.initState();
    // Las fotos salen del backend; se piden para todo el catalogo visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SpeciesInfoCubit>().ensureLoaded(
        PlantSpeciesCatalog.selectable.map((s) => s.id),
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final query = _searchCtrl.text;

    // Buscar ignora la categoria: el usuario espera encontrar su planta
    // escribiendo el nombre, sin tener que acertar el grupo.
    final results = query.trim().isNotEmpty
        ? PlantSpeciesCatalog.search(query)
        : (_category == null
              ? PlantSpeciesCatalog.selectable
              : PlantSpeciesCatalog.byCategory(_category!));

    final grouped = <PlantCategory, List<PlantSpecies>>{};
    for (final species in results) {
      grouped.putIfAbsent(species.category, () => []).add(species);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Qué planta vas a cuidar?',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cada planta necesita un nivel de humedad distinto. Al elegir la '
          'especie, AquaSave sabe cuándo regarla.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.74),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.t('searchPlant'),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                  ),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        // Filtro por categoria. Se oculta al buscar, porque la busqueda ya
        // atraviesa todas.
        if (query.trim().isEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(
                  label: l10n.t('allCategories'),
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final category in PlantCategory.values) ...[
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: category.label,
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.t('noPlantsFound'),
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          )
        else
          for (final entry in grouped.entries) ...[
            // El encabezado solo aporta cuando hay varias categorias juntas.
            if (grouped.length > 1) ...[
              Text(
                entry.key.label,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final species in entry.value)
                  _SpeciesCard(
                    species: species,
                    selected: widget.selected?.id == species.id,
                    onTap: () => widget.onChanged(species),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        // "Otra planta": el usuario escribe el nombre y el backend busca su
        // foto y ficha en Wikipedia.
        _OtherPlantCard(
          selected: widget.selected?.isGeneric ?? false,
          controller: widget.otherNameCtrl,
          onTap: () => widget.onChanged(PlantSpeciesCatalog.generic),
        ),
        if (widget.selected case final species?) ...[
          const SizedBox(height: 18),
          _SpeciesInfoPanel(species: species),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Opcion de especie con su foto.
class _SpeciesCard extends StatelessWidget {
  final PlantSpecies species;
  final bool selected;
  final VoidCallback onTap;

  const _SpeciesCard({
    required this.species,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final info = context.watch<SpeciesInfoCubit>().infoFor(species.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 116,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.12)
                : cs.surface.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? cs.primary : cs.outline.withValues(alpha: 0.22),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  PlantPhoto(imageUrl: info?.imageUrl, size: 100, radius: 11),
                  if (selected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                species.commonName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${species.soilMinPct}-${species.soilMaxPct}%',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Otra planta": el usuario escribe el nombre de su especie.
class _OtherPlantCard extends StatelessWidget {
  final bool selected;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _OtherPlantCard({
    required this.selected,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surface.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? cs.primary : cs.outline.withValues(alpha: 0.22),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 19,
                    color: selected ? cs.primary : cs.onSurface,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '¿No está en la lista?',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: cs.primary,
                    ),
                ],
              ),
              if (selected) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n.t('otherPlantName'),
                    hintText: l10n.t('otherPlantHint'),
                    prefixIcon: const Icon(Icons.local_florist_outlined),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Buscaremos su foto y sus cuidados. Usaremos valores de '
                  'humedad generales hasta conocerla mejor.',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Ficha de la especie elegida: humedad ideal, luz y un consejo de cuidado.
class _SpeciesInfoPanel extends StatelessWidget {
  final PlantSpecies species;

  const _SpeciesInfoPanel({required this.species});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final info = context.watch<SpeciesInfoCubit>().infoFor(species.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: cs.primary.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!species.isGeneric)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PlantPhoto(
                    imageUrl: info?.imageUrl,
                    size: 64,
                    radius: 12,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.isGeneric
                          ? 'Cuidados generales'
                          : 'Cuidados de la '
                                '${species.commonName.toLowerCase()}',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SpeciesInfoRow(
                      icon: Icons.water_drop_outlined,
                      label: 'Humedad ideal',
                      value: '${species.soilMinPct}% a ${species.soilMaxPct}%',
                    ),
                    const SizedBox(height: 6),
                    _SpeciesInfoRow(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Luz',
                      value: species.sunlight,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Descripcion de Wikipedia, cuando el backend la trae.
          if (info?.description case final description?) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.75),
                height: 1.35,
              ),
            ),
          ],
          if (species.careTip.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    species.careTip,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SpeciesInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpeciesInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 7),
        Text(
          '$label: ',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _WizardConnectStep extends StatelessWidget {
  // El dispositivo de riego trae el WiFi configurado de fabrica: se conecta
  // solo al encenderlo. Aqui no se menciona hardware ni firmware: el usuario
  // solo necesita saber que debe encenderlo y que puede hacerlo despues.
  const _WizardConnectStep();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _WizardResponsiveRow(
      left: const _IrrigationDeviceIllustration(),
      right: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conecta tu dispositivo de riego',
            style: tt.headlineMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Es el aparato que mide la humedad de la tierra y riega tu planta '
            'automáticamente.',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 20),
          const _WizardCheckRow(
            icon: Icons.power_rounded,
            text: 'Enciéndelo y espera a que la luz quede fija.',
          ),
          const SizedBox(height: 9),
          const _WizardCheckRow(
            icon: Icons.wifi_rounded,
            text: 'Déjalo cerca de tu router: se conecta solo a tu WiFi.',
          ),
          const SizedBox(height: 9),
          const _WizardCheckRow(
            icon: Icons.link_rounded,
            text: 'Al terminar, abre "Ver detalles" de tu planta para '
                'vincularlo con su código.',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Todavía no tienes el dispositivo? No hay problema: '
                    'registra tu planta igual y conéctalo cuando lo tengas. '
                    'Mientras tanto verás sus cuidados y recomendaciones.',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                      height: 1.35,
                    ),
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

class _WizardPlantStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descriptionCtrl;
  final PlantSpecies? species;
  final _PlaceResult? selectedPlace;
  final ValueChanged<_PlaceResult?> onPlaceChanged;

  const _WizardPlantStep({
    required this.nameCtrl,
    required this.descriptionCtrl,
    required this.species,
    required this.selectedPlace,
    required this.onPlaceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final speciesName = species?.commonName ?? 'planta';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos de tu $speciesName',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Guardamos la ubicación para consultar el clima de tu zona y '
          'ajustar el riego.',
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
                  decoration: InputDecoration(
                    labelText: 'Nombre de tu planta',
                    hintText: 'Mi $speciesName de la terraza',
                    prefixIcon: const Icon(Icons.eco_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: descriptionCtrl,
                  minLines: 2,
                  maxLines: 3,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    hintText: 'Dónde está, en qué maceta, algo que recordar…',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
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

class _WizardReadyStep extends StatelessWidget {
  final String name;
  final String location;
  final PlantSpecies? species;

  const _WizardReadyStep({
    required this.name,
    required this.location,
    required this.species,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final plantSpecies = species ?? PlantSpeciesCatalog.generic;
    final rows = [
      ('Nombre', name),
      ('Ubicación', location.isEmpty ? 'Pendiente' : location),
      ('Planta', plantSpecies.commonName),
      (
        'Humedad ideal',
        '${plantSpecies.soilMinPct}% a ${plantSpecies.soilMaxPct}%',
      ),
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
          'Tu planta ya está registrada en AquaSave.',
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
        const SizedBox(height: 16),
        // Recordatorio de vinculacion, en lenguaje del usuario: el codigo de
        // la planta es lo que identifica a su dispositivo de riego.
        const _WizardCheckRow(
          icon: Icons.link_rounded,
          text: 'Para vincular tu dispositivo de riego: abre "Ver detalles" '
              'de la planta y copia su código.',
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

/// Ilustracion del dispositivo de riego. A proposito NO dibuja una placa
/// electronica: el usuario no deberia pensar en hardware, sino en el aparato
/// que cuida su planta.
class _IrrigationDeviceIllustration extends StatelessWidget {
  const _IrrigationDeviceIllustration();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: cs.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LedDot(on: true, color: cs.primary),
                const SizedBox(width: 7),
                Text(
                  'Encendido',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
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
  // Una planta por dispositivo: ya no se pide cantidad, se pide la especie.
  var selectedSpecies = PlantSpeciesCatalog.byId(device?.speciesId);
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
                            final plantField =
                                DropdownButtonFormField<String>(
                                  initialValue: selectedSpecies.id,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.t('speciesLabel'),
                                    prefixIcon: const Icon(Icons.eco_outlined),
                                  ),
                                  items: [
                                    for (final species
                                        in PlantSpeciesCatalog.all)
                                      DropdownMenuItem(
                                        value: species.id,
                                        child: Text(species.commonName),
                                      ),
                                  ],
                                  onChanged: (value) => setDialogState(
                                    () => selectedSpecies =
                                        PlantSpeciesCatalog.byId(value),
                                  ),
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
                    selectedSpecies,
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
}

void _submitDeviceDialog(
  BuildContext pageContext,
  BuildContext dialogContext,
  GlobalKey<FormState> formKey,
  TextEditingController nameCtrl,
  String location,
  PlantSpecies species,
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

  if (device == null) {
    pageContext.read<DevicesBloc>().add(
      AddDeviceRequested(
        name: name,
        location: location,
        plantCount: 1,
        speciesId: species.id,
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
        plantCount: 1,
        speciesId: species.id,
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
  final String? Function(String?)? validator;

  const _DeviceDialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
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
