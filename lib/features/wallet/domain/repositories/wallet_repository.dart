import '../../../../core/domain/result.dart';
import '../models/transaction.dart';

abstract class WalletRepository {
  Future<Result<List<Transaction>>> getTransactions({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Result<Transaction>> createTransaction(Transaction transaction);

  Future<Result<Transaction>> updateTransaction(Transaction transaction);

  Future<Result<void>> deleteTransaction(String id);
}
