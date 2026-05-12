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
            child: BlocBuilder<DevicesBloc, DevicesState>(
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
      spacing: AppDimensions.spaceMd,
      runSpacing: AppDimensions.spaceMd,
      children: [
        ...devices.map(
          (device) => SizedBox(
            width: 420,
            child: DeviceListCard(
              device: device,
              isActive: _isActive(context, device),
              onEdit: () => _showDeviceDialog(context, device: device),
              onViewDetails: () => context.read<DevicesBloc>().add(
                SelectActiveDevice(device.id),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 420,
          height: 260,
          child: _AddDeviceCard(onTap: () => _showDeviceDialog(context)),
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
              onViewDetails: () => context.read<DevicesBloc>().add(
                SelectActiveDevice(device.id),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: _AddDeviceCard(onTap: () => _showDeviceDialog(context)),
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
        scale: _hovered ? 1.01 : 1,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.34),
              border: Border.all(
                color: const Color(0xFF37593F).withValues(alpha: 0.42),
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 48, color: cs.onSurface),
                const SizedBox(height: 14),
                Text(
                  l10n.t('addDevice'),
                  textAlign: TextAlign.center,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
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

Future<void> _showDeviceDialog(BuildContext context, {Device? device}) async {
  final editing = device != null;
  final nameCtrl = TextEditingController(text: device?.name ?? '');
  final plantCountCtrl = TextEditingController(
    text: (device?.plantCount ?? 1).toString(),
  );
  final locationParts = _locationParts(device?.location ?? '');
  final countryCtrl = TextEditingController(text: locationParts.country);
  final cityCtrl = TextEditingController(text: locationParts.city);
  final districtCtrl = TextEditingController(text: locationParts.district);
  final postalCodeCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final l10n = AppLocalizations.of(context);
  _ResolvedLocation? resolvedLocation;
  String? locationMessage;
  var isResolvingLocation = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final tt = Theme.of(dialogContext).textTheme;
      final cs = Theme.of(dialogContext).colorScheme;
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final compact = screenWidth < 560;

      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> resolveLocation() async {
            setDialogState(() {
              isResolvingLocation = true;
              locationMessage = null;
            });
            final result = await _resolveLocation(
              country: countryCtrl.text,
              city: cityCtrl.text,
              district: districtCtrl.text,
              postalCode: postalCodeCtrl.text,
            );
            if (!dialogContext.mounted) return;
            setDialogState(() {
              isResolvingLocation = false;
              resolvedLocation = result;
              if (result != null) {
                if ((result.country ?? '').isNotEmpty) {
                  countryCtrl.text = result.country!;
                }
                if ((result.city ?? '').isNotEmpty) {
                  cityCtrl.text = result.city!;
                }
                if ((result.district ?? '').isNotEmpty) {
                  districtCtrl.text = result.district!;
                }
              }
              locationMessage = result == null
                  ? l10n.t('locationNotFound')
                  : '${l10n.t(result.fromPostalCode ? 'locationResolvedWithPostal' : 'resolvedLocation')}: ${result.displayName}';
            });
          }

          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 32,
              vertical: 24,
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
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
                      fontWeight: FontWeight.w800,
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
                      _DeviceDialogField(
                        controller: nameCtrl,
                        label: l10n.t('gardenName'),
                        icon: Icons.sensors_outlined,
                        validator: (value) {
                          if (value == null || value.trim().length < 3) {
                            return l10n.t('invalidName');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _LocationLookupPanel(
                        countryCtrl: countryCtrl,
                        cityCtrl: cityCtrl,
                        districtCtrl: districtCtrl,
                        postalCodeCtrl: postalCodeCtrl,
                        isResolving: isResolvingLocation,
                        message: locationMessage,
                        onResolve: resolveLocation,
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _DeviceDialogField(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DeviceSubmitButton(
                      label: editing
                          ? l10n.t('saveChanges')
                          : l10n.t('register'),
                      onPressed: () => _submitDeviceDialog(
                        context,
                        dialogContext,
                        formKey,
                        nameCtrl,
                        _buildLocation(
                          resolvedLocation: resolvedLocation,
                          countryCtrl: countryCtrl,
                          cityCtrl: cityCtrl,
                          districtCtrl: districtCtrl,
                          postalCodeCtrl: postalCodeCtrl,
                        ),
                        plantCountCtrl,
                        device,
                        l10n,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n.t('cancel')),
                    ),
                  ],
                )
              else ...[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.t('cancel')),
                ),
                _DeviceSubmitButton(
                  label: editing ? l10n.t('saveChanges') : l10n.t('register'),
                  onPressed: () => _submitDeviceDialog(
                    context,
                    dialogContext,
                    formKey,
                    nameCtrl,
                    _buildLocation(
                      resolvedLocation: resolvedLocation,
                      countryCtrl: countryCtrl,
                      cityCtrl: cityCtrl,
                      districtCtrl: districtCtrl,
                      postalCodeCtrl: postalCodeCtrl,
                    ),
                    plantCountCtrl,
                    device,
                    l10n,
                  ),
                ),
              ],
            ],
          );
        },
      );
    },
  );

  nameCtrl.dispose();
  plantCountCtrl.dispose();
  countryCtrl.dispose();
  cityCtrl.dispose();
  districtCtrl.dispose();
  postalCodeCtrl.dispose();
}

void _submitDeviceDialog(
  BuildContext pageContext,
  BuildContext dialogContext,
  GlobalKey<FormState> formKey,
  TextEditingController nameCtrl,
  String location,
  TextEditingController plantCountCtrl,
  Device? device,
  AppLocalizations l10n,
) {
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
      ),
    );
  } else {
    pageContext.read<DevicesBloc>().add(
      EditDeviceRequested(
        deviceId: device.id,
        name: name,
        location: location,
        plantCount: plantCount,
      ),
    );
  }

  Navigator.of(dialogContext).pop();
}

