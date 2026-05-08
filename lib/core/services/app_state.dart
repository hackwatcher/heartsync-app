import 'package:flutter/foundation.dart';
import 'persistence_service.dart';

/// Central app state for user/partner info - persisted across sessions
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final PersistenceService _persistence = PersistenceService();

  String _myName = 'You';
  String _partnerName = 'Alex';
  String _myTimezone = 'Europe/Istanbul';
  String _partnerTimezone = 'Europe/Istanbul';
  DateTime? _reunionDate;
  String _reunionLabel = 'Next Reunion';
  bool _isConnected = false;
  String? _roomId;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _vibrationIntensity = 'Orta';
  String? _myPhotoUrl;
  String? _partnerPhotoUrl;

  String get myName => _myName;
  String get partnerName => _partnerName;
  String get myTimezone => _myTimezone;
  String get partnerTimezone => _partnerTimezone;
  DateTime? get reunionDate => _reunionDate;
  String get reunionLabel => _reunionLabel;
  bool get isConnected => _isConnected;
  String? get roomId => _roomId;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String get vibrationIntensity => _vibrationIntensity;
  String? get myPhotoUrl => _myPhotoUrl;
  String? get partnerPhotoUrl => _partnerPhotoUrl;

  Future<void> loadFromStorage() async {
    _myName = await _persistence.getString('my_name') ?? 'You';
    _partnerName = await _persistence.getString('partner_name') ?? 'Alex';
    _myTimezone = await _persistence.getString('my_timezone') ?? 'Europe/Istanbul';
    _partnerTimezone = await _persistence.getString('partner_timezone') ?? 'Europe/Istanbul';
    _reunionLabel = await _persistence.getString('reunion_label') ?? 'Next Reunion';
    _roomId = await _persistence.getString('room_id');
    _isConnected = await _persistence.getBool('is_connected') ?? false;
    _notificationsEnabled = await _persistence.getBool('notifications_enabled') ?? true;
    _darkModeEnabled = await _persistence.getBool('dark_mode_enabled') ?? true;
    _vibrationIntensity = await _persistence.getString('vibration_intensity') ?? 'Orta';
    
    final dateStr = await _persistence.getString('reunion_date');
    if (dateStr != null) {
      _reunionDate = DateTime.tryParse(dateStr);
    }
    notifyListeners();
  }

  Future<void> setMyName(String name) async {
    _myName = name;
    await _persistence.saveString('my_name', name);
    notifyListeners();
  }

  Future<void> setPartnerName(String name) async {
    _partnerName = name;
    await _persistence.saveString('partner_name', name);
    notifyListeners();
  }

  Future<void> setMyTimezone(String tz) async {
    _myTimezone = tz;
    await _persistence.saveString('my_timezone', tz);
    notifyListeners();
  }

  Future<void> setPartnerTimezone(String tz) async {
    _partnerTimezone = tz;
    await _persistence.saveString('partner_timezone', tz);
    notifyListeners();
  }

  Future<void> setReunionDate(DateTime date, String label) async {
    _reunionDate = date;
    _reunionLabel = label;
    await _persistence.saveString('reunion_date', date.toIso8601String());
    await _persistence.saveString('reunion_label', label);
    notifyListeners();
  }

  Future<void> setConnected(bool connected, {String? room}) async {
    _isConnected = connected;
    _roomId = room ?? _roomId;
    await _persistence.saveBool('is_connected', connected);
    if (room != null) await _persistence.saveString('room_id', room);
    notifyListeners();
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _roomId = null;
    await _persistence.saveBool('is_connected', false);
    await _persistence.remove('room_id');
    notifyListeners();
  }

  Duration? get timeUntilReunion {
    if (_reunionDate == null) return null;
    final diff = _reunionDate!.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _persistence.saveBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    _darkModeEnabled = enabled;
    await _persistence.saveBool('dark_mode_enabled', enabled);
    notifyListeners();
  }

  Future<void> setVibrationIntensity(String intensity) async {
    _vibrationIntensity = intensity;
    await _persistence.saveString('vibration_intensity', intensity);
    notifyListeners();
  }
}
