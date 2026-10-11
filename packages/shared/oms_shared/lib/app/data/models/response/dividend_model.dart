// To parse this JSON data, do
//
//     final dividendModel = dividendModelFromMap(jsonString);

import 'dart:convert';

DividendModel dividendModelFromMap(String str) =>
    DividendModel.fromMap(json.decode(str));

String dividendModelToMap(DividendModel data) => json.encode(data.toMap());

class DividendModel {
  final String? id;
  final int? serialNumber;
  final int? companyCode;
  final String? tradingSymbol;
  final String? companyName;
  final FiscalYear? fiscalYear;
  final Dividend? dividend;
  final RecordDates? recordDates;
  final String? remarks;
  final DateTime? createdAt;
  final String? dataSource;
  final String? status;

  DividendModel({
    this.id,
    this.serialNumber,
    this.companyCode,
    this.tradingSymbol,
    this.companyName,
    this.fiscalYear,
    this.dividend,
    this.recordDates,
    this.remarks,
    this.createdAt,
    this.dataSource,
    this.status,
  });

  factory DividendModel.fromMap(Map<String, dynamic> json) => DividendModel(
    id: json["_id"],
    serialNumber: json["serial_number"],
    companyCode: json["company_code"],
    tradingSymbol: json["trading_symbol"],
    companyName: json["company_name"],
    fiscalYear: json["fiscal_year"] == null
        ? null
        : FiscalYear.fromMap(json["fiscal_year"]),
    dividend: json["dividend"] == null
        ? null
        : Dividend.fromMap(json["dividend"]),
    recordDates: json["record_dates"] == null
        ? null
        : RecordDates.fromMap(json["record_dates"]),
    remarks: json["remarks"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    dataSource: json["data_source"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "serial_number": serialNumber,
    "company_code": companyCode,
    "trading_symbol": tradingSymbol,
    "company_name": companyName,
    "fiscal_year": fiscalYear?.toMap(),
    "dividend": dividend?.toMap(),
    "record_dates": recordDates?.toMap(),
    "remarks": remarks,
    "created_at": createdAt?.toIso8601String(),
    "data_source": dataSource,
    "status": status,
  };
}

class Dividend {
  final double? cashPercent;
  final dynamic cashOriginalText;
  final bool? cashHasDetails;
  final dynamic stockPercent;
  final dynamic stockOriginalText;
  final bool? stockHasDetails;

  Dividend({
    this.cashPercent,
    this.cashOriginalText,
    this.cashHasDetails,
    this.stockPercent,
    this.stockOriginalText,
    this.stockHasDetails,
  });

  factory Dividend.fromMap(Map<String, dynamic> json) => Dividend(
    cashPercent: json["cash_percent"].toDouble(),
    cashOriginalText: json["cash_original_text"],
    cashHasDetails: json["cash_has_details"],
    stockPercent: json["stock_percent"],
    stockOriginalText: json["stock_original_text"],
    stockHasDetails: json["stock_has_details"],
  );

  Map<String, dynamic> toMap() => {
    "cash_percent": cashPercent,
    "cash_original_text": cashOriginalText,
    "cash_has_details": cashHasDetails,
    "stock_percent": stockPercent,
    "stock_original_text": stockOriginalText,
    "stock_has_details": stockHasDetails,
  };
}

class FiscalYear {
  final int? yearEnd;
  final DateTime? agmDate;
  final DateTime? declarationDate;

  FiscalYear({this.yearEnd, this.agmDate, this.declarationDate});

  factory FiscalYear.fromMap(Map<String, dynamic> json) => FiscalYear(
    yearEnd: json["year_end"],
    agmDate: json["agm_date"] == null ? null : DateTime.parse(json["agm_date"]),
    declarationDate: json["declaration_date"] == null
        ? null
        : DateTime.parse(json["declaration_date"]),
  );

  Map<String, dynamic> toMap() => {
    "year_end": yearEnd,
    "agm_date": agmDate?.toIso8601String(),
    "declaration_date": declarationDate?.toIso8601String(),
  };
}

class RecordDates {
  final DateTime? general;
  final dynamic stockSpecific;

  RecordDates({this.general, this.stockSpecific});

  factory RecordDates.fromMap(Map<String, dynamic> json) => RecordDates(
    general: json["general"] == null ? null : DateTime.parse(json["general"]),
    stockSpecific: json["stock_specific"],
  );

  Map<String, dynamic> toMap() => {
    "general": general?.toIso8601String(),
    "stock_specific": stockSpecific,
  };
}
