// To parse this JSON data, do
//
//     final companiesModel = companiesModelFromMap(jsonString);

import 'dart:convert';

CompaniesModel companiesModelFromMap(dynamic str) =>
    CompaniesModel.fromMap(str as dynamic);

String companiesModelToMap(CompaniesModel data) => json.encode(data.toMap());

class CompaniesModel {
  final String? id;
  final Identifiers? identifiers;
  final Classification? classification;
  final CorporateActions? corporateActions;
  final Shareholding? shareholding;
  final Financials? financials;
  final MarketData? marketData;
  final CalculatedMetrics? calculatedMetrics;
  final Metadata? metadata;

  CompaniesModel({
    this.id,
    this.identifiers,
    this.classification,
    this.corporateActions,
    this.shareholding,
    this.financials,
    this.marketData,
    this.calculatedMetrics,
    this.metadata,
  });

  CompaniesModel copyWith({
    String? id,
    Identifiers? identifiers,
    Classification? classification,
    CorporateActions? corporateActions,
    Shareholding? shareholding,
    Financials? financials,
    MarketData? marketData,
    CalculatedMetrics? calculatedMetrics,
    Metadata? metadata,
  }) => CompaniesModel(
    id: id ?? this.id,
    identifiers: identifiers ?? this.identifiers,
    classification: classification ?? this.classification,
    corporateActions: corporateActions ?? this.corporateActions,
    shareholding: shareholding ?? this.shareholding,
    financials: financials ?? this.financials,
    marketData: marketData ?? this.marketData,
    calculatedMetrics: calculatedMetrics ?? this.calculatedMetrics,
    metadata: metadata ?? this.metadata,
  );

  factory CompaniesModel.fromMap(Map<String, dynamic> json) => CompaniesModel(
    id: json["_id"],
    identifiers: json["identifiers"] == null
        ? null
        : Identifiers.fromMap(json["identifiers"]),
    classification: json["classification"] == null
        ? null
        : Classification.fromMap(json["classification"]),
    corporateActions: json["corporate_actions"] == null
        ? null
        : CorporateActions.fromMap(json["corporate_actions"]),
    shareholding: json["shareholding"] == null
        ? null
        : Shareholding.fromMap(json["shareholding"]),
    financials: json["financials"] == null
        ? null
        : Financials.fromMap(json["financials"]),
    marketData: json["market_data"] == null
        ? null
        : MarketData.fromMap(json["market_data"]),
    calculatedMetrics: json["calculated_metrics"] == null
        ? null
        : CalculatedMetrics.fromMap(json["calculated_metrics"]),
    metadata: json["metadata"] == null
        ? null
        : Metadata.fromMap(json["metadata"]),
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "identifiers": identifiers?.toMap(),
    "classification": classification?.toMap(),
    "corporate_actions": corporateActions?.toMap(),
    "shareholding": shareholding?.toMap(),
    "financials": financials?.toMap(),
    "market_data": marketData?.toMap(),
    "calculated_metrics": calculatedMetrics?.toMap(),
    "metadata": metadata?.toMap(),
  };
}

class CalculatedMetrics {
  final double? marketCapTk;
  final double? marketCapMnTk;
  final String? marketCapCategory;
  final double? priceToBookRatio;
  final int? financialHealthScore;
  final String? healthCategory;
  final double? investmentScore;
  final String? investmentGrade;

  CalculatedMetrics({
    this.marketCapTk,
    this.marketCapMnTk,
    this.marketCapCategory,
    this.priceToBookRatio,
    this.financialHealthScore,
    this.healthCategory,
    this.investmentScore,
    this.investmentGrade,
  });

