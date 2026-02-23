import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nino_create_provider.freezed.dart';
part 'nino_create_provider.g.dart';

@freezed
abstract class NinoCreateState with _$NinoCreateState {
  const factory NinoCreateState({
    @Default(null) String? nfcUid,
    @Default(false) bool isLoading,
  }) = _NinoCreateState;
  const NinoCreateState._();
}

@riverpod
class NinoCreate extends _$NinoCreate {
  @override
  NinoCreateState build() {
    return const NinoCreateState();
  }

  void setNfcUid(String nfcUid) {
    state = state.copyWith(nfcUid: nfcUid);
  }

  void startLoading() {
    state = state.copyWith(isLoading: true);
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }
}
