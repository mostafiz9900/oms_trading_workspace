// To parse this JSON data, do
//
//     final companiesModel = companiesModelFromJson(jsonString);

import 'dart:convert';

CompaniesModel companiesModelFromJson(String str) =>
    CompaniesModel.fromJson(json.decode(str));

String companiesModelToJson(CompaniesModel data) => json.encode(data.toJson());

class CompaniesModel {
  final Fundamentals? fundamentals;
  final ShareHolding? shareHolding;
  final String? symbol;

  CompaniesModel({this.fundamentals, this.shareHolding, this.symbol});

  CompaniesModel copyWith({
    Fundamentals? fundamentals,
    ShareHolding? shareHolding,
    String? symbol,
  }) => CompaniesModel(
    fundamentals: fundamentals ?? this.fundamentals,
    shareHolding: shareHolding ?? this.shareHolding,
    symbol: symbol ?? this.symbol,
  );

  factory CompaniesModel.fromJson(Map<String, dynamic> json) => CompaniesModel(
    fundamentals: json["fundamentals"] == null
        ? null
        : Fundamentals.fromJson(json["fundamentals"]),
    shareHolding: json["share_holding"] == null
        ? null
        : ShareHolding.fromJson(json["share_holding"]),
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "fundamentals": fundamentals?.toJson(),
    "share_holding": shareHolding?.toJson(),
    "symbol": symbol,
  };
}

class Fundamentals {
  final double? authCap;
  final double? cashDividend;
  final String? category;
  final double? divYield;
  final double? dividend;
  final Eps? eps;
  final double? epsTtm;
  final double? faceValue;
  final String? lastAgm; // int? থেকে String? এ পরিবর্তন করা হয়েছে
  final double? marketCap;
  final double? nav;
  final Eps? nocfps;
  final double? paidUpCap;
  final double? peAudited;
  final double? peTrailing;
  final double? peTtm;
  final String? recordDate; // int? থেকে String? এ পরিবর্তন করা হয়েছে
  final String? sector;
  final double? stockDividend;
  final double? ttlShare;
  final String? yrEnd;

  Fundamentals({
    this.authCap,
    this.cashDividend,
    this.category,
    this.divYield,
    this.dividend,
    this.eps,
    this.epsTtm,
    this.faceValue,
    this.lastAgm,
    this.marketCap,
    this.nav,
    this.nocfps,
    this.paidUpCap,
    this.peAudited,
    this.peTrailing,
    this.peTtm,
    this.recordDate,
    this.sector,
    this.stockDividend,
    this.ttlShare,
    this.yrEnd,
  });

  Fundamentals copyWith({
    double? authCap,
    double? cashDividend,
    String? category,
    double? divYield,
    double? dividend,
    Eps? eps,
    double? epsTtm,
    double? faceValue,
    String? lastAgm,
    double? marketCap,
    double? nav,
    Eps? nocfps,
    double? paidUpCap,
    double? peAudited,
    double? peTrailing,
    double? peTtm,
    String? recordDate,
    String? sector,
    double? stockDividend,
    double? ttlShare,
    String? yrEnd,
  }) => Fundamentals(
    authCap: authCap ?? this.authCap,
    cashDividend: cashDividend ?? this.cashDividend,
    category: category ?? this.category,
    divYield: divYield ?? this.divYield,
    dividend: dividend ?? this.dividend,
    eps: eps ?? this.eps,
    epsTtm: epsTtm ?? this.epsTtm,
    faceValue: faceValue ?? this.faceValue,
    lastAgm: lastAgm ?? this.lastAgm,
    marketCap: marketCap ?? this.marketCap,
    nav: nav ?? this.nav,
    nocfps: nocfps ?? this.nocfps,
    paidUpCap: paidUpCap ?? this.paidUpCap,
    peAudited: peAudited ?? this.peAudited,
    peTrailing: peTrailing ?? this.peTrailing,
    peTtm: peTtm ?? this.peTtm,
    recordDate: recordDate ?? this.recordDate,
    sector: sector ?? this.sector,
    stockDividend: stockDividend ?? this.stockDividend,
    ttlShare: ttlShare ?? this.ttlShare,
    yrEnd: yrEnd ?? this.yrEnd,
  );

