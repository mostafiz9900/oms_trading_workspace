// To parse this JSON data, do
//
//     final companiesModel = companiesModelFromJson(jsonString);

import 'dart:convert';

CompaniesModel companiesModelFromJson(String str) =>
    CompaniesModel.fromJson(json.decode(str));

String companiesModelToJson(CompaniesModel data) => json.encode(data.toJson());

int? _intField(Map<String, dynamic> json, String key, String modelField) {
  final value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  if (value is double && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException(
    'CompaniesModel.$modelField (JSON "$key") expected an integer, '
    'got ${value.runtimeType}: $value. '
    'See packages/shared/oms_shared/lib/app/data/models/response/companies_model.dart:15',
  );
}

double? _doubleField(Map<String, dynamic> json, String key, String modelField) {
  final value = json[key];
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException(
    'CompaniesModel.$modelField (JSON "$key") expected a number, '
    'got ${value.runtimeType}: $value. '
    'See packages/shared/oms_shared/lib/app/data/models/response/companies_model.dart:33',
  );
}

DateTime? _dateField(Map<String, dynamic> json, String key, String modelField) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException(
      'CompaniesModel.$modelField (JSON "$key") expected a date string, '
      'got ${value.runtimeType}: $value. '
      'See packages/shared/oms_shared/lib/app/data/models/response/companies_model.dart:50',
    );
  }

  final normalizedValue = value.trim();
  if (normalizedValue.isEmpty ||
      const {
        'n/a',
        'na',
        'null',
        '-',
        '--',
      }.contains(normalizedValue.toLowerCase())) {
    return null;
  }

  final isoDate = DateTime.tryParse(normalizedValue);
  if (isoDate != null) return isoDate;

  final dayFirst = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$')
      .firstMatch(normalizedValue);
  if (dayFirst != null) {
    final day = int.parse(dayFirst.group(1)!);
    final month = int.parse(dayFirst.group(2)!);
    final year = int.parse(dayFirst.group(3)!);
    final parsed = DateTime(year, month, day);
    if (parsed.year == year && parsed.month == month && parsed.day == day) {
      return parsed;
    }
  }

  throw FormatException(
    'CompaniesModel.$modelField (JSON "$key") has invalid date: "$value". '
    'Expected ISO date or dd-MM-yyyy. '
    'See packages/shared/oms_shared/lib/app/data/models/response/companies_model.dart:50',
  );
}

class CompaniesModel {
  final String? companyName;
  final Fundamentals? fundamentals;
  final Map<String, double>? growth;
  final ShareHolding? shareHolding;
  final String? symbol;

  CompaniesModel({
    this.companyName,
    this.fundamentals,
    this.growth,
    this.shareHolding,
    this.symbol,
  });

  CompaniesModel copyWith({
    String? companyName,
    Fundamentals? fundamentals,
    Map<String, double>? growth,
    ShareHolding? shareHolding,
    String? symbol,
  }) => CompaniesModel(
    companyName: companyName ?? this.companyName,
    fundamentals: fundamentals ?? this.fundamentals,
    growth: growth ?? this.growth,
    shareHolding: shareHolding ?? this.shareHolding,
    symbol: symbol ?? this.symbol,
  );

  factory CompaniesModel.fromJson(Map<String, dynamic> json) => CompaniesModel(
    companyName: json["company_name"],
    fundamentals: json["fundamentals"] == null
        ? null
        : Fundamentals.fromJson(json["fundamentals"]),
    growth: Map.from(json["growth"]!)
        .map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
    shareHolding: json["share_holding"] == null
        ? null
        : ShareHolding.fromJson(json["share_holding"]),
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "company_name": companyName,
    "fundamentals": fundamentals?.toJson(),
    "growth": Map.from(growth!).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "share_holding": shareHolding?.toJson(),
    "symbol": symbol,
  };
}

class Fundamentals {
  final int? annYear;
  final int? authCap;
  final double? cashDividend;
  final String? category;
  final int? divYear;
  final double? divYield;
  final double? dividend;
  final Eps? eps;
  final double? epsTtm;
  final int? epsYear;
  final int? faceValue;
  final String? lastAgm;
  final double? marketCap;
  final double? nav;
  final Eps? nocfps;
  final int? nocfpsYear;
  final double? paidUpCap;
  final double? peAudited;
  final double? peTrailing;
  final double? peTtm;
  final int? q1Year;
  final int? q2Year;
  final int? q3Year;
  final DateTime? recordDate;
  final String? sector;
  final double? stockDividend;
  final double? ttlShare;
  final Years? years;
  final String? yrEnd;

