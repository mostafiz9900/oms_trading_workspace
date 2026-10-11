class EpsModel {
  final String? tradingSymbol;
  final int? year;
  final String? quarter;
  final double? epsContinuing;
  final double? dilutedEpsContinuing;
  final bool? isCumulative;
  final int? month;

  EpsModel({
    this.tradingSymbol,
    this.year,
    this.quarter,
    this.epsContinuing,
    this.dilutedEpsContinuing,
    this.isCumulative,
    this.month,
  });

  factory EpsModel.fromMap(Map<String, dynamic> json) {
    // 🚀 Safe Boolean Parser: 1/0 বা "true"/"false" আসলেও সামলে নেবে
    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1; // 1 means true, 0 means false
      if (value is String) return value.toLowerCase() == 'true';
      return null;
    }

    return EpsModel(
      // 🚀 String এর জন্য: শুধু .toString() ব্যবহার করা হয়েছে
      tradingSymbol: json["trading_symbol"]?.toString(),
      quarter: json["quarter"]?.toString(),

      // 🚀 Int এর জন্য: আগে String বানিয়ে তারপর safely tryParse করা হয়েছে
      year: json["year"] != null ? int.tryParse(json["year"].toString()) : null,
      month: json["month"] != null
          ? int.tryParse(json["month"].toString())
          : null,

      // 🚀 Double এর জন্য: String বানিয়ে safely tryParse করা হয়েছে
      epsContinuing: json["eps_continuing"] != null
          ? double.tryParse(json["eps_continuing"].toString())
          : null,
      dilutedEpsContinuing: json["diluted_eps_continuing"] != null
          ? double.tryParse(json["diluted_eps_continuing"].toString())
          : null,

      // 🚀 Boolean এর জন্য
      isCumulative: parseBool(json["is_cumulative"]),
    );
  }

  Map<String, dynamic> toMap() => {
    "trading_symbol": tradingSymbol,
    "year": year,
    "quarter": quarter,
    "eps_continuing": epsContinuing,
    "diluted_eps_continuing": dilutedEpsContinuing,
    "is_cumulative": isCumulative,
    "month": month,
  };
}
