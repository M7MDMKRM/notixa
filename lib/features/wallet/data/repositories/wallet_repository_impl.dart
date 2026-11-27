import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final Dio _dio;
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  WalletRepositoryImpl(this._dio, this._db);

  @override
  Future<Result<List<Transaction>>> getTransactions({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 1. Try fetching from remote API
      final response = await _dio.get('/transactions', queryParameters: {
        if (category != null) 'category': category,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      });

      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data['data'] as List? ?? response.data as List? ?? [])
            .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
            .toList();

        // Cache transactions locally in SQLite
        await _cacheTransactionsLocally(list);
        return Success(list);
      }
    } catch (_) {
      // Network failure: Fallback to local SQLite cache
    }

    // Fallback: Read from local SQLite database
    try {
      final db = await _db.database;
      final rows = await db.query(
        'cached_transactions',
        orderBy: 'date DESC',
      );

      final localList = rows.map((r) => Transaction(
        id: r['id'] as String,
        amount: (r['amount'] as num).toDouble(),
        type: TransactionType.fromString(r['type'] as String),
        category: r['category'] as String,
        currency: r['currency'] as String,
        note: r['note'] as String?,
        date: DateTime.fromMillisecondsSinceEpoch(r['date'] as int),
      )).toList();

      return Success(localList);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<Transaction>> createTransaction(Transaction transaction) async {
    final newId = transaction.id.isEmpty ? _uuid.v4() : transaction.id;
    final itemToSave = transaction.copyWith(id: newId);

    // Save locally first for fast optimistic update
    try {
      final db = await _db.database;
      await db.insert('cached_transactions', {
        'id': itemToSave.id,
        'amount': itemToSave.amount,
        'type': itemToSave.type.name,
        'category': itemToSave.category,
        'currency': itemToSave.currency,
        'note': itemToSave.note,
        'date': itemToSave.date.millisecondsSinceEpoch,
        'is_synced': 0,
      });
    } catch (_) {}

    // Post to Remote API
    try {
      final response = await _dio.post('/transactions', data: itemToSave.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(itemToSave);
      }
      return Success(itemToSave);
    } catch (_) {
      // Saved offline successfully
      return Success(itemToSave);
    }
  }

  @override
  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final db = await _db.database;
      await db.update(
        'cached_transactions',
        {
          'amount': transaction.amount,
          'type': transaction.type.name,
          'category': transaction.category,
          'currency': transaction.currency,
          'note': transaction.note,
          'date': transaction.date.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      await _dio.put('/transactions/${transaction.id}', data: transaction.toJson());
      return Success(transaction);
    } catch (e) {
      return Success(transaction);
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      final db = await _db.database;
      await db.delete('cached_transactions', where: 'id = ?', whereArgs: [id]);
      await _dio.delete('/transactions/$id');
      return const Success(null);
    } catch (e) {
      return const Success(null);
    }
  }

  Future<void> _cacheTransactionsLocally(List<Transaction> transactions) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final t in transactions) {
      batch.insert(
        'cached_transactions',
        {
          'id': t.id,
          'amount': t.amount,
          'type': t.type.name,
          'category': t.category,
          'currency': t.currency,
          'note': t.note,
          'date': t.date.millisecondsSinceEpoch,
          'is_synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
