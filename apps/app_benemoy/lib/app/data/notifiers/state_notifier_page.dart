import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Car {
  final int? speed;
  final int? doors;

  const Car({this.speed = 120, this.doors = 4});

  Car copy({int? speed, int? doors}) => Car(speed: speed ?? this.speed, doors: doors ?? this.doors);
}

// Import Notifier from 'package:riverpod_annotation/riverpod_annotation.dart'
// if you are using code generation (recommended).
// Otherwise, import Notifier from 'package:flutter_riverpod/flutter_riverpod.dart'.

class CarNotifier extends Notifier<Car> {
  // 1. The build method initializes the state and replaces the constructor logic
  @override
  Car build() {
    // This is the initial state, equivalent to CarNotifier() : super(Car())
    return Car();
  }

  // 2. Methods update the state using the copyWith method
  void setDoors(int doors) {
    // Read the current state and use copyWith to create the new state
    state = state.copy(doors: doors);
  }

  void increaseSpeed() {
    final speed = state.speed! + 5;
    state = state.copy(speed: speed);
  }

  void hitBrake() {
    final speed = max(0, state.speed! - 30);
    state = state.copy(speed: speed);
  }

  // Note: No dispose method is typically needed, as the Notifier is automatically
  // managed by Riverpod based on its usage (unless you need manual cleanup).
}

// 3. The Provider definition
final carProvider = NotifierProvider<CarNotifier, Car>(CarNotifier.new);

class StateNotifierPage extends ConsumerWidget {
  const StateNotifierPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final car = ref.watch(carProvider);
    final speed = car.speed;
    final doors = car.doors;

    final carNotifier = ref.watch(carProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('StateNotifierProvider')),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text('Speed: $speed'),
            const SizedBox(height: 8),
            Text('Doors: $doors'),
            const SizedBox(height: 32),
            // buildButtons(watch),
            const SizedBox(height: 32),
            Slider(value: car.doors!.toDouble(), max: 5, onChanged: (value) => carNotifier.setDoors(value.toInt())),
          ],
        ),
      ),
    );
  }

  Widget buildButtons(watch) {
    final carNotifier = watch(carProvider);

    return Row(
      mainAxisAlignment: .center,
      children: [
        // ButtonWidget(text: 'Increase +5', onClicked: carNotifier.increaseSpeed),
        const SizedBox(width: 12),
        // ButtonWidget(text: 'Hit Brake -30', onClicked: carNotifier.hitBrake),
      ],
    );
  }
}