  CalculatedMetrics copyWith({
    double? marketCapTk,
    double? marketCapMnTk,
    String? marketCapCategory,
    double? priceToBookRatio,
    int? financialHealthScore,
    String? healthCategory,
    double? investmentScore,
    String? investmentGrade,
  }) => CalculatedMetrics(
    marketCapTk: marketCapTk ?? this.marketCapTk,
    marketCapMnTk: marketCapMnTk ?? this.marketCapMnTk,
    marketCapCategory: marketCapCategory ?? this.marketCapCategory,
    priceToBookRatio: priceToBookRatio ?? this.priceToBookRatio,
    financialHealthScore: financialHealthScore ?? this.financialHealthScore,
    healthCategory: healthCategory ?? this.healthCategory,
    investmentScore: investmentScore ?? this.investmentScore,
    investmentGrade: investmentGrade ?? this.investmentGrade,
  );

  factory CalculatedMetrics.fromMap(Map<String, dynamic> json) =>
      CalculatedMetrics(
        marketCapTk: json["market_cap_tk"]?.toDouble(),
        marketCapMnTk: json["market_cap_mn_tk"]?.toDouble(),
        marketCapCategory: json["market_cap_category"],
        priceToBookRatio: json["price_to_book_ratio"]?.toDouble(),
        financialHealthScore: json["financial_health_score"],
        healthCategory: json["health_category"],
        investmentScore: json["investment_score"]?.toDouble(),
        investmentGrade: json["investment_grade"],
      );

  Map<String, dynamic> toMap() => {
    "market_cap_tk": marketCapTk,
    "market_cap_mn_tk": marketCapMnTk,
    "market_cap_category": marketCapCategory,
    "price_to_book_ratio": priceToBookRatio,
    "financial_health_score": financialHealthScore,
    "health_category": healthCategory,
    "investment_score": investmentScore,
    "investment_grade": investmentGrade,
  };
}

class Classification {
  final String? sector;
  final String? marketCategory;
  final bool? isMainBoard;

  Classification({this.sector, this.marketCategory, this.isMainBoard});

  Classification copyWith({
    String? sector,
    String? marketCategory,
    bool? isMainBoard,
  }) => Classification(
    sector: sector ?? this.sector,
    marketCategory: marketCategory ?? this.marketCategory,
    isMainBoard: isMainBoard ?? this.isMainBoard,
  );

  factory Classification.fromMap(Map<String, dynamic> json) => Classification(
    sector: json["sector"],
    marketCategory: json["market_category"],
    isMainBoard: json["is_main_board"],
  );

  Map<String, dynamic> toMap() => {
    "sector": sector,
    "market_category": marketCategory,
    "is_main_board": isMainBoard,
  };
}

class CorporateActions {
  final int? listingYear;
  final String? financialYearEnd;
  final int? reportingYear;
  final int? financialYear;

  CorporateActions({
    this.listingYear,
    this.financialYearEnd,
    this.reportingYear,
    this.financialYear,
  });

  CorporateActions copyWith({
    int? listingYear,
    String? financialYearEnd,
    int? reportingYear,
    int? financialYear,
  }) => CorporateActions(
    listingYear: listingYear ?? this.listingYear,
    financialYearEnd: financialYearEnd ?? this.financialYearEnd,
    reportingYear: reportingYear ?? this.reportingYear,
    financialYear: financialYear ?? this.financialYear,
  );

  factory CorporateActions.fromMap(Map<String, dynamic> json) =>
      CorporateActions(
        listingYear: json["listing_year"],
        financialYearEnd: json["financial_year_end"],
        reportingYear: json["reporting_year"],
        financialYear: json["financial_year"],
      );

  Map<String, dynamic> toMap() => {
    "listing_year": listingYear,
    "financial_year_end": financialYearEnd,
    "reporting_year": reportingYear,
    "financial_year": financialYear,
  };
}

class Financials {
  final ReservesSurplus? reservesSurplus;
  final PerShareMetrics? perShareMetrics;
  final Profitability? profitability;

  Financials({this.reservesSurplus, this.perShareMetrics, this.profitability});

