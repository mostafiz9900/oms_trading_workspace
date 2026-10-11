import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ---------------------------------------------------------
// ১. আপনার দেওয়া Notifier ক্লাসগুলো (অপরিবর্তিত)
// ---------------------------------------------------------

class WebviewLoadingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true; // শুরুতে লোডিং ট্রু থাকবে
  }

  void startLoading() {
    state = true;
  }

  void stopLoading() {
    state = false;
  }
}

class TickerNotifier extends Notifier<String> {
  @override
  String build() {
    return 'GP'; // শুরুর কোম্পানি
  }

  void setTicker(String newTicker) {
    state = newTicker;
  }
}

// ---------------------------------------------------------
// ২. Provider ডিক্লারেশন
// ---------------------------------------------------------
final webviewLoadingProvider = NotifierProvider<WebviewLoadingNotifier, bool>(WebviewLoadingNotifier.new);

final tickerProvider = NotifierProvider<TickerNotifier, String>(TickerNotifier.new);

// ---------------------------------------------------------
// ৩. TradingViewPage উইজেট
// ---------------------------------------------------------
class TradingViewPage extends ConsumerStatefulWidget {
  const TradingViewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TradingViewPage> createState() => _TradingViewPageState();
}

class _TradingViewPageState extends ConsumerState<TradingViewPage> {
  late final WebViewController _controller;

  // DSEBD এর ভ্যালিড এবং জনপ্রিয় টিকার সিম্বল লিস্ট
  final List<String> dseTickers = [
    'GP', // Grameenphone
    'SQURPHARMA', // Square Pharmaceuticals
    'BRACBANK', // BRAC Bank
    'BEXIMCO', // Beximco Pharmaceuticals
    'DSEX', // DSE Broad Index (মার্কেট ইনডেক্স)
    'LINDA', // Linda Group Textiles
    'BATBC', // British American Tobacco Bangladesh
    'ROBI', // Robi Axiata
  ];

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black) // লোডিংয়ের সময় কালো ব্যাকগ্রাউন্ড
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            ref.read(webviewLoadingProvider.notifier).startLoading();
          },
          onPageFinished: (String url) {
            ref.read(webviewLoadingProvider.notifier).stopLoading();
          },
          onWebResourceError: (WebResourceError error) {
            // এরর লগিং (ডিবাগিংয়ের জন্য)
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_getTradingViewHtml(ref.read(tickerProvider)));
  }

  // ড্রপডাউন থেকে সিলেকশন পরিবর্তন হলে এই ফাংশন কল হবে
  void _onTickerChanged(String newTicker) {
    // ১. Notifier এ নতুন টিকার সেট করো
    ref.read(tickerProvider.notifier).setTicker(newTicker);

    // ২. WebView তে নতুন HTML লোড করো (এতে স্বয়ংক্রিয়ভাবে লোডিং শুরু ও শেষ হবে)
    _controller.loadHtmlString(_getTradingViewHtml(newTicker));
  }

  // TradingView এর HTML উইজেট জেনারেটর (এখানে DSEBD: ব্যবহার করা হয়েছে)
  String _getTradingViewHtml(String ticker) {
    return '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>DSE Chart</title>
          <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
          <style>
              body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; background-color: #131722; }
              #tradingview_widget { height: 100vh; width: 100%; }
          </style>
      </head>
      <body>
          <div id="tradingview_widget"></div>
          <script type="text/javascript">
              new TradingView.widget({
                  "width": "100%",
                  "height": "100%",
                  "symbol": "DSEBD:$ticker", 
                  "interval": "D",
                  "timezone": "Asia/Dhaka",
                  "theme": "dark", 
                  "style": "1", 
                  "locale": "en",
                  "toolbar_bg": "#131722",
                  "enable_publishing": false,
                  "allow_symbol_change": true, 
                  "container_id": "tradingview_widget"
              });
          </script>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(webviewLoadingProvider);
    final currentTicker = ref.watch(tickerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DSE Stock Chart'),
        backgroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: currentTicker,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              underline: const SizedBox(),
              items: dseTickers.map((String ticker) {
                return DropdownMenuItem<String>(value: ticker, child: Text(ticker));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != currentTicker) {
                  _onTickerChanged(newValue);
                  launchOnlyDseChart(newValue);
                }
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

Future<void> launchOnlyDseChart(String ticker) async {
  // উদাহরণ: ticker = "DSEX" অথবা "GP" অথবা "BEXIMCO"

  // ১. মূল ট্রিক: ইউআরএল প্যারামিটারে মার্কেট ও স্ক্রিনার বাংলাদেশ রাখা হয়েছে
  // এবং exchange=DSEBD দিয়ে সার্চ ইঞ্জিনকে সম্পূর্ণ লক করা হয়েছে।
  final String dseLockedUrl =
      "https://tradingview.com"
      "&screener=bangladesh"
      "&market=bangladesh"
      "&exchange=DSEBD";

  final Uri url = Uri.parse(dseLockedUrl);

  try {
    // LaunchMode.externalApplication ব্যবহার করা হয়েছে যাতে এটি মোবাইল ব্রাউজারে বা
    // ফোনে TradingView এর নিজস্ব অফিসিয়াল অ্যাপ থাকলে সেখানে প্রফেশনালি ওপেন হয়।
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $dseLockedUrl');
    }
  } catch (e) {
    debugPrint("URL Launcher Error: $e");
  }
}