  Fundamentals({
    this.annYear,
    this.authCap,
    this.cashDividend,
    this.category,
    this.divYear,
    this.divYield,
    this.dividend,
    this.eps,
    this.epsTtm,
    this.epsYear,
    this.faceValue,
    this.lastAgm,
    this.marketCap,
    this.nav,
    this.nocfps,
    this.nocfpsYear,
    this.paidUpCap,
    this.peAudited,
    this.peTrailing,
    this.peTtm,
    this.q1Year,
    this.q2Year,
    this.q3Year,
    this.recordDate,
    this.sector,
    this.stockDividend,
    this.ttlShare,
    this.years,
    this.yrEnd,
  });

  Fundamentals copyWith({
    int? annYear,
    int? authCap,
    double? cashDividend,
    String? category,
    int? divYear,
    double? divYield,
    double? dividend,
    Eps? eps,
    double? epsTtm,
    int? epsYear,
    int? faceValue,
    String? lastAgm,
    double? marketCap,
    double? nav,
    Eps? nocfps,
    int? nocfpsYear,
    double? paidUpCap,
    double? peAudited,
    double? peTrailing,
    double? peTtm,
    int? q1Year,
    int? q2Year,
    int? q3Year,
    DateTime? recordDate,
    String? sector,
    double? stockDividend,
    double? ttlShare,
    Years? years,
    String? yrEnd,
  }) => Fundamentals(
    annYear: annYear ?? this.annYear,
    authCap: authCap ?? this.authCap,
    cashDividend: cashDividend ?? this.cashDividend,
    category: category ?? this.category,
    divYear: divYear ?? this.divYear,
    divYield: divYield ?? this.divYield,
    dividend: dividend ?? this.dividend,
    eps: eps ?? this.eps,
    epsTtm: epsTtm ?? this.epsTtm,
    epsYear: epsYear ?? this.epsYear,
    faceValue: faceValue ?? this.faceValue,
    lastAgm: lastAgm ?? this.lastAgm,
    marketCap: marketCap ?? this.marketCap,
    nav: nav ?? this.nav,
    nocfps: nocfps ?? this.nocfps,
    nocfpsYear: nocfpsYear ?? this.nocfpsYear,
    paidUpCap: paidUpCap ?? this.paidUpCap,
    peAudited: peAudited ?? this.peAudited,
    peTrailing: peTrailing ?? this.peTrailing,
    peTtm: peTtm ?? this.peTtm,
    q1Year: q1Year ?? this.q1Year,
    q2Year: q2Year ?? this.q2Year,
    q3Year: q3Year ?? this.q3Year,
    recordDate: recordDate ?? this.recordDate,
    sector: sector ?? this.sector,
    stockDividend: stockDividend ?? this.stockDividend,
    ttlShare: ttlShare ?? this.ttlShare,
    years: years ?? this.years,
    yrEnd: yrEnd ?? this.yrEnd,
  );

  factory Fundamentals.fromJson(Map<String, dynamic> json) => Fundamentals(
    annYear: _intField(json, "ann_year", "fundamentals.annYear"),
    authCap: _intField(json, "auth_cap", "fundamentals.authCap"),
    cashDividend: _doubleField(
      json,
      "cash_dividend",
      "fundamentals.cashDividend",
    ),
    category: json["category"],
    divYear: _intField(json, "div_year", "fundamentals.divYear"),
    divYield: json["div_yield"]?.toDouble(),
    dividend: json["dividend"]?.toDouble(),
    eps: json["eps"] == null ? null : Eps.fromJson(json["eps"]),
    epsTtm: json["eps_ttm"]?.toDouble(),
    epsYear: _intField(json, "eps_year", "fundamentals.epsYear"),
    faceValue: _intField(json, "face_value", "fundamentals.faceValue"),
    lastAgm: json["last_agm"],
    marketCap: _doubleField(json, "market_cap", "fundamentals.marketCap"),
    nav: json["nav"]?.toDouble(),
    nocfps: json["nocfps"] == null ? null : Eps.fromJson(json["nocfps"]),
    nocfpsYear: _intField(json, "nocfps_year", "fundamentals.nocfpsYear"),
    paidUpCap: json["paid_up_cap"]?.toDouble(),
    peAudited: json["pe_audited"]?.toDouble(),
    peTrailing: json["pe_trailing"]?.toDouble(),
    peTtm: json["pe_ttm"]?.toDouble(),
    q1Year: _intField(json, "q1_year", "fundamentals.q1Year"),
    q2Year: _intField(json, "q2_year", "fundamentals.q2Year"),
    q3Year: _intField(json, "q3_year", "fundamentals.q3Year"),
    recordDate: _dateField(json, "record_date", "fundamentals.recordDate"),
    sector: json["sector"],
    stockDividend: json["stock_dividend"]?.toDouble(),
    ttlShare: json["ttl_share"]?.toDouble(),
    years: json["years"] == null ? null : Years.fromJson(json["years"]),
    yrEnd: json["yr_end"],
  );

