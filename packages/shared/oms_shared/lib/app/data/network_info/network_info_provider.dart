import 'dart:convert';

import 'package:oms_shared/app/app_pkg.dart';
import 'package:oms_shared/app/data/notifiers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'network_info_impl.dart';

/// NetworkInfo provider
final networkInfoProvider = Provider<InternetConnection>((ref) => InternetConnection());

/// NetworkInfoImpl provider
final networkInfoImplProvider = Provider<NetworkInfoImpl>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return NetworkInfoImpl(networkInfo: networkInfo);
});

//
// lib/api_state.dart
/*
sealed class ApiState<T> {}

class ApiLoading<T> extends ApiState<T> {}

class ApiLoaded<T> extends ApiState<T> {
  final T data;

  ApiLoaded(this.data);
}

class ApiError<T> extends ApiState<T> {
  final String message;
  ApiError(this.message);
}
//
// lib/models/item.dart
class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
    );
  }
}
//
class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<Item>> fetchItems() async {
    final response = await GetConnect().get('$baseUrl/items');

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Item.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }
}
////

// Define a provider for the API service
final apiServiceProvider = Provider((ref) => ApiService('https://example.com'));

// Define a provider for fetching items with API state
final itemsProvider = FutureProvider<ApiState<List<Item>>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final data = await apiService.fetchItems();
    return ApiLoaded(data);
  } catch (e) {
    return ApiError(e.toString());
  }
});
///
///
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'api_state.dart';
import 'models/item.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Riverpod API Example')),
        body: ItemList(),
      ),
    );
  }
}

class ItemList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(itemsProvider);

    return asyncItems.when(
      data: (apiState) {
        if (apiState is ApiLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (apiState is ApiLoaded) {
          final items = apiState.data;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
              );
            },
          );
        } else if (apiState is ApiError) {
          return Center(child: Text('Error: ${apiState.message}'));
        }
        return Center(child: Text('Unknown state'));
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
*/

//multiple state change events with flutter riverpod
//model/ states
class MyState {
  final int value1;
  final String? value2;
  final bool value3;
  final String? selectOrderType;

  MyState({required this.value1, this.value2, required this.value3, this.selectOrderType});

  // The copyWith method allows for updating individual properties
  MyState copyWith({int? value1, String? value2, bool? value3, String? selectOrderType}) {
    return MyState(
      value1: value1 ?? this.value1,
      value2: value2 ?? this.value2,
      value3: value3 ?? this.value3,
      selectOrderType: selectOrderType ?? this.selectOrderType,
    );
  }
}
//https://dev.to/danielasaboro/statenotifier-changenotifier-why-when-and-how-to-use-them-2l6j

// notifire
// Convert to Notifier
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() {
    // Initial state
    return MyState(value1: 0, value2: 'Initial', value3: false);
  }

  void updateValue1(int newValue) {
    state = state.copyWith(value1: state.value1 + newValue);
  }

  void updateValue2(String newValue) {
    state = state.copyWith(value2: newValue);
  }

  void updateValue3(bool newValue) {
    state = state.copyWith(value3: state.value3 != newValue);
  }

  void changeOrderType(String newOrderType) {
    // Access other providers using ref
    final selectOrder = ref.read(selectOrderProvider);
    print('select order :: $selectOrder');

    // If you need to update another provider
    // ref.read(selectOrderProvider.notifier).state = newOrderType;
  }
}

// Create the provider
final myProvider = NotifierProvider<MyNotifier, MyState>(() {
  return MyNotifier();
});

//notifier
final counterProvider = NotifierProvider<CounterNotifier, MyState>(() => CounterNotifier());

class CounterNotifier extends Notifier<MyState> {
  @override
  MyState build() {
    return MyState(value1: 0, value3: false);
  }

  void updateValue1(int newValue) {
    state = state.copyWith(value1: state.value1 + newValue);
    // ref.read(selectOrderProvider.notifier).update((state) => state + newValue);
  }

  void updateValue2(String newValue) {
    state = state.copyWith(value2: newValue);
  }

  void updateValue3(bool newValue) {
    state = state.copyWith(value3: state.value3 != newValue);
  }

  void changeOrderType(String newOrderType) {
    printLog('select order :: ${ref.read(selectOrderProvider)}');

    // ref.read(selectOrderProvider.notifier).state=newOrderType;
    // state = state.copyWith(selectOrderType: newOrderType );
  }
}

final myStateNotifierProvider = NotifierProvider<MyNotifier, MyState>(() {
  return MyNotifier();
});

// Notifier class
class SelectOrderNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Initial state is null
    return null;
  }

  // Method to set order
  void setOrder(String order) {
    state = order;
  }

  // Method to clear order
  void clear() {
    state = null;
  }

  // Getter to check if order is selected
  bool get hasOrder => state != null;

  // Method to toggle between two orders
  void toggleOrder(String order1, String order2) {
    if (state == order1) {
      state = order2;
    } else {
      state = order1;
    }
  }
}

