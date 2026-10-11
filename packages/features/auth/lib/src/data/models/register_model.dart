// To parse this JSON data, do
//
//     final registerModel = registerModelFromMap(jsonString);

import 'dart:convert';

RegisterModel registerModelFromMap(dynamic str) =>
    RegisterModel.fromMap((str as dynamic));

String registerModelToMap(RegisterModel data) => json.encode(data.toMap());

class RegisterModel {
  String? boId;
  List<NameList>? nameList;

  RegisterModel({this.boId, this.nameList});

  factory RegisterModel.fromMap(Map<String, dynamic> json) => RegisterModel(
    boId: json["bo_id"],
    nameList: json["name_list"] == null
        ? []
        : List<NameList>.from(
            json["name_list"]!.map((x) => NameList.fromMap(x)),
          ),
  );

  Map<String, dynamic> toMap() => {
    "bo_id": boId,
    "name_list": nameList == null
        ? []
        : List<dynamic>.from(nameList!.map((x) => x.toMap())),
  };
}

class NameList {
  String? name;
  String? fathersName;

  NameList({this.name, this.fathersName});

  factory NameList.fromMap(Map<String, dynamic> json) =>
      NameList(name: json["name"], fathersName: json["fathers_name"]);

  Map<String, dynamic> toMap() => {"name": name, "fathers_name": fathersName};
}
