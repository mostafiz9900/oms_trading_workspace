// To parse this JSON data, do
//
//     final indexModel = indexModelFromJson(jsonString);

import 'dart:convert';

List<IndexModel> indexModelFromJson(String str) =>
    List<IndexModel>.from(json.decode(str).map((x) => IndexModel.fromJson(x)));

String indexModelToJson(List<IndexModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IndexModel {
  int? ob;
  final String? sn;
  double? civ;
  double? ivd;
  double? ip;
  int? u;
  int? d;
  int? uc;
  int? nt;
  int? tds;
  int? v;
  double? vl;

  IndexModel({
    this.ob,
    required this.sn,
    this.civ,
    this.ivd,
    this.ip,
    this.u,
    this.d,
    this.uc,
    this.nt,
    this.tds,
    this.v,
    this.vl,
  });

  IndexModel copyWith({
    int? ob,
    String? sn,
    double? civ,
    double? ivd,
    double? ip,
    int? u,
    int? d,
    int? uc,
    int? nt,
    int? tds,
    int? v,
    double? vl,
  }) => IndexModel(
    ob: ob ?? this.ob,
    sn: sn ?? this.sn,
    civ: civ ?? this.civ,
    ivd: ivd ?? this.ivd,
    ip: ip ?? this.ip,
    u: u ?? this.u,
    d: d ?? this.d,
    uc: uc ?? this.uc,
    nt: nt ?? this.nt,
    tds: tds ?? this.tds,
    v: v ?? this.v,
    vl: vl ?? this.vl,
  );
  factory IndexModel.empty() => IndexModel(sn: '', v: 0);
  factory IndexModel.fromJson(Map<String, dynamic> json) {
    try {
      return IndexModel(
        ob: json["ob"] as int?,
        sn: json["sn"] as String?,
        civ: (json["civ"] as num?)?.toDouble(),
        ivd: (json["ivd"] as num?)?.toDouble(),
        ip: (json["ip"] as num?)?.toDouble(),
        u: json["u"] as int?,
        d: json["d"] as int?,
        uc: json["uc"] as int?,
        nt: json["nt"] as int?,
        tds: json["tds"] as int?,
        v: json["v"] as int?,
        vl: (json["vl"] as num?)?.toDouble(),
      );
    } catch (e) {
      throw FormatException('Failed to parse IndexModel: $e');
    }
  }

  /// Update only values without changing name
  void updateValues(IndexModel other) {
    ob = other.ob;
    civ = other.civ;
    ivd = other.ivd;
    ip = other.ip;
    u = other.u;
    d = other.d;
    uc = other.uc;
    nt = other.nt;
    tds = other.tds;
    v = other.v;
    vl = other.vl;
  }

  Map<String, dynamic> toJson() => {
    "ob": ob,
    "sn": sn,
    "civ": civ,
    "ivd": ivd,
    "ip": ip,
    "u": u,
    "d": d,
    "uc": uc,
    "nt": nt,
    "tds": tds,
    "v": v,
    "vl": vl,
  };

  IndexModel mergePartialUpdate(Map<String, dynamic> json) {
    return copyWith(
      ob: json.containsKey('ob') ? json['ob'] as int? : ob,
      sn: json.containsKey('sn') ? json['sn'] as String? : sn,
      civ: json.containsKey('civ') ? (json['civ'] as num?)?.toDouble() : civ,
      ivd: json.containsKey('ivd') ? (json['ivd'] as num?)?.toDouble() : ivd,
      ip: json.containsKey('ip') ? (json['ip'] as num?)?.toDouble() : ip,
      u: json.containsKey('u') ? json['u'] as int? : u,
      d: json.containsKey('d') ? json['d'] as int? : d,
      uc: json.containsKey('uc') ? json['uc'] as int? : uc,
      nt: json.containsKey('nt') ? json['nt'] as int? : nt,
      tds: json.containsKey('tds') ? json['tds'] as int? : tds,
      v: json.containsKey('v') ? json['v'] as int? : v,
      vl: json.containsKey('vl') ? (json['vl'] as num?)?.toDouble() : vl,
    );
  }
}
