class MarketModel {
  final int? id;
  final int? fvbId;
  final String? session;
  final String? shortName;
  final String? fullName;
  final String? filterName;
  final String? firmId;
  final String? tradingState;
  final String? shareType;
  final String? marketType;
  final int? orderBook;
  final String? date;
  final int? lq;
  final int? bq;
  final int? aq;
  final double? dl;
  final double? dh;
  final double? bid;
  final double? ask;
  final double? open;
  final double? reference;
  final double? last;
  final int? volume;
  final double? high;
  final double? low;
  final double? close;
  final double? d;
  final double? chg;
  final double? settle1;
  final double? settle;
  final dynamic status;
  final double? val;
  final double? vwap;
  final int? executedQty;
  final int? sellPending;
  final int? buyPending;
  final String? board;
  final String? group;
  final String? instrumentType;
  final String? ticker;
  final String? sector;
  final String? isinCode;
  final int? trades;
  final String? lastTradeTime;
  final double? wk52Low;
  final double? wk52High;
  final double? wk26Low;
  final double? wk26High;
  final double? wk4Low;
  final double? wk4High;
  final double? wk2Low;
  final double? wk2High;
  final double? wk1Low;
  final double? wk1High;
  final double? ch1y;
  final double? chp1y;
  final double? ch6m;
  final double? chp6m;
  final double? ch1m;
  final double? chp1m;
  final double? ch2w;
  final double? chp2w;
  final double? ch1w;
  final double? chp1w;
  final double? wk1AvgVol;
  final double? month1AvgVol;
  final String? streamId;
  final int? sp;
  final int? bp;

