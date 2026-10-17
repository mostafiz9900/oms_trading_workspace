import '../enums/app_enum.dart';

import 'response/market_model.dart' show MarketModel;

class OrderConfirmHolder {
  final MarketModel? marketData;
  final double? price;
  final String? qty;
  final String? orderType;
  final String? tif;
  final String? orderValue;
  final String? commission;
  final String? netValue;
  final String? type;
  final String? disclosedQty;
  final String? validity;
  final String? minQty;
  final SideType2? sideType;

  OrderConfirmHolder({
    this.marketData,
    this.price,
    this.qty,
    this.orderType,
    this.tif,
    this.orderValue,
    this.commission,
    this.netValue,
    this.type,
    this.disclosedQty,
    this.validity,
    this.minQty,
    this.sideType,
  });
}