  Map<String, dynamic> toJson() => {
    "ann_year": annYear,
    "auth_cap": authCap,
    "cash_dividend": cashDividend,
    "category": category,
    "div_year": divYear,
    "div_yield": divYield,
    "dividend": dividend,
    "eps": eps?.toJson(),
    "eps_ttm": epsTtm,
    "eps_year": epsYear,
    "face_value": faceValue,
    "last_agm":
        lastAgm, // Store as string; parsing to DateTime is handled in fromJson
    "market_cap": marketCap,
    "nav": nav,
    "nocfps": nocfps?.toJson(),
    "nocfps_year": nocfpsYear,
    "paid_up_cap": paidUpCap,
    "pe_audited": peAudited,
    "pe_trailing": peTrailing,
    "pe_ttm": peTtm,
    "q1_year": q1Year,
    "q2_year": q2Year,
    "q3_year": q3Year,
    "record_date": recordDate == null
        ? null
        : "${recordDate!.year.toString().padLeft(4, '0')}-${recordDate!.month.toString().padLeft(2, '0')}-${recordDate!.day.toString().padLeft(2, '0')}",
    "sector": sector,
    "stock_dividend": stockDividend,
    "ttl_share": ttlShare,
    "years": years?.toJson(),
    "yr_end": yrEnd,
  };
}

class Eps {
  final double? ann;
  final int? annYear;
  final Details? details;
  final double? q1;
  final int? q1Year;
  final double? q2;
  final int? q2Year;
  final double? q3;
  final int? q3Year;

  Eps({
    this.ann,
    this.annYear,
    this.details,
    this.q1,
    this.q1Year,
    this.q2,
    this.q2Year,
    this.q3,
    this.q3Year,
  });

  Eps copyWith({
    double? ann,
    int? annYear,
    Details? details,
    double? q1,
    int? q1Year,
    double? q2,
    int? q2Year,
    double? q3,
    int? q3Year,
  }) => Eps(
    ann: ann ?? this.ann,
    annYear: annYear ?? this.annYear,
    details: details ?? this.details,
    q1: q1 ?? this.q1,
    q1Year: q1Year ?? this.q1Year,
    q2: q2 ?? this.q2,
    q2Year: q2Year ?? this.q2Year,
    q3: q3 ?? this.q3,
    q3Year: q3Year ?? this.q3Year,
  );

  factory Eps.fromJson(Map<String, dynamic> json) => Eps(
    ann: json["ann"]?.toDouble(),
    annYear: _intField(json, "ann_year", "fundamentals.eps.annYear"),
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
    q1: json["q1"]?.toDouble(),
    q1Year: _intField(json, "q1_year", "fundamentals.eps.q1Year"),
    q2: json["q2"]?.toDouble(),
    q2Year: _intField(json, "q2_year", "fundamentals.eps.q2Year"),
    q3: json["q3"]?.toDouble(),
    q3Year: _intField(json, "q3_year", "fundamentals.eps.q3Year"),
  );

  Map<String, dynamic> toJson() => {
    "ann": ann,
    "ann_year": annYear,
    "details": details?.toJson(),
    "q1": q1,
    "q1_year": q1Year,
    "q2": q2,
    "q2_year": q2Year,
    "q3": q3,
    "q3_year": q3Year,
  };
}

class Details {
  final Ann? ann;
  final Ann? q1;
  final Ann? q2;
  final Ann? q3;

  Details({this.ann, this.q1, this.q2, this.q3});

  Details copyWith({Ann? ann, Ann? q1, Ann? q2, Ann? q3}) => Details(
    ann: ann ?? this.ann,
    q1: q1 ?? this.q1,
    q2: q2 ?? this.q2,
    q3: q3 ?? this.q3,
  );

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    ann: json["ann"] == null ? null : Ann.fromJson(json["ann"]),
    q1: json["q1"] == null ? null : Ann.fromJson(json["q1"]),
    q2: json["q2"] == null ? null : Ann.fromJson(json["q2"]),
    q3: json["q3"] == null ? null : Ann.fromJson(json["q3"]),
  );

  Map<String, dynamic> toJson() => {
    "ann": ann?.toJson(),
    "q1": q1?.toJson(),
    "q2": q2?.toJson(),
    "q3": q3?.toJson(),
  };
}

class Ann {
  final double? diff;
  final double? val;
  final int? year;

  Ann({this.diff, this.val, this.year});

  Ann copyWith({double? diff, double? val, int? year}) => Ann(
    diff: diff ?? this.diff,
    val: val ?? this.val,
    year: year ?? this.year,
  );

  factory Ann.fromJson(Map<String, dynamic> json) => Ann(
    diff: json["diff"]?.toDouble(),
    val: json["val"]?.toDouble(),
    year: _intField(json, "year", "fundamentals.eps.details.year"),
  );