  const MarketModel({
    this.id,
    this.fvbId,
    this.session,
    this.shortName,
    this.fullName,
    this.filterName,
    this.firmId,
    this.tradingState,
    this.shareType,
    this.marketType,
    this.orderBook,
    this.date,
    this.lq,
    this.bq,
    this.aq,
    this.dl,
    this.dh,
    this.bid,
    this.ask,
    this.open,
    this.reference,
    this.last,
    this.volume,
    this.high,
    this.low,
    this.close,
    this.d,
    this.chg,
    this.settle1,
    this.settle,
    this.status,
    this.val,
    this.vwap,
    this.executedQty,
    this.sellPending,
    this.buyPending,
    this.board,
    this.group,
    this.instrumentType,
    this.ticker,
    this.sector,
    this.isinCode,
    this.trades,
    this.lastTradeTime,
    this.wk52Low,
    this.wk52High,
    this.wk26Low,
    this.wk26High,
    this.wk4Low,
    this.wk4High,
    this.wk2Low,
    this.wk2High,
    this.wk1Low,
    this.wk1High,
    this.ch1y,
    this.chp1y,
    this.ch6m,
    this.chp6m,
    this.ch1m,
    this.chp1m,
    this.ch2w,
    this.chp2w,
    this.ch1w,
    this.chp1w,
    this.wk1AvgVol,
    this.month1AvgVol,
    this.streamId,
    this.sp,
    this.bp,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      fvbId: json['fvbId'] != null
          ? int.tryParse(json['fvbId'].toString())
          : null,
      session: json['session']?.toString(),
      shortName: json['sn'],
      fullName: json['fn'],
      filterName: json['fln'],
      firmId: json['fid'],
      tradingState: json['ts'],
      shareType: json['st']?.toString(),
      marketType: json['mt'],
      orderBook: int.tryParse(json['ob']?.toString() ?? ''),
      date: json['date']?.toString(),
      lq: json['lq'],
      bq: json['bq'],
      aq: json['aq'],
      dl: (json['dl'] ?? 0).toDouble(),
      dh: (json['dh'] ?? 0).toDouble(),
      bid: (json['bd'] ?? 0).toDouble(),
      ask: (json['ak'] ?? 0).toDouble(),
      open: (json['o'] ?? 0).toDouble(),
      reference: (json['r'] ?? 0).toDouble(),
      settle1: (json['r'] ?? 0).toDouble(),
      last: (json['lp'] ?? 0).toDouble(),
      volume: json['v'],
      executedQty: json['v'],
      high: (json['h'] ?? 0).toDouble(),
      low: (json['l'] ?? 0).toDouble(),
      close: (json['c'] ?? 0).toDouble(),
      settle: (json['c'] ?? 0).toDouble(),
      d: (json['d'] ?? 0).toDouble(),
      chg: (json['cg'] ?? 0).toDouble(),
      status: json['status'] ?? json['ts'],
      val: (json['vl'] ?? 0).toDouble(),
      vwap: double.tryParse(json['vw']?.toString() ?? '') ?? 0.0,
      board: json['b'],
      group: json['g'],
      instrumentType: json['it'],
      ticker: json['t'],
      sector: json['sc'],
      isinCode: json['ic'],
      trades: json['tds'],
      lastTradeTime: json['ltt'] != null ? '${json['ltt']}' : null,
      wk52Low: (json['52l'] ?? 0).toDouble(),
      wk52High: (json['52h'] ?? 0).toDouble(),
      wk26Low: (json['26l'] ?? 0).toDouble(),
      wk26High: (json['26h'] ?? 0).toDouble(),
      wk4Low: (json['4wl'] ?? 0).toDouble(),
      wk4High: (json['4wh'] ?? 0).toDouble(),
      wk2Low: (json['2wl'] ?? 0).toDouble(),
      wk2High: (json['2wh'] ?? 0).toDouble(),
      wk1Low: (json['1wl'] ?? 0).toDouble(),
      wk1High: (json['1wh'] ?? 0).toDouble(),
      ch1y: (json['ch_1y'] ?? 0).toDouble(),
      chp1y: (json['chp_1y'] ?? 0).toDouble(),
      ch6m: (json['ch_6m'] ?? 0).toDouble(),
      chp6m: (json['chp_6m'] ?? 0).toDouble(),
      ch1m: (json['ch_1m'] ?? 0).toDouble(),
      chp1m: (json['chp_1m'] ?? 0).toDouble(),
      ch2w: (json['ch_2w'] ?? 0).toDouble(),
      chp2w: (json['chp_2w'] ?? 0).toDouble(),
      ch1w: (json['ch_1w'] ?? 0).toDouble(),
      chp1w: (json['chp_1w'] ?? 0).toDouble(),
      wk1AvgVol: (json['1wav'] ?? 0).toDouble(),
      month1AvgVol: (json['1mav'] ?? 0).toDouble(),
      sellPending: json['sellPending'],
      buyPending: json['buyPending'],
      streamId: json['streamId'],
      sp: (json['sp'] ?? 0).toInt(),
      bp: (json['bp'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fvbId': fvbId,
    'session': session,
    'sn': shortName,
    'fn': fullName,
    'fln': filterName,
    'fid': firmId,
    'ts': tradingState,
    'st': shareType,
    'mt': marketType,
    'ob': orderBook,
    'date': date,
    'lq': lq,
    'bq': bq,
    'aq': aq,
    'dl': dl,
    'dh': dh,
    'bd': bid,
    'ak': ask,
    'o': open,
    'r': [reference, settle1],
    'lp': last,
    'v': [volume, executedQty],
    'h': high,
    'l': low,
    'c': [close, settle],
    'd': d,
    'cg': chg,
    'status': status,
    'vl': val,
    'vw': vwap,
    'sellPending': sellPending,
    'buyPending': buyPending,
    'b': board,
    'g': group,
    'it': instrumentType,
    't': ticker,
    'sc': sector,
    'ic': isinCode,
    'tds': trades,
    'ltt': lastTradeTime,
    '52l': wk52Low,
    '52h': wk52High,
    '26l': wk26Low,
    '26h': wk26High,
    '4wl': wk4Low,
    '4wh': wk4High,
    '2wl': wk2Low,
    '2wh': wk2High,
    '1wl': wk1Low,
    '1wh': wk1High,
    'ch_1y': ch1y,
    'chp_1y': chp1y,
    'ch_6m': ch6m,
    'chp_6m': chp6m,
    'ch_1m': ch1m,
    'chp_1m': chp1m,
    'ch_2w': ch2w,
    'chp_2w': chp2w,
    'ch_1w': ch1w,
    'chp_1w': chp1w,
    '1wav': wk1AvgVol,
    '1mav': month1AvgVol,
    'streamId': streamId,
    'sp': sp,
    'bp': bp,
  };

  MarketModel copyWith({
    int? id,
    int? fvbId,
    String? session,
    String? shortName,
    String? fullName,
    String? filterName,
    String? firmId,
    String? tradingState,
    String? shareType,
    String? marketType,
    int? orderBook,
    String? date,
    int? lq,
    int? bq,
    int? aq,
    double? dl,
    double? dh,
    double? bid,
    double? ask,
    double? open,
    double? reference,
    double? last,
    int? volume,
    double? high,
    double? low,
    double? close,
    double? d,
    double? chg,
    double? settle1,
    double? settle,
    dynamic status,
    double? val,
    double? vwap,
    int? executedQty,
    int? sellPending,
    int? buyPending,
    String? board,
    String? group,
    String? instrumentType,
    String? ticker,
    String? sector,
    String? isinCode,
    int? trades,
    String? lastTradeTime,
    double? wk52Low,
    double? wk52High,
    double? wk26Low,
    double? wk26High,
    double? wk4Low,
    double? wk4High,
    double? wk2Low,
    double? wk2High,
    double? wk1Low,
    double? wk1High,
    double? ch1y,
    double? chp1y,
    double? ch6m,
    double? chp6m,
    double? ch1m,
    double? chp1m,
    double? ch2w,
    double? chp2w,
    double? ch1w,
    double? chp1w,
    double? wk1AvgVol,
    double? month1AvgVol,
    String? streamId,
    int? sp,
    int? bp,
  }) {
    return MarketModel(
      id: id ?? this.id,
      fvbId: fvbId ?? this.fvbId,
      session: session ?? this.session,
      shortName: shortName ?? this.shortName,
      fullName: fullName ?? this.fullName,
      filterName: filterName ?? this.filterName,
      firmId: firmId ?? this.firmId,
      tradingState: tradingState ?? this.tradingState,
      shareType: shareType ?? this.shareType,
      marketType: marketType ?? this.marketType,
      orderBook: orderBook ?? this.orderBook,
      date: date ?? this.date,
      lq: lq ?? this.lq,
      bq: bq ?? this.bq,
      aq: aq ?? this.aq,
      dl: dl ?? this.dl,
      dh: dh ?? this.dh,
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
      open: open ?? this.open,
      reference: reference ?? this.reference,
      last: last ?? this.last,
      volume: volume ?? this.volume,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      d: d ?? this.d,
      chg: chg ?? this.chg,
      settle1: settle1 ?? this.settle1,
      settle: settle ?? this.settle,
      status: status ?? this.status,
      val: val ?? this.val,
      vwap: vwap ?? this.vwap,
      executedQty: executedQty ?? this.executedQty,
      sellPending: sellPending ?? this.sellPending,
      buyPending: buyPending ?? this.buyPending,
      board: board ?? this.board,
      group: group ?? this.group,
      instrumentType: instrumentType ?? this.instrumentType,
      ticker: ticker ?? this.ticker,
      sector: sector ?? this.sector,
      isinCode: isinCode ?? this.isinCode,
      trades: trades ?? this.trades,
      lastTradeTime: lastTradeTime ?? this.lastTradeTime,
      wk52Low: wk52Low ?? this.wk52Low,
      wk52High: wk52High ?? this.wk52High,
      wk26Low: wk26Low ?? this.wk26Low,
      wk26High: wk26High ?? this.wk26High,
      wk4Low: wk4Low ?? this.wk4Low,
      wk4High: wk4High ?? this.wk4High,
      wk2Low: wk2Low ?? this.wk2Low,
      wk2High: wk2High ?? this.wk2High,
      wk1Low: wk1Low ?? this.wk1Low,
      wk1High: wk1High ?? this.wk1High,
      ch1y: ch1y ?? this.ch1y,
      chp1y: chp1y ?? this.chp1y,
      ch6m: ch6m ?? this.ch6m,
      chp6m: chp6m ?? this.chp6m,
      ch1m: ch1m ?? this.ch1m,
      chp1m: chp1m ?? this.chp1m,
      ch2w: ch2w ?? this.ch2w,
      chp2w: chp2w ?? this.chp2w,
      ch1w: ch1w ?? this.ch1w,
      chp1w: chp1w ?? this.chp1w,
      wk1AvgVol: wk1AvgVol ?? this.wk1AvgVol,
      month1AvgVol: month1AvgVol ?? this.month1AvgVol,
      streamId: streamId ?? this.streamId,
      sp: sp ?? this.sp,
      bp: bp ?? this.bp,
    );
  }

  MarketModel mergePartialUpdate(Map<String, dynamic> json) {
    return copyWith(
      id: json.containsKey('id') ? int.tryParse(json['id'].toString()) : id,
      fvbId: json.containsKey('fvbId')
          ? int.tryParse(json['fvbId'].toString())
          : fvbId,
      session: json.containsKey('session')
          ? json['session']?.toString()
          : session,
      shortName: json.containsKey('sn') ? json['sn'] : shortName,
      fullName: json.containsKey('fn') ? json['fn'] : fullName,
      filterName: json.containsKey('fln') ? json['fln'] : filterName,
      firmId: json.containsKey('fid') ? json['fid'] : firmId,
      tradingState: json.containsKey('ts') ? json['ts'] : tradingState,
      shareType: json.containsKey('st') ? json['st'] : shareType,
      marketType: json.containsKey('mt') ? json['mt'] : marketType,
      orderBook: json.containsKey('ob')
          ? int.tryParse(json['ob'].toString())
          : orderBook,
      date: json.containsKey('date') ? json['date']?.toString() : date,
      lq: json.containsKey('lq') ? json['lq'] : lq,
      bq: json.containsKey('bq') ? json['bq'] : bq,
      aq: json.containsKey('aq') ? json['aq'] : aq,
      dl: json.containsKey('dl') ? (json['dl'] as num?)?.toDouble() : dl,
      dh: json.containsKey('dh') ? (json['dh'] as num?)?.toDouble() : dh,
      bid: json.containsKey('bd') ? (json['bd'] as num?)?.toDouble() : bid,
      ask: json.containsKey('ak') ? (json['ak'] as num?)?.toDouble() : ask,
      open: json.containsKey('o') ? (json['o'] as num?)?.toDouble() : open,
      reference: json.containsKey('r')
          ? (json['r'] as num?)?.toDouble()
          : reference,
      settle1: json.containsKey('r')
          ? (json['r'] as num?)?.toDouble()
          : settle1,
      last: json.containsKey('lp') ? (json['lp'] as num?)?.toDouble() : last,
      volume: json.containsKey('v') ? json['v'] : volume,
      high: json.containsKey('h') ? (json['h'] as num?)?.toDouble() : high,
      low: json.containsKey('l') ? (json['l'] as num?)?.toDouble() : low,
      close: json.containsKey('c') ? (json['c'] as num?)?.toDouble() : close,
      settle: json.containsKey('c') ? (json['c'] as num?)?.toDouble() : settle,
      d: json.containsKey('d') ? (json['d'] as num?)?.toDouble() : d,
      chg: json.containsKey('cg') ? (json['cg'] as num?)?.toDouble() : chg,
      status: json.containsKey('status')
          ? json['status']
          : (json.containsKey('ts') ? json['ts'] : status),
      val: json.containsKey('vl') ? (json['vl'] as num?)?.toDouble() : val,
      vwap: json.containsKey('vw')
          ? (double.tryParse(json['vw']?.toString() ?? '') ?? vwap)
          : vwap,
      executedQty: json.containsKey('v') ? json['v'] : executedQty,
      sellPending: json.containsKey('sellPending')
          ? json['sellPending']
          : sellPending,
      buyPending: json.containsKey('buyPending')
          ? json['buyPending']
          : buyPending,
      board: json.containsKey('b') ? json['b'] : board,
      group: json.containsKey('g') ? json['g'] : group,
      instrumentType: json.containsKey('it') ? json['it'] : instrumentType,
      ticker: json.containsKey('t') ? json['t'] : ticker,
      sector: json.containsKey('sc') ? json['sc'] : sector,
      isinCode: json.containsKey('ic') ? json['ic'] : isinCode,
      trades: json.containsKey('tds') ? json['tds'] : trades,
      lastTradeTime: json.containsKey('ltt') ? '${json['ltt']}' : lastTradeTime,
      wk52Low: json.containsKey('52l')
          ? (json['52l'] as num?)?.toDouble()
          : wk52Low,
      wk52High: json.containsKey('52h')
          ? (json['52h'] as num?)?.toDouble()
          : wk52High,
      wk26Low: json.containsKey('26l')
          ? (json['26l'] as num?)?.toDouble()
          : wk26Low,
      wk26High: json.containsKey('26h')
          ? (json['26h'] as num?)?.toDouble()
          : wk26High,
      wk4Low: json.containsKey('4wl')
          ? (json['4wl'] as num?)?.toDouble()
          : wk4Low,
      wk4High: json.containsKey('4wh')
          ? (json['4wh'] as num?)?.toDouble()
          : wk4High,
      wk2Low: json.containsKey('2wl')
          ? (json['2wl'] as num?)?.toDouble()
          : wk2Low,
      wk2High: json.containsKey('2wh')
          ? (json['2wh'] as num?)?.toDouble()
          : wk2High,
      wk1Low: json.containsKey('1wl')
          ? (json['1wl'] as num?)?.toDouble()
          : wk1Low,
      wk1High: json.containsKey('1wh')
          ? (json['1wh'] as num?)?.toDouble()
          : wk1High,
      ch1y: json.containsKey('ch_1y')
          ? (json['ch_1y'] as num?)?.toDouble()
          : ch1y,
      chp1y: json.containsKey('chp_1y')
          ? (json['chp_1y'] as num?)?.toDouble()
          : chp1y,
      ch6m: json.containsKey('ch_6m')
          ? (json['ch_6m'] as num?)?.toDouble()
          : ch6m,
      chp6m: json.containsKey('chp_6m')
          ? (json['chp_6m'] as num?)?.toDouble()
          : chp6m,
      ch1m: json.containsKey('ch_1m')
          ? (json['ch_1m'] as num?)?.toDouble()
          : ch1m,
      chp1m: json.containsKey('chp_1m')
          ? (json['chp_1m'] as num?)?.toDouble()
          : chp1m,
      ch2w: json.containsKey('ch_2w')
          ? (json['ch_2w'] as num?)?.toDouble()
          : ch2w,
      chp2w: json.containsKey('chp_2w')
          ? (json['chp_2w'] as num?)?.toDouble()
          : chp2w,
      ch1w: json.containsKey('ch_1w')
          ? (json['ch_1w'] as num?)?.toDouble()
          : ch1w,
      chp1w: json.containsKey('chp_1w')
          ? (json['chp_1w'] as num?)?.toDouble()
          : chp1w,
      wk1AvgVol: json.containsKey('1wav')
          ? (json['1wav'] as num?)?.toDouble()
          : wk1AvgVol,
      month1AvgVol: json.containsKey('1mav')
          ? (json['1mav'] as num?)?.toDouble()
          : month1AvgVol,
      streamId: json.containsKey('streamId') ? json['streamId'] : streamId,
      sp: json.containsKey('sp') ? (json['sp'] as int?) : sp,
      bp: json.containsKey('bp') ? (json['bp'] as int?) : bp,
    );
  }

  MarketModel mergeUpdate(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : id,
      fvbId: json['fvbId'] != null
          ? int.tryParse(json['fvbId'].toString())
          : fvbId,
      session: json['session'] ?? session,
      shortName: json['sn'] ?? shortName,
      fullName: json['fn'] ?? fullName,
      filterName: json['fln'] ?? filterName,
      firmId: json['fid'] ?? firmId,
      tradingState: json['ts'] ?? tradingState,
      shareType: json['st'] ?? shareType,
      marketType: json['mt'] ?? marketType,
      orderBook: json['ob'] != null
          ? int.tryParse(json['ob'].toString()) ?? orderBook
          : orderBook,
      date: json['date'] ?? date,
      lq: json['lq'] ?? lq,
      bq: json['bq'] ?? bq,
      aq: json['aq'] ?? aq,
      dl: (json['dl'] as num?)?.toDouble() ?? dl,
      dh: (json['dh'] as num?)?.toDouble() ?? dh,
      bid: (json['bd'] as num?)?.toDouble() ?? bid,
      ask: (json['ak'] as num?)?.toDouble() ?? ask,
      open: (json['o'] as num?)?.toDouble() ?? open,
      reference: (json['r'] as num?)?.toDouble() ?? reference,
      settle1: (json['r'] as num?)?.toDouble() ?? settle1,
      last: (json['lp'] as num?)?.toDouble() ?? last,
      volume: json['v'] ?? volume,
      high: (json['h'] as num?)?.toDouble() ?? high,
      low: (json['l'] as num?)?.toDouble() ?? low,
      close: (json['c'] as num?)?.toDouble() ?? close,
      settle: (json['c'] as num?)?.toDouble() ?? settle,
      d: (json['d'] as num?)?.toDouble() ?? d,
      chg: (json['cg'] as num?)?.toDouble() ?? chg,
      status: json['status'] ?? json['ts'] ?? status,
      val: (json['vl'] as num?)?.toDouble() ?? val,
      vwap: (json['vw'] as num?)?.toDouble() ?? vwap,
      executedQty: json['v'] ?? executedQty,
      sellPending: json['sellPending'] ?? sellPending,
      buyPending: json['buyPending'] ?? buyPending,
      board: json['b'] ?? board,
      group: json['g'] ?? group,
      instrumentType: json['it'] ?? instrumentType,
      ticker: json['t'] ?? ticker,
      sector: json['sc'] ?? sector,
      isinCode: json['ic'] ?? isinCode,
      trades: json['tds'] ?? trades,
      lastTradeTime: json['ltt'] != null ? '${json['ltt']}' : lastTradeTime,
      wk52Low: (json['52l'] as num?)?.toDouble() ?? wk52Low,
      wk52High: (json['52h'] as num?)?.toDouble() ?? wk52High,
      wk26Low: (json['26l'] as num?)?.toDouble() ?? wk26Low,
      wk26High: (json['26h'] as num?)?.toDouble() ?? wk26High,
      wk4Low: (json['4wl'] as num?)?.toDouble() ?? wk4Low,
      wk4High: (json['4wh'] as num?)?.toDouble() ?? wk4High,
      wk2Low: (json['2wl'] as num?)?.toDouble() ?? wk2Low,
      wk2High: (json['2wh'] as num?)?.toDouble() ?? wk2High,
      wk1Low: (json['1wl'] as num?)?.toDouble() ?? wk1Low,
      wk1High: (json['1wh'] as num?)?.toDouble() ?? wk1High,
      ch1y: (json['ch_1y'] as num?)?.toDouble() ?? ch1y,
      chp1y: (json['chp_1y'] as num?)?.toDouble() ?? chp1y,
      ch6m: (json['ch_6m'] as num?)?.toDouble() ?? ch6m,
      chp6m: (json['chp_6m'] as num?)?.toDouble() ?? chp6m,
      ch1m: (json['ch_1m'] as num?)?.toDouble() ?? ch1m,
      chp1m: (json['chp_1m'] as num?)?.toDouble() ?? chp1m,
      ch2w: (json['ch_2w'] as num?)?.toDouble() ?? ch2w,
      chp2w: (json['chp_2w'] as num?)?.toDouble() ?? chp2w,
      ch1w: (json['ch_1w'] as num?)?.toDouble() ?? ch1w,
      chp1w: (json['chp_1w'] as num?)?.toDouble() ?? chp1w,
      wk1AvgVol: (json['1wav'] as num?)?.toDouble() ?? wk1AvgVol,
      month1AvgVol: (json['1mav'] as num?)?.toDouble() ?? month1AvgVol,
      streamId: json['streamId'] ?? streamId,
      sp: json['sp'] != null ? (json['sp'] as num).toInt() : sp,
      bp: json['bp'] != null ? (json['bp'] as num).toInt() : bp,
    );
  }
}

class OrderDetail {
  final int? orders;
  final double? price;
  final int? quantity;

  OrderDetail({this.orders, this.price, this.quantity});

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orders: json['Orders'],
      price: (json['Bid'] ?? json['Ask'] ?? 0).toDouble(),
      quantity: json['Quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Orders': orders,
    'Bid': price,
    'Quantity': quantity,
  };
}

class MarketOrderModel {
  final int? orderbook;
  final int? orders;
  final double? price;
  final int? quantity;
  final int? cumQ;

  MarketOrderModel({
    this.orderbook,
    this.orders,
    this.price,
    this.quantity,
    this.cumQ,
  });

  factory MarketOrderModel.fromJson(Map<String, dynamic> json) {
    return MarketOrderModel(
      orderbook: json['orderbook'],
      orders: json['Orders'],
      price: (json['Bid'] ?? json['Ask'] ?? 0).toDouble(),
      quantity: json['Quantity'],
      cumQ: json['CumQ'],
    );
  }

  Map<String, dynamic> toJson() => {
    'orderbook': orderbook,
    'Orders': orders,
    'Bid': price,
    'Quantity': quantity,
    'CumQ': cumQ,
  };
}

class Bucket {
  final String label;
  final double min;
  final double max;
  final bool isCenter;
  const Bucket(this.label, this.min, this.max, {this.isCenter = false});
}
