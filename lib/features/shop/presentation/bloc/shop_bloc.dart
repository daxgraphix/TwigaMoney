import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/shop.dart';
import '../../domain/usecases/shop_usecases.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failure.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetShopUseCase getShopUseCase;
  final UpdateShopUseCase updateShopUseCase;

  ShopBloc({
    required this.getShopUseCase,
    required this.updateShopUseCase,
  }) : super(ShopInitial()) {
    on<LoadShopEvent>(_onLoadShop);
    on<UpdateShopEvent>(_onUpdateShop);
  }

  Future<void> _onLoadShop(LoadShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    
    final result = await TaskEither.tryCatch(
      () => getShopUseCase(NoParams()),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load shop: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(ShopError('failedToLoadShop')),
      (shop) => emit(ShopLoaded(shop)),
    );
  }

  Future<void> _onUpdateShop(
      UpdateShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    
    final result = await TaskEither.tryCatch(
      () => updateShopUseCase(event.shop),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update shop: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(ShopError('failedToUpdateShop')),
      (_) {
        add(LoadShopEvent());
        emit(ShopOperationSuccess());
      },
    );
  }
}
