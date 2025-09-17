import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

/// Presents a user-friendly localized message for a Failure
class FailurePresenter {
  const FailurePresenter();

  String present(Failure failure, AppLocalizations l10n) {
    if (failure.userMessageKey != null) {
      // Add mapping here if any key requires arguments
      return _resolveByKey(
        failure.userMessageKey!,
        failure.userMessageArgs,
        l10n,
      );
    }

    switch (failure.code) {
      case FailureCode.validation:
        return l10n.genericValidationError;
      case FailureCode.notFound:
        return l10n.genericNotFoundError;
      case FailureCode.conflict:
        return l10n.genericConflictError;
      case FailureCode.unauthorized:
        return l10n.genericUnauthorizedError;
      case FailureCode.forbidden:
        return l10n.genericForbiddenError;
      case FailureCode.network:
        return l10n.genericNetworkError;
      case FailureCode.timeout:
        return l10n.genericTimeoutError;
      case FailureCode.storage:
        return l10n.genericStorageError;
      case FailureCode.serialization:
        return l10n.genericSerializationError;
      case FailureCode.cancellation:
        return l10n.genericCancellationError;
      case FailureCode.unknown:
        return l10n.genericUnknownError;
    }
  }

  String _resolveByKey(
    String key,
    Map<String, String>? args,
    AppLocalizations l10n,
  ) {
    // New localizations should get matching getters in AppLocalizations
    switch (key) {
      case 'errorTimeout':
        return l10n.genericTimeoutError;
      case 'errorNetwork':
        return l10n.genericNetworkError;
      case 'errorStorage':
        return l10n.genericStorageError;
      case 'errorSerialization':
        return l10n.genericSerializationError;
      case 'errorValidation':
        return l10n.genericValidationError;
      case 'errorUnknown':
      default:
        return l10n.genericUnknownError;
    }
  }
}
