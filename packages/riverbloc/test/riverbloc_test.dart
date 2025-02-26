import 'package:bloc/bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

enum CounterEvent { inc, dec }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(int state, {this.onClose}) : super(state);

  void Function()? onClose;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.inc:
        yield state + 1;
        break;
      case CounterEvent.dec:
      default:
        yield state - 1;
        break;
    }
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

final counterBlocProvider = BlocProvider((ref) => CounterBloc(0));

class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);
}

final counterCubitProvider = BlocProvider((ref) => CounterCubit(0));

void main() {
  group('Bloc test', () {
    test(
        'reads bloc with default state 0 and applies increments and decrements',
        () async {
      final container = ProviderContainer();

      final counterBloc = container.read(counterBlocProvider);

      expect(counterBloc.state, 0);

      container.read(counterBlocProvider).add(CounterEvent.inc);
      await Future(() {});
      expect(counterBloc.state, 1);

      container.read(counterBlocProvider).add(CounterEvent.inc);
      container.read(counterBlocProvider).add(CounterEvent.inc);
      await Future(() {});
      expect(counterBloc.state, 3);

      container.read(counterBlocProvider).add(CounterEvent.dec);
      await Future(() {});
      expect(counterBloc.state, 2);
    });

    test('defaults to 0 and notify listeners when value changes', () async {
      final container = ProviderContainer();

      final counterBloc = container.read(counterBlocProvider);

      expect(counterBloc.state, 0);
      expect(container.read(counterBlocProvider.state), 0);

      for (var count = 0; count < 10; count++) {
        container.read(counterBlocProvider).add(CounterEvent.inc);
        expect(container.read(counterBlocProvider.state), count);
        await Future(() {});
        expect(counterBloc.state, count + 1);
        expect(container.read(counterBlocProvider.state), count + 1);
      }
    });

    test('bloc resubscribe', () async {
      final container = ProviderContainer();
      final counterBloc = container.read(counterBlocProvider);

      expect(counterBloc.state, 0);
      expect(container.read(counterBlocProvider.state), 0);

      for (var i = 0; i < 2; i++) {
        counterBloc.add(CounterEvent.inc);
      }
      await Future(() {});
      expect(container.read(counterBlocProvider.state), 2);

      final counterBloc2 = container.refresh(counterBlocProvider);
      expect(counterBloc2, isNot(equals(counterBloc)));
      expect(container.read(counterBlocProvider), equals(counterBloc2));

      expect(counterBloc2.state, 0);
      expect(container.read(counterBlocProvider.state), 0);
    });

    test('bloc with manual dispose', () async {
      final container = ProviderContainer();

      var isBlocClosed = false;

      final counterBlocProvider = BlocProvider(
        (ref) {
          final bloc = CounterBloc(0, onClose: () => isBlocClosed = true);
          ref.onDispose(bloc.close);
          return bloc;
        },
      );
      final counterBloc = container.read(counterBlocProvider);

      expect(counterBloc.state, 0);
      expect(container.read(counterBlocProvider.state), 0);

      counterBloc.add(CounterEvent.inc);
      await Future(() {});

      container.dispose();

      expect(isBlocClosed, true);
    });

    test('BlocProvider override with provider', () {
      final counterBloc = CounterBloc(3);
      final counterProvider2 = BlocProvider((ref) => counterBloc);
      final container = ProviderContainer(
        overrides: [
          counterBlocProvider.overrideWithProvider(counterProvider2),
        ],
      );

      expect(container.read(counterBlocProvider), counterBloc);
      expect(container.read(counterBlocProvider.state), 3);
    });

    test('BlocStateProvider override with value', () {
      final container = ProviderContainer(
        overrides: [
          counterBlocProvider.state.overrideWithValue(5),
        ],
      );
      expect(container.read(counterBlocProvider.state), 5);
      expect(container.read(counterBlocProvider).state, 0);
    });
  });

  group('Cubit test', () {
    test('reads cubit with default state 0 and increments it', () {
      final container = ProviderContainer();

      final counterCubit = container.read(counterCubitProvider);

      expect(counterCubit.state, 0);

      container.read(counterCubitProvider).increment();

      expect(counterCubit.state, 1);
    });

    test('defaults to 0 and notify listeners when value changes', () async {
      final container = ProviderContainer();

      final counterCubit = container.read(counterCubitProvider);

      expect(counterCubit.state, 0);
      expect(container.read(counterCubitProvider.state), 0);

      for (var count = 0; count < 10; count++) {
        container.read(counterCubitProvider).increment();
        expect(container.read(counterCubitProvider.state), count);
        expect(counterCubit.state, count + 1);
        await Future(() {});
        expect(container.read(counterCubitProvider.state), count + 1);
      }
    });

    test('bloc resubscribe', () async {
      final container = ProviderContainer();
      final counterCubit = container.read(counterCubitProvider);

      expect(counterCubit.state, 0);
      expect(container.read(counterCubitProvider.state), 0);

      for (var i = 0; i < 2; i++) {
        counterCubit.increment();
      }
      await Future(() {});
      expect(container.read(counterCubitProvider.state), 2);

      final counterCubit2 = container.refresh(counterCubitProvider);
      expect(counterCubit2, isNot(equals(counterCubit)));
      expect(container.read(counterCubitProvider), equals(counterCubit2));

      expect(counterCubit2.state, 0);
      expect(container.read(counterCubitProvider.state), 0);
    });

    test('BlocProvider override with provider', () {
      final counterCubit = CounterCubit(3);
      final counterProvider2 = BlocProvider((ref) => counterCubit);
      final container = ProviderContainer(
        overrides: [
          counterCubitProvider.overrideWithProvider(counterProvider2),
        ],
      );

      expect(container.read(counterCubitProvider), counterCubit);
      expect(container.read(counterCubitProvider.state), 3);
    });

    test('BlocStateProvider override with value', () {
      final container = ProviderContainer(
        overrides: [
          counterCubitProvider.state.overrideWithValue(5),
        ],
      );
      expect(container.read(counterCubitProvider.state), 5);
      expect(container.read(counterCubitProvider).state, 0);
    });
  });
}
