import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/chat_message.dart';

abstract class AssistantRemoteDataSource {
  // GET /api/irrigation/chat/plants
  Future<List<ChatPlantOption>> listPlants();

  // POST /api/irrigation/chat
  Future<ChatMessage> send({
    required String message,
    String? deviceId,
    List<ChatMessage> history = const [],
  });
}

class HttpAssistantRemoteDataSource implements AssistantRemoteDataSource {
  final http.Client client;

  const HttpAssistantRemoteDataSource({required this.client});

  @override
  Future<List<ChatPlantOption>> listPlants() async {
    final response = await client.get(
      Uri.parse('${AppConstants.apiBaseUrl}/api/irrigation/chat/plants'),
      headers: await _headers(),
    );

    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw ServerException(_error(body, 'No se pudieron cargar tus plantas'));
    }

    final plants = body['plants'];
    if (plants is! List) return const [];
    return plants
        .whereType<Map<String, dynamic>>()
        .map(ChatPlantOption.fromJson)
        .toList();
  }

  @override
  Future<ChatMessage> send({
    required String message,
    String? deviceId,
    List<ChatMessage> history = const [],
  }) async {
    final response = await client.post(
      Uri.parse('${AppConstants.apiBaseUrl}/api/irrigation/chat'),
      headers: await _headers(json: true),
      body: json.encode({
        'message': message,
        'deviceId': ?deviceId,
        // El backend solo necesita los últimos turnos para dar contexto.
        'history': history
            .map(
              (m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'text': m.text,
              },
            )
            .toList(),
      }),
    );

    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw ServerException(_error(body, 'El asistente no pudo responder'));
    }

    final reply = body['reply'] as Map<String, dynamic>?;
    if (reply == null) {
      throw const ServerException('Respuesta del asistente invalida');
    }

    final options = reply['options'];
    return ChatMessage(
      text: reply['text'] as String? ?? '',
      isUser: false,
      fromAi: reply['source'] == 'ai',
      options: options is List
          ? options
                .whereType<Map<String, dynamic>>()
                .map(ChatPlantOption.fromJson)
                .toList()
          : const [],
    );
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    if (token == null || token.isEmpty) {
      throw const ServerException('No hay una sesion activa');
    }
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      if (json) 'Content-Type': 'application/json',
    };
  }

  Map<String, dynamic> _decode(String body) {
    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException('Respuesta del asistente invalida');
    }
    return decoded;
  }

  String _error(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    return message is String && message.isNotEmpty ? message : fallback;
  }
}
