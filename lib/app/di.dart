import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../core/data/local/app_database.dart';
import '../core/data/network/dio_factory.dart';
import '../core/data/storage/token_storage.dart';
import '../core/speech/deepgram_speech_service.dart';
import '../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../features/calendar/domain/repositories/calendar_repository.dart';
import '../features/home/domain/usecases/extract_note_usecase.dart';
import '../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';
import '../features/wallet/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Storage & Database
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Network & Dio
  sl.registerLazySingleton<DioFactory>(() => DioFactory(sl<TokenStorage>()));
  sl.registerLazySingleton<Dio>(() => sl<DioFactory>().createDio());

  // Services
  sl.registerLazySingleton<DeepgramSpeechService>(() => DeepgramSpeechService());

  // Repositories
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<Dio>(), sl<AppDatabase>()),
  );
  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(sl<Dio>(), sl<AppDatabase>()),
  );

  // Usecases
  sl.registerLazySingleton<ExtractNoteUsecase>(
    () => ExtractNoteUsecase(sl<Dio>()),
  );

  // BLoCs
  sl.registerFactory<WalletBloc>(
    () => WalletBloc(sl<WalletRepository>()),
  );
}
