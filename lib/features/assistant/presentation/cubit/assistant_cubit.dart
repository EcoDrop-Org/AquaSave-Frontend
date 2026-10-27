import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/remote/assistant_remote_datasource.dart';
import '../../domain/entities/chat_message.dart';

class AssistantState extends Equatable {
  final List<ChatMessage> messages;
  final bool sending;

  /// Planta sobre la que se está preguntando, si el usuario eligió una.
  final ChatPlantOption? focus;
  final String? error;

  const AssistantState({
    this.messages = const [],
    this.sending = false,
    this.focus,
    this.error,
  });

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? sending,
    ChatPlantOption? focus,
    bool clearFocus = false,
    String? error,
    bool clearError = false,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      focus: clearFocus ? null : focus ?? this.focus,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [messages, sending, focus, error];
}

/// Chat con el asistente de plantas.
///
/// El historial se guarda en memoria: es una conversación de consulta, no algo
/// que haga falta persistir entre sesiones.
class AssistantCubit extends Cubit<AssistantState> {
  final AssistantRemoteDataSource remote;

  AssistantCubit({required this.remote}) : super(const AssistantState());

  /// Primer mensaje: saluda y ofrece las plantas como botones.
  Future<void> start() async {
    if (state.messages.isNotEmpty) return;
    await _send('hola', showUserMessage: false);
  }

  /// El usuario eligió una planta con un botón.
  Future<void> focusOn(ChatPlantOption plant) async {
    emit(state.copyWith(focus: plant));
    await _send('¿Cómo está mi ${plant.name}?');
  }

  Future<void> send(String text) => _send(text);

  void clearFocus() => emit(state.copyWith(clearFocus: true));

  void reset() => emit(const AssistantState());

  Future<void> _send(String text, {bool showUserMessage = true}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;

    final history = List<ChatMessage>.from(state.messages);
    final messages = showUserMessage
        ? [...history, ChatMessage(text: trimmed, isUser: true)]
        : history;

    emit(state.copyWith(messages: messages, sending: true, clearError: true));

    try {
      final reply = await remote.send(
        message: trimmed,
        deviceId: state.focus?.deviceId,
        // Se envían los turnos previos, no el que se acaba de escribir.
        history: history,
      );
      if (isClosed) return;
      emit(state.copyWith(messages: [...messages, reply], sending: false));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          sending: false,
          error: e.toString().replaceFirst('ServerException: ', ''),
        ),
      );
    }
  }
}
