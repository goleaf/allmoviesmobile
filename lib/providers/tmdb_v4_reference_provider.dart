import 'package:flutter/foundation.dart';

import '../data/models/tmdb_v4_endpoint.dart';
import '../data/services/tmdb_v4_api_service.dart';
import '../data/tmdb_v4_repository.dart';
import 'tmdb_v4_auth_provider.dart';

enum EndpointExecutionStatus { idle, loading, success, error }

class EndpointExecutionState {
  const EndpointExecutionState._({
    required this.status,
    this.payload,
    this.errorMessage,
  });

  const EndpointExecutionState.idle()
    : this._(status: EndpointExecutionStatus.idle);
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
  TmdbV4ReferenceProvider(this._repository, this._authProvider) {
    _authProvider.addListener(_handleAuthChanged);
  }

  final TmdbV4Repository _repository;
  TmdbV4AuthProvider _authProvider;

  final Map<String, EndpointExecutionState> _states = {};

  List<TmdbV4EndpointGroup> get groups => _repository.groups;

  bool get isAuthenticated => _authProvider.isAuthenticated;

  EndpointExecutionState stateFor(TmdbV4Endpoint endpoint) {
    return _states[endpoint.id] ?? const EndpointExecutionState.idle();
  }

  bool canExecute(TmdbV4Endpoint endpoint) {
    if (!endpoint.supportsExecution) {
      return false;
    }
    if (endpoint.requiresUserToken && !isAuthenticated) {
      return false;
    }
    return true;
  }

  Future<void> execute(TmdbV4Endpoint endpoint) async {
    if (!endpoint.supportsExecution) {
      _states[endpoint.id] = const EndpointExecutionState.error(
        'Execution disabled. Update your credentials to try this endpoint.',
      );
      notifyListeners();
      return;
    }

    if (endpoint.requiresUserToken && !isAuthenticated) {
      _states[endpoint.id] = const EndpointExecutionState.error(
        'Sign in with your TMDB account to execute this endpoint.',
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
      final accountId = _authProvider.accountId;
      if (endpoint.path.contains('{account_id}') &&
          (accountId == null || accountId.isEmpty)) {
        _states[endpoint.id] = const EndpointExecutionState.error(
          'Account id missing from TMDB profile. Sign out and try again.',
        );
        notifyListeners();
        return;
      }
      final payload = await _repository.execute(
        endpoint,
        accountId: accountId,
      );
      _states[endpoint.id] = EndpointExecutionState.success(payload);
    } on TmdbV4ApiException catch (error) {
      _states[endpoint.id] = EndpointExecutionState.error(error.message);
    } catch (error) {
      _states[endpoint.id] = EndpointExecutionState.error(error.toString());
    }

    notifyListeners();
  }

  void updateAuthProvider(TmdbV4AuthProvider authProvider) {
    if (identical(_authProvider, authProvider)) {
      return;
    }
    _authProvider.removeListener(_handleAuthChanged);
    _authProvider = authProvider;
    _authProvider.addListener(_handleAuthChanged);
    notifyListeners();
  }

  void _handleAuthChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthChanged);
    super.dispose();
  }
}
