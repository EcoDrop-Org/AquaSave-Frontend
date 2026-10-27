import 'dart:convert';

import 'package:aquasave/features/irrigation_intelligence/data/models/plant_recommendation_model.dart';
import 'package:aquasave/features/irrigation_intelligence/domain/entities/plant_recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Respuesta real capturada del backend (con la IA activa), para fijar el
/// contrato: si el backend cambia de forma, este test falla.
const _liveResponse = '''
{
  "recommendation": {
    "deviceId": "9e3a4ae6-6338-46c3-907b-72b73498e949",
    "speciesId": "albahaca",
    "speciesName": "Albahaca",
    "irrigation": {
      "level": "watch",
      "title": "Mejor esperar: va a llover",
      "body": "Humedad actual en 32% (ideal 45-70%) y 22.8 C, pero con 97% de probabilidad de lluvia es mejor esperar.",
      "reason": "Probabilidad de lluvia 97%.",
      "source": "ai"
    },
    "care": {
      "tips": [
        { "icon": "sun",   "title": "Luz",    "body": "4 a 6 horas de sol directo." },
        { "icon": "water", "title": "Riego",  "body": "Rango optimo 45-70%." },
        { "icon": "bug",   "title": "Plagas", "body": "Vigila el exceso de humedad." }
      ],
      "source": "ai"
    },
    "info": { "description": "sweet basil" },
    "generatedAt": "2026-10-27T03:02:27.807Z",
    "validUntil": "2026-10-27T03:12:27.807Z"
  }
}
''';

void main() {
  group('PlantRecommendationModel.fromJson', () {
    test('parsea la respuesta real del backend', () {
      final body = json.decode(_liveResponse) as Map<String, dynamic>;
      final model = PlantRecommendationModel.fromJson(
        body['recommendation'] as Map<String, dynamic>,
      );

      expect(model.speciesId, 'albahaca');
      expect(model.speciesName, 'Albahaca');
      expect(model.irrigation.level, RecommendationLevel.watch);
      expect(model.irrigation.source, AdviceSource.ai);
      expect(model.irrigation.reason, contains('97%'));
      expect(model.careTips, hasLength(3));
      expect(model.careTips.first.icon, 'sun');
      expect(model.careSource, AdviceSource.ai);
      expect(model.description, 'sweet basil');
      // El free tier de Perenual no siempre da foto: debe quedar en null.
      expect(model.imageUrl, isNull);
    });

    test('mapea los tres niveles de urgencia', () {
      for (final (raw, expected) in [
        ('act', RecommendationLevel.act),
        ('watch', RecommendationLevel.watch),
        ('ok', RecommendationLevel.ok),
      ]) {
        final model = PlantRecommendationModel.fromJson({
          'deviceId': 'd1',
          'irrigation': {'level': raw},
        });
        expect(model.irrigation.level, expected);
      }
    });

    test('un nivel desconocido no rompe el parseo', () {
      final model = PlantRecommendationModel.fromJson({
        'deviceId': 'd1',
        'irrigation': {'level': 'algo-nuevo'},
      });

      expect(model.irrigation.level, RecommendationLevel.ok);
    });

    test('sobrevive a una respuesta minima', () {
      final model = PlantRecommendationModel.fromJson({'deviceId': 'd1'});

      expect(model.speciesId, 'otra');
      expect(model.careTips, isEmpty);
      expect(model.irrigation.source, AdviceSource.rules);
      expect(model.validUntil.isAfter(DateTime.now()), isTrue);
    });

    test('descarta consejos sin texto', () {
      final model = PlantRecommendationModel.fromJson({
        'deviceId': 'd1',
        'care': {
          'tips': [
            {'icon': 'sun', 'title': 'Luz', 'body': 'Sol directo.'},
            {'icon': 'water', 'title': 'Riego', 'body': ''},
            'basura',
          ],
        },
      });

      expect(model.careTips, hasLength(1));
    });

    test('isExpired usa validUntil', () {
      final expired = PlantRecommendationModel.fromJson({
        'deviceId': 'd1',
        'validUntil': '2020-01-01T00:00:00.000Z',
      });

      expect(expired.isExpired, isTrue);
    });
  });
}
