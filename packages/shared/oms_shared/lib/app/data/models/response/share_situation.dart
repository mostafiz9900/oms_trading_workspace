// To parse this JSON data, do


class ShareSituation {
  final int? id;
  final String? name;
  late bool? isActive;

  ShareSituation({this.id, this.name, this.isActive});

  ShareSituation copyWith({int? id, String? name, bool? isActive}) =>
      ShareSituation(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
      );

  factory ShareSituation.fromJson(Map<String, dynamic> json) => ShareSituation(
    id: json["id"],
    name: json["name"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isActive": isActive,
  };
}