  Financials copyWith({
    ReservesSurplus? reservesSurplus,
    PerShareMetrics? perShareMetrics,
    Profitability? profitability,
  }) => Financials(
    reservesSurplus: reservesSurplus ?? this.reservesSurplus,
    perShareMetrics: perShareMetrics ?? this.perShareMetrics,
    profitability: profitability ?? this.profitability,
  );

  factory Financials.fromMap(Map<String, dynamic> json) => Financials(
    reservesSurplus: json["reserves_surplus"] == null
        ? null
        : ReservesSurplus.fromMap(json["reserves_surplus"]),
    perShareMetrics: json["per_share_metrics"] == null
        ? null
        : PerShareMetrics.fromMap(json["per_share_metrics"]),
    profitability: json["profitability"] == null
        ? null
        : Profitability.fromMap(json["profitability"]),
  );

  Map<String, dynamic> toMap() => {
    "reserves_surplus": reservesSurplus?.toMap(),
    "per_share_metrics": perShareMetrics?.toMap(),
    "profitability": profitability?.toMap(),
  };
}

class PerShareMetrics {
  final double? navTk;
  final double? epsTk;

  PerShareMetrics({this.navTk, this.epsTk});

  PerShareMetrics copyWith({double? navTk, double? epsTk}) =>
      PerShareMetrics(navTk: navTk ?? this.navTk, epsTk: epsTk ?? this.epsTk);

