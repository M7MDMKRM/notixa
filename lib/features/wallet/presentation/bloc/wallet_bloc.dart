import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

// EVENTS
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends WalletEvent {
  final String? category;
  const LoadTransactionsEvent({this.category});
  @override
  List<Object?> get props => [category];
}

class AddTransactionEvent extends WalletEvent {
  final Transaction transaction;
  const AddTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends WalletEvent {
  final String id;
  const DeleteTransactionEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// STATES
abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final String selectedCurrency;

  const WalletLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.selectedCurrency = 'USD',
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpense, balance, selectedCurrency];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _repository;

  WalletBloc(this._repository) : super(WalletInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    final result = await _repository.getTransactions(category: event.category);

    if (result.isSuccess) {
      final list = result.dataOrNull ?? [];
      _emitLoadedState(list, emit);
    } else {
      emit(WalletError(result.failureOrNull?.message ?? 'Failed to load wallet data'));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<WalletState> emit,
  ) async {
    final result = await _repository.createTransaction(event.transaction);
    if (result.isSuccess) {
      // Reload list
      add(const LoadTransactionsEvent());
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<WalletState> emit,
  ) async {
    final result = await _repository.deleteTransaction(event.id);
    if (result.isSuccess) {
      add(const LoadTransactionsEvent());
    }
  }

  void _emitLoadedState(List<Transaction> list, Emitter<WalletState> emit) {
    double income = 0;
    double expense = 0;

    for (final t in list) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    emit(WalletLoaded(
      transactions: list,
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
      selectedCurrency: list.isNotEmpty ? list.first.currency : 'USD',
    ));
  }
}
