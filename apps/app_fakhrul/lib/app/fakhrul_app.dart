import 'package:flutter/material.dart';
import 'package:trading_ui/trading_ui.dart';

import 'fakhrul_config.dart';

class FakhrulApp extends StatelessWidget {
  const FakhrulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: FakhrulConfig.house.displayName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const FakhrulOnboardingPage(),
      routes: {
        '/onboarding': (_) => const FakhrulOnboardingPage(),
        '/login': (_) => const FakhrulLoginPage(),
        '/home': (_) => const FakhrulShell(),
        '/dashboard': (_) => const FakhrulShell(selectedIndex: 1),
        '/market': (_) => const FakhrulShell(selectedIndex: 2),
      },
    );
  }
}

class FakhrulOnboardingPage extends StatelessWidget {
  const FakhrulOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: CustomContainerWidget(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            FakhrulConfig.house.displayName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to Fakhrul',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Track prices, monitor your portfolio, and act on market opportunities from one secure trading workspace.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const FakhrulLoginPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Continue to app'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FakhrulLoginPage extends StatelessWidget {
  const FakhrulLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: 'demo@fakhrul.com');
    final passwordController = TextEditingController(text: 'secret123');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: CustomContainerWidget(
                padding: const EdgeInsets.all(28),
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login to your account',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use your secure mobile credentials to access your trading workspace.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const FakhrulShell(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Sign in'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FakhrulShell extends StatefulWidget {
  const FakhrulShell({super.key, this.selectedIndex = 0});

  final int selectedIndex;

  @override
  State<FakhrulShell> createState() => _FakhrulShellState();
}

class _FakhrulShellState extends State<FakhrulShell> {
  late int _selectedIndex;

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.trending_up_rounded),
      label: 'Market',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant FakhrulShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const FakhrulHomePage(),
      const FakhrulDashboardPage(),
      const FakhrulMarketPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) => setState(() => _selectedIndex = value),
        type: BottomNavigationBarType.fixed,
        items: _navItems,
      ),
    );
  }
}

class FakhrulHomePage extends StatelessWidget {
  const FakhrulHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final house = FakhrulConfig.house;

    return Scaffold(
      appBar: AppBar(
        title: Text(house.displayName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ResponsiveLayout(
        largeScreen: _buildContent(context, house),
        mediumScreen: _buildContent(context, house),
        smallScreen: _buildContent(context, house),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic house) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'House: ${house.houseId} · Environment: ${house.environment}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              CustomContainerWidget(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Momentum is improving across the active watchlist with strong participation in the index and mid-cap basket.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/dashboard'),
                          icon: const Icon(Icons.dashboard_rounded),
                          label: const Text('Dashboard'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/market'),
                          icon: const Icon(Icons.trending_up_rounded),
                          label: const Text('Market'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 700 ? 3 : 1;
                  final cards = [
                    _StatCard(
                      label: 'Nifty 50',
                      value: '24,180.4',
                      change: '+1.42%',
                    ),
                    _StatCard(
                      label: 'Bank Nifty',
                      value: '52,310.6',
                      change: '+1.12%',
                    ),
                    _StatCard(
                      label: 'Turnover',
                      value: '৳ 8.4Cr',
                      change: '+12.3%',
                    ),
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) => cards[index],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FakhrulDashboardPage extends StatelessWidget {
  const FakhrulDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomContainerWidget(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portfolio snapshot',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Invested',
                          value: '৳ 5.2L',
                          change: '+4.8%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'P&L',
                          value: '+৳ 42K',
                          change: '+3.2%',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FakhrulMarketPage extends StatelessWidget {
  const FakhrulMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final markets = [
      _MarketRow(symbol: 'DSE', value: '23,760.2', change: '+0.8%'),
      _MarketRow(symbol: 'BSE', value: '54,110.4', change: '+1.1%'),
      _MarketRow(symbol: 'Banking', value: '5,320.7', change: '+0.6%'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomContainerWidget(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market watch',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...markets.map(
                (market) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: market,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.change,
  });

  final String label;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');

    return CustomContainerWidget(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            change,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({
    required this.symbol,
    required this.value,
    required this.change,
  });

  final String symbol;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');

    return Row(
      children: [
        Expanded(
          child: Text(symbol, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 16),
        Text(
          change,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