  factory PerShareMetrics.fromMap(Map<String, dynamic> json) => PerShareMetrics(
    navTk: json["nav_tk"]?.toDouble(),
    epsTk: json["eps_tk"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {"nav_tk": navTk, "eps_tk": epsTk};
}

class Profitability {
  final bool? isProfitable;
  final String? epsCategory;

  Profitability({this.isProfitable, this.epsCategory});

  Profitability copyWith({bool? isProfitable, String? epsCategory}) =>
      Profitability(
        isProfitable: isProfitable ?? this.isProfitable,
        epsCategory: epsCategory ?? this.epsCategory,
      );

  factory Profitability.fromMap(Map<String, dynamic> json) => Profitability(
    isProfitable: json["is_profitable"],
    epsCategory: json["eps_category"],
  );

  Map<String, dynamic> toMap() => {
    "is_profitable": isProfitable,
    "eps_category": epsCategory,
  };
}

class ReservesSurplus {
  final double? valueMnTk;
  final String? trend;

  ReservesSurplus({this.valueMnTk, this.trend});

  ReservesSurplus copyWith({double? valueMnTk, String? trend}) =>
      ReservesSurplus(
        valueMnTk: valueMnTk ?? this.valueMnTk,
        trend: trend ?? this.trend,
      );

  factory ReservesSurplus.fromMap(Map<String, dynamic> json) => ReservesSurplus(
    valueMnTk: json["value_mn_tk"]?.toDouble(),
    trend: json["trend"],
  );

  Map<String, dynamic> toMap() => {"value_mn_tk": valueMnTk, "trend": trend};
}

class Identifiers {
  final String? tradingSymbol;
  final int? securityCode;
  final String? companyName;
  final String? searchableName;

  Identifiers({
    this.tradingSymbol,
    this.securityCode,
    this.companyName,
    this.searchableName,
  });

  Identifiers copyWith({
    String? tradingSymbol,
    int? securityCode,
    String? companyName,
    String? searchableName,
  }) => Identifiers(
    tradingSymbol: tradingSymbol ?? this.tradingSymbol,
    securityCode: securityCode ?? this.securityCode,
    companyName: companyName ?? this.companyName,
    searchableName: searchableName ?? this.searchableName,
  );

  factory Identifiers.fromMap(Map<String, dynamic> json) => Identifiers(
    tradingSymbol: json["trading_symbol"],
    securityCode: json["security_code"],
    companyName: json["company_name"],
    searchableName: json["searchable_name"],
  );

  Map<String, dynamic> toMap() => {
    "trading_symbol": tradingSymbol,
    "security_code": securityCode,
    "company_name": companyName,
    "searchable_name": searchableName,
  };
}

class MarketData {
  final PriceRange? priceRange;
  final Valuation? valuation;

  MarketData({this.priceRange, this.valuation});

  MarketData copyWith({PriceRange? priceRange, Valuation? valuation}) =>
      MarketData(
        priceRange: priceRange ?? this.priceRange,
        valuation: valuation ?? this.valuation,
      );

  factory MarketData.fromMap(Map<String, dynamic> json) => MarketData(
    priceRange: json["price_range"] == null
        ? null
        : PriceRange.fromMap(json["price_range"]),
    valuation: json["valuation"] == null
        ? null
        : Valuation.fromMap(json["valuation"]),
  );

  Map<String, dynamic> toMap() => {
    "price_range": priceRange?.toMap(),
    "valuation": valuation?.toMap(),
  };
}

class PriceRange {
  final double? yearHighTk;
  final double? yearLowTk;
  final double? rangePct;

  PriceRange({this.yearHighTk, this.yearLowTk, this.rangePct});

  PriceRange copyWith({
    double? yearHighTk,
    double? yearLowTk,
    double? rangePct,
  }) => PriceRange(
    yearHighTk: yearHighTk ?? this.yearHighTk,
    yearLowTk: yearLowTk ?? this.yearLowTk,
    rangePct: rangePct ?? this.rangePct,
  );

  factory PriceRange.fromMap(Map<String, dynamic> json) => PriceRange(
    yearHighTk: json["year_high_tk"]?.toDouble(),
    yearLowTk: json["year_low_tk"]?.toDouble(),
    rangePct: json["range_pct"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "year_high_tk": yearHighTk,
    "year_low_tk": yearLowTk,
    "range_pct": rangePct,
  };
}

class Valuation {
  final double? peRatio;
  final String? peCategory;
  final double? dividendYieldPct;
  final bool? isDividendPayer;

  Valuation({
    this.peRatio,
    this.peCategory,
    this.dividendYieldPct,
    this.isDividendPayer,
  });

  Valuation copyWith({
    double? peRatio,
    String? peCategory,
    double? dividendYieldPct,
    bool? isDividendPayer,
  }) => Valuation(
    peRatio: peRatio ?? this.peRatio,
    peCategory: peCategory ?? this.peCategory,
    dividendYieldPct: dividendYieldPct ?? this.dividendYieldPct,
    isDividendPayer: isDividendPayer ?? this.isDividendPayer,
  );

  factory Valuation.fromMap(Map<String, dynamic> json) => Valuation(
    peRatio: json["pe_ratio"]?.toDouble(),
    peCategory: json["pe_category"],
    dividendYieldPct: json["dividend_yield_pct"]?.toDouble(),
    isDividendPayer: json["is_dividend_payer"],
  );

  Map<String, dynamic> toMap() => {
    "pe_ratio": peRatio,
    "pe_category": peCategory,
    "dividend_yield_pct": dividendYieldPct,
    "is_dividend_payer": isDividendPayer,
  };
}

class Metadata {
  final String? dataSource;
  final DateTime? importTimestamp;
  final String? dataVersion;
  final String? recordType;

  Metadata({
    this.dataSource,
    this.importTimestamp,
    this.dataVersion,
    this.recordType,
  });

  Metadata copyWith({
    String? dataSource,
    DateTime? importTimestamp,
    String? dataVersion,
    String? recordType,
  }) => Metadata(
    dataSource: dataSource ?? this.dataSource,
    importTimestamp: importTimestamp ?? this.importTimestamp,
    dataVersion: dataVersion ?? this.dataVersion,
    recordType: recordType ?? this.recordType,
  );

  factory Metadata.fromMap(Map<String, dynamic> json) => Metadata(
    dataSource: json["data_source"],
    importTimestamp: json["import_timestamp"] == null
        ? null
        : DateTime.parse(json["import_timestamp"]),
    dataVersion: json["data_version"],
    recordType: json["record_type"],
  );

  Map<String, dynamic> toMap() => {
    "data_source": dataSource,
    "import_timestamp": importTimestamp?.toIso8601String(),
    "data_version": dataVersion,
    "record_type": recordType,
  };
}

class Shareholding {
  final double? totalShares;
  final double? totalSharesMillions;
  final OwnershipBreakdown? ownershipBreakdown;
  final double? freeFloatPct;
  final double? promoterHoldingPct;

  Shareholding({
    this.totalShares,
    this.totalSharesMillions,
    this.ownershipBreakdown,
    this.freeFloatPct,
    this.promoterHoldingPct,
  });

  Shareholding copyWith({
    double? totalShares,
    double? totalSharesMillions,
    OwnershipBreakdown? ownershipBreakdown,
    double? freeFloatPct,
    double? promoterHoldingPct,
  }) => Shareholding(
    totalShares: totalShares ?? this.totalShares,
    totalSharesMillions: totalSharesMillions ?? this.totalSharesMillions,
    ownershipBreakdown: ownershipBreakdown ?? this.ownershipBreakdown,
    freeFloatPct: freeFloatPct ?? this.freeFloatPct,
    promoterHoldingPct: promoterHoldingPct ?? this.promoterHoldingPct,
  );

  factory Shareholding.fromMap(Map<String, dynamic> json) => Shareholding(
    totalShares: json["total_shares"]?.toDouble(),
    totalSharesMillions: json["total_shares_millions"]?.toDouble(),
    ownershipBreakdown: json["ownership_breakdown"] == null
        ? null
        : OwnershipBreakdown.fromMap(json["ownership_breakdown"]),
    freeFloatPct: json["free_float_pct"]?.toDouble(),
    promoterHoldingPct: json["promoter_holding_pct"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "total_shares": totalShares,
    "total_shares_millions": totalSharesMillions,
    "ownership_breakdown": ownershipBreakdown?.toMap(),
    "free_float_pct": freeFloatPct,
    "promoter_holding_pct": promoterHoldingPct,
  };
}

class OwnershipBreakdown {
  final double? sponsorsDirectorsPct;
  final double? governmentPct;
  final double? institutionalPct;
  final double? foreignPct;
  final double? publicPct;

  OwnershipBreakdown({
    this.sponsorsDirectorsPct,
    this.governmentPct,
    this.institutionalPct,
    this.foreignPct,
    this.publicPct,
  });

  OwnershipBreakdown copyWith({
    double? sponsorsDirectorsPct,
    double? governmentPct,
    double? institutionalPct,
    double? foreignPct,
    double? publicPct,
  }) => OwnershipBreakdown(
    sponsorsDirectorsPct: sponsorsDirectorsPct ?? this.sponsorsDirectorsPct,
    governmentPct: governmentPct ?? this.governmentPct,
    institutionalPct: institutionalPct ?? this.institutionalPct,
    foreignPct: foreignPct ?? this.foreignPct,
    publicPct: publicPct ?? this.publicPct,
  );

  factory OwnershipBreakdown.fromMap(Map<String, dynamic> json) =>
      OwnershipBreakdown(
        sponsorsDirectorsPct: json["sponsors_directors_pct"]?.toDouble(),
        governmentPct: json["government_pct"]?.toDouble(),
        institutionalPct: json["institutional_pct"]?.toDouble(),
        foreignPct: json["foreign_pct"]?.toDouble(),
        publicPct: json["public_pct"]?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
    "sponsors_directors_pct": sponsorsDirectorsPct,
    "government_pct": governmentPct,
    "institutional_pct": institutionalPct,
    "foreign_pct": foreignPct,
    "public_pct": publicPct,
  };
}
