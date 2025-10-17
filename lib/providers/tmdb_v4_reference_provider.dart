import 'package:flutter/foundation.dart';

import '../data/models/tmdb_v4_endpoint.dart';
import '../data/services/tmdb_v4_api_service.dart';
import '../data/tmdb_v4_repository.dart';

enum EndpointExecutionStatus { idle, loading, success, error }

class EndpointExecutionState {
  const EndpointExecutionState._({
    required this.status,
    this.payload,
    this.errorMessage,
  });

  const EndpointExecutionState.idle() : this._(status: EndpointExecutionStatus.idle);
  const EndpointExecutionState.loading()
      : this._(status: EndpointExecutionStatus.loading);
  const EndpointExecutionState.success(String payload)
      : this._(status: EndpointExecutionStatus.success, payload: payload);
  const EndpointExecutionState.error(String message)
      : this._(status: EndpointExecutionStatus.error, errorMessage: message);

  final EndpointExecutionStatus status;
  final String? payload;
  final String? errorMessage;

  bool get hasPayload => payload != null && payload!.isNotEmpty;
}

class TmdbV4ReferenceProvider extends ChangeNotifier {
  TmdbV4ReferenceProvider(this._repository);

  final TmdbV4Repository _repository;

  final Map<String, EndpointExecutionState> _states = {};

  List<TmdbV4EndpointGroup> get groups => _repository.groups;

  EndpointExecutionState stateFor(TmdbV4Endpoint endpoint) {
    return _states[endpoint.id] ?? const EndpointExecutionState.idle();
  }

  Future<void> execute(TmdbV4Endpoint endpoint) async {
    if (!endpoint.supportsExecution) {
      _states[endpoint.id] = const EndpointExecutionState.error(
        'Execution disabled. Update your credentials to try this endpoint.',
      );
      notifyListeners();
      return;
    }

    if (_states[endpoint.id]?.status == EndpointExecutionStatus.loading) {
      return;
    }

    _states[endpoint.id] = const EndpointExecutionState.loading();
    notifyListeners();

    try {
      final payload = await _repository.execute(endpoint);
      _states[endpoint.id] = EndpointExecutionState.success(payload);
    } on TmdbV4ApiException catch (error) {
      _states[endpoint.id] = EndpointExecutionState.error(
        error.message,
      );
    } catch (error) {
      _states[endpoint.id] = EndpointExecutionState.error(error.toString());
    }

    notifyListeners();
  }
}