// NotifierProvider declaration
final selectOrderProvider = NotifierProvider<SelectOrderNotifier, String?>(() {
  return SelectOrderNotifier();
});

class MyStateView extends ConsumerWidget {
  const MyStateView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myState = ref.watch(myStateNotifierProvider);
    final selectOrderType = ref.watch(selectOrderProvider);
    final myStateNotifier = ref.watch(myStateNotifierProvider.notifier);
    final counterState = ref.watch(myStateNotifierProvider);
    final counterNotifier = ref.watch(myStateNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('StateNotifier')),
      body: Column(
        mainAxisAlignment: .center,
        children: [
          Text('Value 1: ${myState.value1}'),
          Text('Value 2: ${myState.value2}'),
          Text('Value 3: ${myState.value3}'),
          SizedBox(height: 20),
          Text('Value 1: ${counterState.value1}'),
          Text('Value 2: ${counterState.value2}'),
          Text('Value 3: ${counterState.value3}'),
          OrderTypeDropdownListWidget(
            valueChanged: (value) {
              ref.read(selectOrderProvider.notifier).state = value;
              myStateNotifier.changeOrderType(value!);
            },
            selectedValueNotifier: ValueNotifier(selectOrderType),
          ),
          ElevatedButton(
            onPressed: () {
              myStateNotifier.updateValue1(10);
            },
            child: const Text('Update Value 1'),
          ),
          ElevatedButton(
            onPressed: () {
              myStateNotifier.updateValue2('Updated Value');
            },
            child: const Text('Update Value 2'),
          ),
          ElevatedButton(
            onPressed: () {
              myStateNotifier.updateValue3(true);
            },
            child: const Text('Update Value 3'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              counterNotifier.updateValue1(10);
            },
            child: const Text('Update Value 1'),
          ),
          ElevatedButton(
            onPressed: () {
              counterNotifier.updateValue2('Updated Value');
            },
            child: const Text('Update Value 2'),
          ),
          ElevatedButton(
            onPressed: () {
              counterNotifier.updateValue3(true);
            },
            child: const Text('Update Value 3'),
          ),
        ],
      ),
    );
  }
}

//https://codewithandrea.com/articles/flutter-riverpod-async-notifier/
//https://medium.com/@ntd278/how-i-simplified-flutter-state-management-using-riverpod-c76652fb607f
///async notifier
class User {
  final String id;
  final String name;
  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'].toString(), name: json['name']);
  }

  User copyWith({String? id, String? name}) {
    return User(id: id ?? this.id, name: name ?? this.name);
  }
}

class UserData {
  final List<User> users;
  final int counter;

  UserData({required this.users, required this.counter});

  UserData copyWith({List<User>? users, int? counter}) {
    return UserData(users: users ?? this.users, counter: counter ?? this.counter);
  }
}

class DataNotifier extends AsyncNotifier<UserData> {
  @override
  Future<UserData> build() async {
    return await _fetchInitialData();
  }

  Future<UserData> _fetchInitialData() async {
    final users = await _fetchUsers();
    return UserData(users: users, counter: 0);
  }

  Future<List<User>> _fetchUsers() async {
    var dio = ref.read(dioProvider);
    final response = await GetConnect().get('https://jsonplaceholder.typicode.com/users');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> incrementCounter() async {
    final currentState = state.value ?? UserData(users: [], counter: 0);
    final newCounter = currentState.counter + 1;
    state = AsyncValue.data(currentState.copyWith(counter: newCounter));

    // Simulate network delay and possible failure
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Update counter on the server if needed
    } catch (e) {
      // state = AsyncValue.error(e);
    }
  }

  Future<void> addUser(User newUser) async {
    final currentState = state.value ?? UserData(users: [], counter: 0);
    state = AsyncValue.data(currentState.copyWith(users: [...currentState.users, newUser]));

    // Simulate network delay and possible failure
    try {
      await Future.delayed(Duration(seconds: 1));
      // Here you would normally send a request to add the user to the server
    } catch (e) {
      // state = AsyncValue.error(e);
    }
  }

  Future<void> refreshData() async {
    try {
      final users = await _fetchUsers();
      state = AsyncValue.data(UserData(users: users, counter: state.value?.counter ?? 0));
    } catch (e) {
      // state = AsyncValue.error(e);
    }
  }
}

// Provider for the AsyncNotifier
final dataProvider = AsyncNotifierProvider<DataNotifier, UserData>(DataNotifier.new);
final dataProvider2 = AsyncNotifierProvider<DataNotifier, UserData>(() {
  return DataNotifier();
});
