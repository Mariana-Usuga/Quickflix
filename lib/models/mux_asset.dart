class MuxAsset {
  final String id;
  final String? status;
  final double? duration;
  final String? createdAt;
  final List<PlaybackId>? playbackIds;
  final String? mp4Support;
  final Master? master;
  final String? passthrough;

  MuxAsset({
    required this.id,
    this.status,
    this.duration,
    this.createdAt,
    this.playbackIds,
    this.mp4Support,
    this.master,
    this.passthrough,
  });

  factory MuxAsset.fromJson(Map<String, dynamic> json) {
    return MuxAsset(
      id: json['id'] as String,
      status: json['status'] as String?,
      duration: json['duration'] != null ? (json['duration'] as num).toDouble() : null,
      createdAt: json['created_at'] as String?,
      playbackIds: json['playback_ids'] != null
          ? (json['playback_ids'] as List)
              .map((id) => PlaybackId.fromJson(id as Map<String, dynamic>))
              .toList()
          : null,
      mp4Support: json['mp4_support'] as String?,
      master: json['master'] != null
          ? Master.fromJson(json['master'] as Map<String, dynamic>)
          : null,
      passthrough: json['passthrough'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'duration': duration,
      'created_at': createdAt,
      'playback_ids': playbackIds?.map((id) => id.toJson()).toList(),
      'mp4_support': mp4Support,
      'master': master?.toJson(),
      'passthrough': passthrough,
    };
  }
}

class PlaybackId {
  final String id;
  final String? policy;

  PlaybackId({
    required this.id,
    this.policy,
  });

  factory PlaybackId.fromJson(Map<String, dynamic> json) {
    return PlaybackId(
      id: json['id'] as String,
      policy: json['policy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'policy': policy,
    };
  }
}

class Master {
  final String? status;
  final String? url;

  Master({
    this.status,
    this.url,
  });

  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      status: json['status'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'url': url,
    };
  }
}

class MuxAssetListResponse {
  final List<MuxAsset> data;
  final int? totalRowCount;

  MuxAssetListResponse({
    required this.data,
    this.totalRowCount,
  });

  factory MuxAssetListResponse.fromJson(Map<String, dynamic> json) {
    return MuxAssetListResponse(
      data: (json['data'] as List)
          .map((asset) => MuxAsset.fromJson(asset as Map<String, dynamic>))
          .toList(),
      totalRowCount: json['total_row_count'] as int?,
    );
  }
}



