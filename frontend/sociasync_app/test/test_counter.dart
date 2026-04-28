import 'package:flutter_test/flutter_test.dart';
import 'package:sociasync_app/counter.dart';

void main() {
  test('Counter initial value test', () {
    final counter = Counter();
    expect(counter.value, 0);
  });

  test('Counter increments test', () {
    final counter = Counter();
    counter.increment();
    counter.increment();
    expect(counter.value, 2);
  });

  test('Counter decrements test', () {
    final counter = Counter();
    counter.decrement();
    expect(counter.value, -1);
  });
}
