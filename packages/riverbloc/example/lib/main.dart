import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);
}

final counterProvider = BlocProvider((ref) => CounterCubit(0));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // Rebuilds the widget if the cubit/bloc changes.
    // But does not rebuild if the state changes with the same cubit/bloc
    final counterCubit = watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'initial counterCubit.state: ${counterCubit.state}',
            ),
            Consumer(builder: (context, watch, __) {
              // Rebuilds on every emitted state
              final _counter = watch(counterProvider.state);
              return Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read(counterProvider).increment(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