  Map<String, dynamic> toJson() => {"diff": diff, "val": val, "year": year};
}

class Years {
  final int? ann;
  final int? dividend;
  final int? nocfpsAnn;
  final int? q1;
  final int? q2;
  final int? q3;

  Years({this.ann, this.dividend, this.nocfpsAnn, this.q1, this.q2, this.q3});

  Years copyWith({
    int? ann,
    int? dividend,
    int? nocfpsAnn,
    int? q1,
    int? q2,
    int? q3,
  }) => Years(
    ann: ann ?? this.ann,
    dividend: dividend ?? this.dividend,
    nocfpsAnn: nocfpsAnn ?? this.nocfpsAnn,
    q1: q1 ?? this.q1,
    q2: q2 ?? this.q2,
    q3: q3 ?? this.q3,
  );

  factory Years.fromJson(Map<String, dynamic> json) => Years(
    ann: _intField(json, "ann", "fundamentals.years.ann"),
    dividend: _intField(json, "dividend", "fundamentals.years.dividend"),
    nocfpsAnn: _intField(json, "nocfps_ann", "fundamentals.years.nocfpsAnn"),
    q1: _intField(json, "q1", "fundamentals.years.q1"),
    q2: _intField(json, "q2", "fundamentals.years.q2"),
    q3: _intField(json, "q3", "fundamentals.years.q3"),
  );

  Map<String, dynamic> toJson() => {
    "ann": ann,
    "dividend": dividend,
    "nocfps_ann": nocfpsAnn,
    "q1": q1,
    "q2": q2,
    "q3": q3,
  };
}

class ShareHolding {
  final String? asOnDate;
  final Changes? changes;
  final double? director;
  final double? foreign;
  final double? govt;
  final double? institute;
  final double? public;
  final Changes? sharesCount;
  final Changes? sharesCr;

  ShareHolding({
    this.asOnDate,
    this.changes,
    this.director,
    this.foreign,
    this.govt,
    this.institute,
    this.public,
    this.sharesCount,
    this.sharesCr,
  });

  ShareHolding copyWith({
    String? asOnDate,
    Changes? changes,
    double? director,
    double? foreign,
    double? govt,
    double? institute,
    double? public,
    Changes? sharesCount,
    Changes? sharesCr,
  }) => ShareHolding(
    asOnDate: asOnDate ?? this.asOnDate,
    changes: changes ?? this.changes,
    director: director ?? this.director,
    foreign: foreign ?? this.foreign,
    govt: govt ?? this.govt,
    institute: institute ?? this.institute,
    public: public ?? this.public,
    sharesCount: sharesCount ?? this.sharesCount,
    sharesCr: sharesCr ?? this.sharesCr,
  );

  factory ShareHolding.fromJson(Map<String, dynamic> json) => ShareHolding(
    asOnDate: json["as_on_date"],
    changes: json["changes"] == null ? null : Changes.fromJson(json["changes"]),
    director: json["director"]?.toDouble(),
    foreign: json["foreign"]?.toDouble(),
    govt: json["govt"]?.toDouble(),
    institute: json["institute"]?.toDouble(),
    public: json["public"]?.toDouble(),
    sharesCount: json["shares_count"] == null
        ? null
        : Changes.fromJson(json["shares_count"]),
    sharesCr: json["shares_cr"] == null
        ? null
        : Changes.fromJson(json["shares_cr"]),
  );

  Map<String, dynamic> toJson() => {
    "as_on_date": asOnDate,
    "changes": changes?.toJson(),
    "director": director,
    "foreign": foreign,
    "govt": govt,
    "institute": institute,
    "public": public,
    "shares_count": sharesCount?.toJson(),
    "shares_cr": sharesCr?.toJson(),
  };
}

class Changes {
  final double? director;
  final double? foreign;
  final double? govt;
  final double? institute;
  final double? public;

  Changes({
    this.director,
    this.foreign,
    this.govt,
    this.institute,
    this.public,
  });

  Changes copyWith({
    double? director,
    double? foreign,
    double? govt,
    double? institute,
    double? public,
  }) => Changes(
    director: director ?? this.director,
    foreign: foreign ?? this.foreign,
    govt: govt ?? this.govt,
    institute: institute ?? this.institute,
    public: public ?? this.public,
  );

  factory Changes.fromJson(Map<String, dynamic> json) => Changes(
    director: json["director"]?.toDouble(),
    foreign: json["foreign"]?.toDouble(),
    govt: json["govt"]?.toDouble(),
    institute: json["institute"]?.toDouble(),
    public: json["public"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "director": director,
    "foreign": foreign,
    "govt": govt,
    "institute": institute,
    "public": public,
  };
}
