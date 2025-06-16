import 'package:flutter/material.dart';
import '../api/mission_api.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';

class MissionService extends ChangeNotifier {
  List<Map<String, dynamic>> _missions = [];
  List<Map<String, dynamic>> _allMissions = [];
  Map<String, List<Map<String, dynamic>>> _missionsByDate = {};
  Map<String, dynamic>? _nextMission;
  bool _isLoading = false;
  String? _userId;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  BuildContext? _context;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<Map<String, dynamic>> get missions => _missions;
  List<Map<String, dynamic>> get allMissions => _allMissions;
  Map<String, List<Map<String, dynamic>>> get missionsByDate => _missionsByDate;
  Map<String, dynamic>? get nextMission => _nextMission;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  void setUserId(String userId) {
    _userId = userId;
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _filterMissionsByDate();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _organizeMissionsByDate() {
    _missionsByDate.clear();

    for (var mission in _allMissions) {
      try {
        final dateMission = mission['date_mission'];
        if (dateMission == null) continue;

        DateTime missionDate;
        try {
          missionDate = DateTime.parse(dateMission);
        } catch (e) {
          continue;
        }

        final dateStr = DateFormat('yyyy-MM-dd').format(missionDate);

        if (!_missionsByDate.containsKey(dateStr)) {
          _missionsByDate[dateStr] = [];
        }
        _missionsByDate[dateStr]!.add(mission);
      } catch (e) {
        // Ignorer les erreurs de parsing
      }
    }

    // Trier les missions dans chaque jour
    _missionsByDate.forEach((date, missions) {
      missions.sort((a, b) {
        try {
          final timeA = a['heure_depart'] ?? '00:00';
          final timeB = b['heure_depart'] ?? '00:00';
          return timeA.compareTo(timeB);
        } catch (e) {
          return 0;
        }
      });
    });
  }

  void _filterMissionsByDate() {
    if (_allMissions.isEmpty) {
      _missions = [];
      notifyListeners();
      return;
    }

    // Utiliser toutes les missions sans filtrage par date
    _missions = List<Map<String, dynamic>>.from(_allMissions);

    // Trier les missions par date
    _missions.sort((a, b) {
      try {
        final timeA = DateTime.parse(
            a['date_mission'] ?? DateTime.now().toIso8601String());
        final timeB = DateTime.parse(
            b['date_mission'] ?? DateTime.now().toIso8601String());
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0;
      }
    });

    _findNextMission();
    notifyListeners();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> fetchMissions() async {
    if (_userId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final response = await MissionApi.getAllMissions();

      if (response != null) {
        _missions = List<Map<String, dynamic>>.from(response).where((mission) {
          final missionAmbulancier =
              mission['ambulancier_id']?.toString() ?? '';
          final missionDoctor = mission['doctor_id']?.toString() ?? '';
          final missionNurse = mission['nurse_id']?.toString() ?? '';

          return missionAmbulancier == _userId ||
              missionDoctor == _userId ||
              missionNurse == _userId;
        }).toList();

        _allMissions = List<Map<String, dynamic>>.from(_missions);
        _isInitialized = true;
      }
    } catch (e) {
      // Erreur silencieuse
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchMissionDetails(int missionId) async {
    try {
      final response = await MissionApi.getMission(missionId);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void _findNextMission() {
    final nonTerminatedMissions = _missions.where((mission) {
      final statut = mission['statut']?.toString().toLowerCase() ?? '';
      final isTerminee = statut == 'terminée' || statut == 'annulée';
      final isAssigned = mission['ambulancier_id']?.toString() == _userId ||
          mission['doctor_id']?.toString() == _userId ||
          mission['nurse_id']?.toString() == _userId;

      return !isTerminee && isAssigned;
    }).toList();

    nonTerminatedMissions.sort((a, b) {
      final dateA =
          DateTime.parse(a['date_mission'] ?? DateTime.now().toIso8601String());
      final dateB =
          DateTime.parse(b['date_mission'] ?? DateTime.now().toIso8601String());
      return dateA.compareTo(dateB);
    });

    _nextMission =
        nonTerminatedMissions.isNotEmpty ? nonTerminatedMissions.first : null;
  }

  void updateMissionsFromCache(List<Map<String, dynamic>> missions) {
    _missions = List<Map<String, dynamic>>.from(missions);
    _allMissions = List<Map<String, dynamic>>.from(missions);
    _organizeMissionsByDate();
    _filterMissionsByDate();
    _findNextMission();
    notifyListeners();
  }
}
