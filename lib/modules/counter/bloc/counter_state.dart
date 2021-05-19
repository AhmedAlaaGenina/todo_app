part of 'counter_cubit.dart';

@immutable
abstract class CounterState {}

class CounterInitial extends CounterState {}

class CounterPlus extends CounterState {}

class CounterMinus extends CounterState {}
