// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nino_create_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NinoCreate)
final ninoCreateProvider = NinoCreateProvider._();

final class NinoCreateProvider
    extends $NotifierProvider<NinoCreate, NinoCreateState> {
  NinoCreateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ninoCreateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ninoCreateHash();

  @$internal
  @override
  NinoCreate create() => NinoCreate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NinoCreateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NinoCreateState>(value),
    );
  }
}

String _$ninoCreateHash() => r'9e7ea9e04a3abb9d0158773627f6e388aa18f34c';

abstract class _$NinoCreate extends $Notifier<NinoCreateState> {
  NinoCreateState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NinoCreateState, NinoCreateState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NinoCreateState, NinoCreateState>,
              NinoCreateState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
