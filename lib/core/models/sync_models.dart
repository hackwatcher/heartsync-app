enum MediaType { image, voiceNote, video }

class HSUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String timezone;

  HSUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.timezone,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'timezone': timezone,
  };

  factory HSUser.fromJson(Map<String, dynamic> json) => HSUser(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
    timezone: json['timezone'],
  );
}

class HSRelationship {
  final String id;
  final String partner1Id;
  final String partner2Id;
  final DateTime startDate;
  final DateTime? nextMeetingDate;
  final String status;

  HSRelationship({
    required this.id,
    required this.partner1Id,
    required this.partner2Id,
    required this.startDate,
    this.nextMeetingDate,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'partner1Id': partner1Id,
    'partner2Id': partner2Id,
    'startDate': startDate.toIso8601String(),
    'nextMeetingDate': nextMeetingDate?.toIso8601String(),
    'status': status,
  };

  factory HSRelationship.fromJson(Map<String, dynamic> json) => HSRelationship(
    id: json['id'],
    partner1Id: json['partner1Id'],
    partner2Id: json['partner2Id'],
    startDate: DateTime.parse(json['startDate']),
    nextMeetingDate: json['nextMeetingDate'] != null ? DateTime.parse(json['nextMeetingDate']) : null,
    status: json['status'],
  );

  /// Demo verisi — gerçek kullanıcı oturumu yokken UI önizlemesi için kullanılır.
  static HSRelationship get mock => HSRelationship(
    id: 'mock_rel',
    partner1Id: 'user_1',
    partner2Id: 'user_2',
    startDate: DateTime(2024, 1, 1),
    nextMeetingDate: DateTime.now().add(const Duration(days: 30)),
    status: 'active',
  );
}

class HSMemory {
  final String id;
  final String title;
  final String? imageUrl;
  final String? voiceUrl;
  final DateTime createdAt;
  final String senderId;
  final bool isSealed;

  HSMemory({
    required this.id,
    required this.title,
    this.imageUrl,
    this.voiceUrl,
    required this.createdAt,
    required this.senderId,
    this.isSealed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imageUrl': imageUrl,
    'voiceUrl': voiceUrl,
    'createdAt': createdAt.toIso8601String(),
    'senderId': senderId,
    'isSealed': isSealed,
  };

  factory HSMemory.fromJson(Map<String, dynamic> json) => HSMemory(
    id: json['id'],
    title: json['title'],
    imageUrl: json['imageUrl'],
    voiceUrl: json['voiceUrl'],
    createdAt: DateTime.parse(json['createdAt']),
    senderId: json['senderId'],
    isSealed: json['isSealed'] ?? false,
  );
}

class HSVoiceNote {
  final String id;
  final String url;
  final Duration duration;
  final DateTime createdAt;
  final List<double> waveform;

  HSVoiceNote({
    required this.id,
    required this.url,
    required this.duration,
    required this.createdAt,
    required this.waveform,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'duration': duration.inMilliseconds,
    'createdAt': createdAt.toIso8601String(),
    'waveform': waveform,
  };

  factory HSVoiceNote.fromJson(Map<String, dynamic> json) => HSVoiceNote(
    id: json['id'],
    url: json['url'],
    duration: Duration(milliseconds: json['duration']),
    createdAt: DateTime.parse(json['createdAt']),
    waveform: List<double>.from(json['waveform']),
  );
}