String _buildLocation({
  required _ResolvedLocation? resolvedLocation,
  required TextEditingController countryCtrl,
  required TextEditingController cityCtrl,
  required TextEditingController districtCtrl,
  required TextEditingController postalCodeCtrl,
}) {
  if (resolvedLocation != null) return resolvedLocation.displayName;

  final parts = [
    districtCtrl.text.trim(),
    cityCtrl.text.trim(),
    countryCtrl.text.trim(),
  ].where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty && postalCodeCtrl.text.trim().isNotEmpty) {
    return postalCodeCtrl.text.trim();
  }
  return parts.join(', ');
}

class _LocationLookupPanel extends StatelessWidget {
  final TextEditingController countryCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController districtCtrl;
  final TextEditingController postalCodeCtrl;
  final bool isResolving;
  final String? message;
  final VoidCallback onResolve;

  const _LocationLookupPanel({
    required this.countryCtrl,
    required this.cityCtrl,
    required this.districtCtrl,
    required this.postalCodeCtrl,
    required this.isResolving,
    required this.message,
    required this.onResolve,
  });

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
                  l10n.t('locationLookupTitle'),
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
            l10n.t('locationFieldsNotSaved'),
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.62),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final country = _DeviceDialogField(
                controller: countryCtrl,
                label: l10n.t('country'),
                hint: l10n.t('countryHint'),
                icon: Icons.public_outlined,
              );
              final city = _DeviceDialogField(
                controller: cityCtrl,
                label: l10n.t('city'),
                hint: l10n.t('cityHint'),
                icon: Icons.location_city_outlined,
              );
              final district = _DeviceDialogField(
                controller: districtCtrl,
                label: l10n.t('district'),
                hint: l10n.t('districtHint'),
                icon: Icons.place_outlined,
              );
              final postal = _DeviceDialogField(
                controller: postalCodeCtrl,
                label: l10n.t('postalCode'),
                hint: l10n.t('postalCodeHint'),
                helperText: l10n.t('postalCodeHelper'),
                icon: Icons.local_post_office_outlined,
                keyboardType: TextInputType.streetAddress,
              );

              if (stacked) {
                return Column(
                  children: [
                    country,
                    const SizedBox(height: 12),
                    city,
                    const SizedBox(height: 12),
                    district,
                    const SizedBox(height: 12),
                    postal,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: country),
                      const SizedBox(width: 12),
                      Expanded(child: city),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: district),
                      const SizedBox(width: 12),
                      Expanded(child: postal),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.primary.withValues(alpha: 0.14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: cs.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.t('postalAlternativeHelp'),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.70),
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isResolving ? null : onResolve,
              icon: isResolving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_outlined),
              label: Text(l10n.t('resolveLocation')),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
              ),
              child: Text(
                message!,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceDialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? helperText;

  const _DeviceDialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
    this.helperText,
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
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 2,
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

Future<_ResolvedLocation?> _resolveLocation({
  required String country,
  required String city,
  required String district,
  required String postalCode,
}) async {
  final countryCode = _countryCodeFor(country);
  final postal = postalCode.trim();

  if (postal.isNotEmpty) {
    final postalResolved = countryCode == null
        ? null
        : await _resolvePostalCode(countryCode, postal);
    if (postalResolved != null) return postalResolved;

    final structuredPostalResolved = await _resolveNominatim(
      country: country,
      countryCode: countryCode,
      city: city,
      district: district,
      postalCode: postal,
    );
    if (structuredPostalResolved != null) return structuredPostalResolved;
  }

  final query = district.trim().isNotEmpty
      ? district.trim()
      : city.trim().isNotEmpty
      ? city.trim()
      : postal;
  if (query.length < 2) return null;

  final params = <String, String>{
    'name': query,
    'count': '10',
    'language': 'es',
    'format': 'json',
  };
  if (countryCode != null) params['countryCode'] = countryCode;
  final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', params);
  final http.Response response;
  try {
    response = await http.get(uri).timeout(const Duration(seconds: 8));
  } catch (_) {
    return null;
  }
  if (response.statusCode < 200 || response.statusCode >= 300) return null;

  final payload = jsonDecode(response.body) as Map<String, dynamic>;
  final results = (payload['results'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .toList();
  if (results.isEmpty) {
    return _resolveNominatim(
      country: country,
      countryCode: countryCode,
      city: city,
      district: district,
      postalCode: postal,
    );
  }

  results.sort((a, b) {
    final scoreB = _locationScore(
      b,
      country: country,
      city: city,
      district: district,
      countryCode: countryCode,
    );
    final scoreA = _locationScore(
      a,
      country: country,
      city: city,
      district: district,
      countryCode: countryCode,
    );
    return scoreB.compareTo(scoreA);
  });

  final best = results.first;
  final bestScore = _locationScore(
    best,
    country: country,
    city: city,
    district: district,
    countryCode: countryCode,
  );
  if (bestScore <= 0) {
    final fallback = await _resolveNominatim(
      country: country,
      countryCode: countryCode,
      city: city,
      district: district,
      postalCode: postal,
    );
    if (fallback != null) return fallback;
  }

  return _locationFromGeocoding(best);
}

Future<_ResolvedLocation?> _resolvePostalCode(
  String countryCode,
  String postalCode,
) async {
  final uri = Uri.https(
    'api.zippopotam.us',
    '/${countryCode.toLowerCase()}/$postalCode',
  );
  final http.Response response;
  try {
    response = await http.get(uri).timeout(const Duration(seconds: 8));
  } catch (_) {
    return null;
  }
  if (response.statusCode < 200 || response.statusCode >= 300) return null;

  final payload = jsonDecode(response.body) as Map<String, dynamic>;
  final places = (payload['places'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .toList();
  if (places.isEmpty) return null;

  final place = places.first;
  final district = (place['place name'] as String? ?? '').trim();
  final city = (place['state'] as String? ?? '').trim();
  final country = (payload['country'] as String? ?? countryCode).trim();
  final displayName = [
    district,
    city,
    country,
  ].where((part) => part.isNotEmpty).join(', ');

  if (displayName.isEmpty) return null;
  return _ResolvedLocation(
    displayName: displayName,
    country: country,
    city: city,
    district: district,
    fromPostalCode: true,
  );
}

int _locationScore(
  Map<String, dynamic> item, {
  required String country,
  required String city,
  required String district,
  required String? countryCode,
}) {
  final name = _normalize(item['name'] as String? ?? '');
  final admin1 = _normalize(item['admin1'] as String? ?? '');
  final admin2 = _normalize(item['admin2'] as String? ?? '');
  final admin3 = _normalize(item['admin3'] as String? ?? '');
  final admin4 = _normalize(item['admin4'] as String? ?? '');
  final itemCountry = _normalize(item['country'] as String? ?? '');
  final itemCountryCode = (item['country_code'] as String? ?? '')
      .trim()
      .toUpperCase();
  final wantedDistrict = _normalize(district);
  final wantedCity = _normalize(city);
  final wantedCountry = _normalize(country);
  var score = 0;

  if (countryCode != null && itemCountryCode.isNotEmpty) {
    score += itemCountryCode == countryCode ? 100 : -150;
  }
  if (wantedDistrict.isNotEmpty && name == wantedDistrict) score += 80;
  if (wantedDistrict.isNotEmpty && admin3 == wantedDistrict) score += 72;
  if (wantedDistrict.isNotEmpty && admin4 == wantedDistrict) score += 60;
  if (wantedDistrict.isNotEmpty && admin2.contains(wantedDistrict)) score += 32;
  if (wantedDistrict.isNotEmpty && admin3.contains(wantedDistrict)) score += 48;
  if (wantedDistrict.isNotEmpty && admin4.contains(wantedDistrict)) score += 38;
  if (wantedCity.isNotEmpty && name.contains(wantedCity)) score += 18;
  if (wantedCity.isNotEmpty && admin1.contains(wantedCity)) score += 38;
  if (wantedCity.isNotEmpty && admin2.contains(wantedCity)) score += 26;
  if (wantedCity.isNotEmpty && admin3.contains(wantedCity)) score += 16;
  if (wantedCountry.isNotEmpty && itemCountry.contains(wantedCountry)) {
    score += 48;
  }

  return score;
}

_ResolvedLocation _locationFromGeocoding(Map<String, dynamic> item) {
  final parts = <String>[
    item['name'] as String? ?? '',
    item['admin3'] as String? ?? '',
    item['admin2'] as String? ?? '',
    item['admin1'] as String? ?? '',
    item['country'] as String? ?? '',
  ];
  final deduped = <String>[];
  for (final part in parts.map((part) => part.trim())) {
    if (part.isEmpty) continue;
    if (deduped.any((existing) => _normalize(existing) == _normalize(part))) {
      continue;
    }
    deduped.add(part);
  }

  return _ResolvedLocation(
    displayName: deduped.join(', '),
    country: item['country'] as String?,
    city: item['admin2'] as String? ?? item['admin1'] as String?,
    district: item['name'] as String?,
  );
}

Future<_ResolvedLocation?> _resolveNominatim({
  required String country,
  required String? countryCode,
  required String city,
  required String district,
  required String postalCode,
}) async {
  final cleanedCountry = country.trim();
  final cleanedCity = city.trim();
  final cleanedDistrict = district.trim();
  final cleanedPostal = postalCode.trim();
  final attempts = <Map<String, String>>[];
  final base = <String, String>{
    'format': 'jsonv2',
    'addressdetails': '1',
    'limit': '8',
    'accept-language': 'es',
  };
  if (countryCode != null) base['countrycodes'] = countryCode.toLowerCase();

  if (cleanedPostal.isNotEmpty && cleanedCountry.isNotEmpty) {
    attempts.add({...base, 'q': '$cleanedPostal, $cleanedCountry'});
  }

  if (cleanedPostal.isNotEmpty &&
      (cleanedDistrict.isNotEmpty || cleanedCity.isNotEmpty)) {
    attempts.add({
      ...base,
      'q': [
        cleanedDistrict,
        cleanedCity,
        cleanedPostal,
        cleanedCountry,
      ].where((part) => part.isNotEmpty).join(', '),
    });
  }

  final structured = Map<String, String>.from(base);
  if (cleanedCountry.isNotEmpty) structured['country'] = cleanedCountry;
  if (cleanedCity.isNotEmpty) structured['city'] = cleanedCity;
  if (cleanedDistrict.isNotEmpty) structured['county'] = cleanedDistrict;
  if (cleanedPostal.isNotEmpty) structured['postalcode'] = cleanedPostal;
  if (structured.length > base.length) attempts.add(structured);

  final freeText = [
    cleanedDistrict,
    cleanedCity,
    cleanedPostal,
    cleanedCountry,
  ].where((part) => part.isNotEmpty).join(', ');
  if (freeText.length >= 2) {
    attempts.add({...base, 'q': freeText});
  }

  for (final params in attempts) {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 8));
    } catch (_) {
      continue;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) continue;

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) continue;
    final results = decoded.whereType<Map<String, dynamic>>().toList();
    if (results.isEmpty) continue;

    results.sort((a, b) {
      final scoreB = _nominatimScore(
        b,
        countryCode: countryCode,
        city: cleanedCity,
        district: cleanedDistrict,
        postalCode: cleanedPostal,
      );
      final scoreA = _nominatimScore(
        a,
        countryCode: countryCode,
        city: cleanedCity,
        district: cleanedDistrict,
        postalCode: cleanedPostal,
      );
      return scoreB.compareTo(scoreA);
    });

    return _locationFromNominatim(
      results.first,
      fromPostalCode: cleanedPostal.isNotEmpty,
    );
  }

  return null;
}

int _nominatimScore(
  Map<String, dynamic> item, {
  required String? countryCode,
  required String city,
  required String district,
  required String postalCode,
}) {
  final address = _addressFromNominatim(item);
  final itemCountryCode = (address['country_code'] as String? ?? '')
      .trim()
      .toUpperCase();
  final itemPostcode = _normalize(address['postcode'] as String? ?? '');
  final itemCity = _normalize(
    _firstString(address, [
      'city',
      'town',
      'village',
      'municipality',
      'county',
      'state',
    ]),
  );
  final itemDistrict = _normalize(
    _firstString(address, [
      'suburb',
      'city_district',
      'district',
      'borough',
      'quarter',
      'neighbourhood',
      'municipality',
      'county',
    ]),
  );
  final wantedCity = _normalize(city);
  final wantedDistrict = _normalize(district);
  final wantedPostal = _normalize(postalCode);
  final importance = ((item['importance'] as num?) ?? 0).clamp(0, 1) * 20;
  final addresstype = (item['addresstype'] as String? ?? '').trim();
  final category = (item['category'] as String? ?? '').trim();
  final placeRank = (item['place_rank'] as num?)?.toInt() ?? 30;
  var score = importance.round();

  if (countryCode != null && itemCountryCode.isNotEmpty) {
    score += itemCountryCode == countryCode ? 120 : -200;
  }
  if (wantedPostal.isNotEmpty && itemPostcode == wantedPostal) score += 140;
  if (wantedPostal.isNotEmpty &&
      itemPostcode.isNotEmpty &&
      itemPostcode != wantedPostal) {
    score -= 100;
  }
  if (wantedPostal.isNotEmpty && addresstype == 'postcode') score += 90;
  if (category == 'boundary' || addresstype == 'city') score += 42;
  if (placeRank >= 28 && addresstype != 'postcode') score -= 36;
  if (wantedDistrict.isNotEmpty && itemDistrict == wantedDistrict) score += 90;
  if (wantedDistrict.isNotEmpty && itemDistrict.contains(wantedDistrict)) {
    score += 58;
  }
  if (wantedCity.isNotEmpty && itemCity == wantedCity) score += 70;
  if (wantedCity.isNotEmpty && itemCity.contains(wantedCity)) score += 42;

  return score;
}

_ResolvedLocation _locationFromNominatim(
  Map<String, dynamic> item, {
  required bool fromPostalCode,
}) {
  final address = _addressFromNominatim(item);
  final country = _firstString(address, ['country']);
  final city = _firstString(address, [
    'city',
    'town',
    'village',
    'municipality',
    'county',
  ]);
  final state = _firstString(address, ['state', 'region']);
  final district = _firstString(address, [
    'suburb',
    'city_district',
    'district',
    'borough',
    'quarter',
    'neighbourhood',
  ]);
  final parts = <String>[district, city, state, country];
  final deduped = <String>[];
  for (final part in parts.map((part) => part.trim())) {
    if (part.isEmpty) continue;
    if (deduped.any((existing) => _normalize(existing) == _normalize(part))) {
      continue;
    }
    deduped.add(part);
  }
  final displayName = deduped.isNotEmpty
      ? deduped.join(', ')
      : (item['display_name'] as String? ?? '').trim();

  return _ResolvedLocation(
    displayName: displayName,
    country: country,
    city: city.isNotEmpty ? city : state,
    district: district,
    fromPostalCode: fromPostalCode,
  );
}

Map<String, dynamic> _addressFromNominatim(Map<String, dynamic> item) {
  final address = item['address'];
  return address is Map<String, dynamic> ? address : <String, dynamic>{};
}

String _firstString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

_LocationParts _locationParts(String location) {
  final parts = location
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  return _LocationParts(
    district: parts.isNotEmpty ? parts.first : location,
    city: parts.length >= 2 ? parts[1] : '',
    country: parts.length >= 3 ? parts.last : '',
  );
}

String? _countryCodeFor(String country) {
  final normalized = _normalize(country).replaceAll(' ', '');
  if (normalized.length == 2) return normalized.toUpperCase();
  const codes = {
    'peru': 'PE',
    'argentina': 'AR',
    'chile': 'CL',
    'colombia': 'CO',
    'mexico': 'MX',
    'espana': 'ES',
    'spain': 'ES',
    'unitedstates': 'US',
    'usa': 'US',
    'estadosunidos': 'US',
    'brazil': 'BR',
    'brasil': 'BR',
    'ecuador': 'EC',
    'bolivia': 'BO',
    'uruguay': 'UY',
    'paraguay': 'PY',
  };
  return codes[normalized];
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');
}

class _ResolvedLocation {
  final String displayName;
  final String? country;
  final String? city;
  final String? district;
  final bool fromPostalCode;

  const _ResolvedLocation({
    required this.displayName,
    this.country,
    this.city,
    this.district,
    this.fromPostalCode = false,
  });
}

class _LocationParts {
  final String district;
  final String city;
  final String country;

  const _LocationParts({
    required this.district,
    required this.city,
    required this.country,
  });
}
