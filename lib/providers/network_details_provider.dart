import 'package:flutter/material.dart';

import '../data/models/image_model.dart';
import '../data/models/network_detailed_model.dart';
import '../data/tmdb_repository.dart';

class NetworkDetailsProvider extends ChangeNotifier {
  NetworkDetailsProvider(this._repository, {required this.networkId}) {
    load();
  }

  final TmdbRepository _repository;
  final int networkId;

  NetworkDetailed? _network;
  List<ImageModel> _logos = const [];
  bool _isLoading = false;
  String? _errorMessage;

  NetworkDetailed? get network => _network;
  List<ImageModel> get logos => List.unmodifiable(_logos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _network != null;

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchNetworkDetails(networkId, forceRefresh: forceRefresh),
        _repository.fetchNetworkLogos(networkId, forceRefresh: forceRefresh),
      ]);

      _network = results[0] as NetworkDetailed;
      _logos = results[1] as List<ImageModel>;
    } catch (error) {
      _errorMessage = error.toString();
      if (!hasData) {
        _network = null;
        _logos = const [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(forceRefresh: true);
}