  factory Fundamentals.fromJson(Map<String, dynamic> json) => Fundamentals(
    authCap: (json["auth_cap"] as num?)?.toDouble(),
    cashDividend: (json["cash_dividend"] as num?)?.toDouble(),
    category: json["category"],
    divYield: (json["div_yield"] as num?)?.toDouble(),
    dividend: (json["dividend"] as num?)?.toDouble(),
    eps: json["eps"] == null ? null : Eps.fromJson(json["eps"]),
    epsTtm: (json["eps_ttm"] as num?)?.toDouble(),
    faceValue: (json["face_value"] as num?)?.toDouble(),
    lastAgm: json["last_agm"].toString(),
    marketCap: (json["market_cap"] as num?)?.toDouble(),
    nav: (json["nav"] as num?)?.toDouble(),
    nocfps: json["nocfps"] == null ? null : Eps.fromJson(json["nocfps"]),
    paidUpCap: (json["paid_up_cap"] as num?)?.toDouble(),
    peAudited: (json["pe_audited"] as num?)?.toDouble(),
    peTrailing: (json["pe_trailing"] as num?)?.toDouble(),
    peTtm: (json["pe_ttm"] as num?)?.toDouble(),
    recordDate: json["record_date"].toString(),
    sector: json["sector"],
    stockDividend: (json["stock_dividend"] as num?)?.toDouble(),
    ttlShare: (json["ttl_share"] as num?)?.toDouble(),
    yrEnd: json["yr_end"],
  );

  Map<String, dynamic> toJson() => {
    "auth_cap": authCap,
    "cash_dividend": cashDividend,
    "category": category,
    "div_yield": divYield,
    "dividend": dividend,
    "eps": eps?.toJson(),
    "eps_ttm": epsTtm,
    "face_value": faceValue,
    "last_agm": lastAgm,
    "market_cap": marketCap,
    "nav": nav,
    "nocfps": nocfps?.toJson(),
    "paid_up_cap": paidUpCap,
    "pe_audited": peAudited,
    "pe_trailing": peTrailing,
    "pe_ttm": peTtm,
    "record_date": recordDate,
    "sector": sector,
    "stock_dividend": stockDividend,
    "ttl_share": ttlShare,
    "yr_end": yrEnd,
  };
}

class Eps {
  final double? ann;
  final double? q1;
  final double? q2;
  final double? q3;

  Eps({this.ann, this.q1, this.q2, this.q3});

  Eps copyWith({double? ann, double? q1, double? q2, double? q3}) => Eps(
    ann: ann ?? this.ann,
    q1: q1 ?? this.q1,
    q2: q2 ?? this.q2,
    q3: q3 ?? this.q3,
  );

  factory Eps.fromJson(Map<String, dynamic> json) => Eps(
    ann: (json["ann"] as num?)?.toDouble(),
    q1: (json["q1"] as num?)?.toDouble(),
    q2: (json["q2"] as num?)?.toDouble(),
    q3: (json["q3"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {"ann": ann, "q1": q1, "q2": q2, "q3": q3};
}

class ShareHolding {
  final double? director;
  final double? foreign;
  final double? govt;
  final double? institute;
  final double? public;

  ShareHolding({
    this.director,
    this.foreign,
    this.govt,
    this.institute,
    this.public,
  });

  ShareHolding copyWith({
    double? director,
    double? foreign,
    double? govt,
    double? institute,
    double? public,
  }) => ShareHolding(
    director: director ?? this.director,
    foreign: foreign ?? this.foreign,
    govt: govt ?? this.govt,
    institute: institute ?? this.institute,
    public: public ?? this.public,
  );

  factory ShareHolding.fromJson(Map<String, dynamic> json) => ShareHolding(
    director: (json["director"] as num?)?.toDouble(),
    foreign: (json["foreign"] as num?)?.toDouble(),
    govt: (json["govt"] as num?)?.toDouble(),
    institute: (json["institute"] as num?)?.toDouble(),
    public: (json["public"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "director": director,
    "foreign": foreign,
    "govt": govt,
    "institute": institute,
    "public": public,
  };
}
