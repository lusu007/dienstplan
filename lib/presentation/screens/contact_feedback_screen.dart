import 'package:dienstplan/presentation/widgets/common/confirm_discard_changes.dart';
import 'package:dienstplan/presentation/widgets/common/app_snack_bar.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';

import 'dart:async';

import 'package:dienstplan/core/config/contact_feedback_copy.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/routing/root_navigator.dart';
import 'package:dienstplan/core/telemetry/sentry_telemetry.dart';
import 'package:dienstplan/core/utils/logger.dart';

import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef SubmitContactFeedback = Future<SentryId> Function(
  SentryFeedback feedback,
  Hint? hint,
);
typedef CaptureContactFeedbackScreenshot = Future<SentryAttachment?> Function();
typedef StartContactFeedbackScreenshotSelection = Future<void> Function(
  ContactFeedbackDraft draft,
);

class ContactFeedbackDraft {
  final String name;
  final String email;
  final String message;

  const ContactFeedbackDraft({
    this.name = '',
    this.email = '',
    this.message = '',
  });
}

class ContactFeedbackScreen extends StatefulWidget {
  final SubmitContactFeedback? onSubmitFeedback;
  final CaptureContactFeedbackScreenshot? captureScreenshot;
  final StartContactFeedbackScreenshotSelection? startScreenshotSelection;
  final ContactFeedbackDraft initialDraft;
  final SentryAttachment? initialScreenshot;

  const ContactFeedbackScreen({
    super.key,
    this.onSubmitFeedback,
    this.captureScreenshot,
    this.startScreenshotSelection,
    this.initialDraft = const ContactFeedbackDraft(),
    this.initialScreenshot,
  });

  @override
  State<ContactFeedbackScreen> createState() => _ContactFeedbackScreenState();
}

class _ContactFeedbackScreenState extends State<ContactFeedbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  SentryAttachment? _screenshot;
  FutureOr<Uint8List>? _screenshotBytes;
  bool _isSubmitting = false;
  bool _confirmingClose = false;
  bool _isCapturingScreenshot = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialDraft.name;
    _emailController.text = widget.initialDraft.email;
    _messageController.text = widget.initialDraft.message;
    _screenshot = widget.initialScreenshot;
    _screenshotBytes = widget.initialScreenshot?.bytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _nameController.text.isNotEmpty ||
      _emailController.text.isNotEmpty ||
      _messageController.text.isNotEmpty ||
      _screenshot != null;

  Future<void> _requestClose() async {
    if (_isSubmitting || _isCapturingScreenshot || _confirmingClose) return;
    _confirmingClose = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final discard = !_isDirty || await confirmDiscardChanges(context);
    _confirmingClose = false;
    if (mounted && discard) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: GlassScreenScaffold(
        title: ContactFeedbackCopy.title,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              glassSpacingLg,
              glassSpacingXl - 4,
              glassSpacingLg,
              glassSpacingXxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIntro(context),
                      const SizedBox(height: glassSpacingXl),
                      _FeedbackTextField(
                        key: const ValueKey('contact_feedback_name_textfield'),
                        controller: _nameController,
                        label: ContactFeedbackCopy.nameLabel,
                        hintText: ContactFeedbackCopy.namePlaceholder,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: glassSpacingLg),
                      _FeedbackTextField(
                        key: const ValueKey('contact_feedback_email_textfield'),
                        controller: _emailController,
                        label: ContactFeedbackCopy.emailLabel,
                        hintText: ContactFeedbackCopy.emailPlaceholder,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: glassSpacingLg),
                      _FeedbackTextField(
                        key: const ValueKey(
                          'contact_feedback_message_textfield',
                        ),
                        controller: _messageController,
                        label:
                            '${ContactFeedbackCopy.messageLabel}'
                            '${ContactFeedbackCopy.requiredLabel}',
                        hintText: ContactFeedbackCopy.messagePlaceholder,
                        minLines: 5,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        validator: _validateRequired,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4096),
                        ],
                      ),
                      const SizedBox(height: glassSpacingLg),
                      _buildScreenshotAction(context),
                      const SizedBox(height: glassSpacingXl),
                      ActionButton(
                        key: const ValueKey('contact_feedback_submit'),
                        text: ContactFeedbackCopy.submitButton,
                        loadingText: ContactFeedbackCopy.submitButton,
                        isLoading: _isSubmitting,
                        fontSize: 16,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ContactFeedbackCopy.introTitle,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: glassSpacingSm),
        Text(
          ContactFeedbackCopy.introBody,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotAction(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle? bodySmall = Theme.of(context).textTheme.bodySmall;

    if (_screenshot != null) {
      final preview = FutureBuilder<Uint8List>(
        future: Future<Uint8List>.value(_screenshotBytes),
        builder: (context, snapshot) {
          final Widget preview = snapshot.hasData
              ? Image.memory(snapshot.data!, fit: BoxFit.cover)
              : Icon(Icons.image_outlined, color: colorScheme.onSurface);
          return ClipRRect(
            borderRadius: BorderRadius.circular(glassSurfaceRadiusSm),
            child: SizedBox.square(dimension: 48, child: preview),
          );
        },
      );
      final label = Text(
        ContactFeedbackCopy.screenshotAttached,
        style: bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      );
      final removeButton = AppGlassButton(
        role: AppGlassButtonRole.quiet,
        onPressed: _isSubmitting ? null : () => _setScreenshot(null),
        child: const Text(ContactFeedbackCopy.removeScreenshotButton),
      );
      return LayoutBuilder(
        builder: (context, constraints) {
          final stackAction =
              constraints.maxWidth < 340 ||
              MediaQuery.textScalerOf(context).scale(16) > 18;
          final summary = Row(
            children: [
              preview,
              const SizedBox(width: glassSpacingMd),
              Expanded(child: label),
              if (!stackAction) removeButton,
            ],
          );
          return stackAction
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: glassSpacingSm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: removeButton,
                    ),
                  ],
                )
              : summary;
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ContactFeedbackCopy.screenshotHint,
          style: bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: glassSpacingSm),
        AppGlassButton.icon(
          role: AppGlassButtonRole.secondary,

          key: const ValueKey('contact_feedback_capture_screenshot'),
          onPressed: _isCapturingScreenshot || _isSubmitting
              ? null
              : _captureScreenshot,
          isLoading: _isCapturingScreenshot,
          icon: const Icon(Icons.screenshot_outlined),
          label: const Text(ContactFeedbackCopy.captureScreenshotButton),
        ),
      ],
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ContactFeedbackCopy.validationError;
    }
    return null;
  }

  Future<void> _captureScreenshot() async {
    if (widget.captureScreenshot == null) {
      await _startAppScreenshotSelection();
      return;
    }
    setState(() => _isCapturingScreenshot = true);
    try {
      final SentryAttachment? screenshot = await widget.captureScreenshot!();
      if (!mounted) {
        return;
      }
      if (screenshot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackBar(
            content: const Text(ContactFeedbackCopy.screenshotUnavailable),
          ),
        );
        return;
      }
      _setScreenshot(screenshot);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to capture feedback screenshot '
        '(screen=contact_feedback, errorType=${e.runtimeType})',
        e,
        stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar(
          content: const Text(ContactFeedbackCopy.screenshotUnavailable),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCapturingScreenshot = false);
      }
    }
  }

  Future<void> _startAppScreenshotSelection() async {
    setState(() => _isCapturingScreenshot = true);
    final ContactFeedbackDraft draft = ContactFeedbackDraft(
      name: _nameController.text,
      email: _emailController.text,
      message: _messageController.text,
    );
    try {
      final StartContactFeedbackScreenshotSelection? startSelection =
          widget.startScreenshotSelection;
      if (startSelection != null) {
        await startSelection(draft);
      } else {
        await ContactFeedbackScreenshotCoordinator.start(
          context: context,
          draft: draft,
          initialScreenshot: _screenshot,
          captureScreenshot: widget.captureScreenshot,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to start contact feedback screenshot selection '
        '(screen=contact_feedback, errorType=${e.runtimeType})',
        e,
        stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar(
          content: const Text(ContactFeedbackCopy.screenshotUnavailable),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCapturingScreenshot = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final Hint hint = Hint();
      // Keep parity with SentryFeedbackWidget so SDK processors classify this
      // as explicit in-app feedback, not a generic feedback event.
      // ignore: invalid_use_of_internal_member
      hint.set(TypeCheckHint.isWidgetFeedback, true);
      final SentryAttachment? screenshot = _screenshot;
      if (screenshot != null) {
        hint.screenshot = screenshot;
      }
      final SentryFeedback feedback = SentryFeedback(
        message: _messageController.text.trim(),
        contactEmail: _emailController.text.trim(),
        name: _nameController.text.trim(),
      );
      final SubmitContactFeedback? submit = widget.onSubmitFeedback;
      late final SentryId feedbackId;
      if (submit != null) {
        feedbackId = await submit(feedback, hint);
      } else {
        feedbackId = await Sentry.captureFeedback(feedback, hint: hint);
      }
      if (feedbackId == const SentryId.empty()) {
        await SentryTelemetry.recordBreadcrumb(
          category: 'feedback.contact',
          message: 'Contact feedback submission failed',
          data: <String, dynamic>{
            'reason': 'sentry_empty_id',
            'hasScreenshot': screenshot != null,
          },
          level: SentryLevel.error,
        );
        AppLogger.e(
          'Failed to submit contact feedback '
          '(screen=contact_feedback, reason=sentry_empty_id)',
        );
        if (!mounted) {
          return;
        }
        messenger.showSnackBar(
          AppSnackBar(content: const Text(ContactFeedbackCopy.submitError)),
        );
        return;
      }
      if (!mounted) {
        return;
      }
      AppLogger.i(
        'Submitted contact feedback successfully '
        '(feedbackId=$feedbackId, hasScreenshot=${screenshot != null})',
      );
      await SentryTelemetry.recordBreadcrumb(
        category: 'feedback.contact',
        message: 'Contact feedback submitted',
        data: <String, dynamic>{
          'feedbackId': feedbackId.toString(),
          'hasScreenshot': screenshot != null,
        },
      );
      if (!mounted) {
        return;
      }
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      messenger.showSnackBar(
        AppSnackBar(content: const Text(ContactFeedbackCopy.successMessage)),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to submit contact feedback '
        '(screen=contact_feedback, errorType=${e.runtimeType})',
        e,
        stackTrace,
      );
      await SentryTelemetry.recordBreadcrumb(
        category: 'feedback.contact',
        message: 'Contact feedback submission failed',
        data: <String, dynamic>{
          'reason': 'unexpected_error',
          'errorType': e.runtimeType.toString(),
        },
        level: SentryLevel.error,
      );
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        AppSnackBar(content: const Text(ContactFeedbackCopy.submitError)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _setScreenshot(SentryAttachment? screenshot) {
    setState(() {
      _screenshot = screenshot;
      _screenshotBytes = screenshot?.bytes;
    });
  }
}

class ContactFeedbackScreenshotCoordinator {
  const ContactFeedbackScreenshotCoordinator._();
  static OverlayEntry? _overlayEntry;

  static Future<void> start({
    required BuildContext context,
    required ContactFeedbackDraft draft,
    SentryAttachment? initialScreenshot,
    CaptureContactFeedbackScreenshot? captureScreenshot,
  }) async {
    final navigator = rootNavigatorKey.currentState ?? Navigator.of(context);
    final overlay = navigator.overlay;
    if (overlay == null || _overlayEntry != null) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    LocalHistoryEntry? history;
    var finished = false;
    var hostRemoved = false;
    late final OverlayEntry entry;
    Future<void> finish({required bool capture}) async {
      if (finished) return;
      finished = true;
      history?.remove();
      entry.remove();
      entry.dispose();
      _overlayEntry = null;
      var screenshot = initialScreenshot;
      var failed = false;
      if (capture) {
        try {
          await WidgetsBinding.instance.endOfFrame;
          final next =
              await (captureScreenshot ?? SentryFlutter.captureScreenshot)();
          if (next == null) {
            failed = true;
          } else {
            screenshot = next;
          }
        } catch (error, stack) {
          AppLogger.e('Screenshot capture failed', error, stack);
          failed = true;
        }
      }
      if (!navigator.mounted || hostRemoved) return;
      unawaited(
        navigator.push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ContactFeedbackScreen(
              initialDraft: draft,
              initialScreenshot: screenshot,
            ),
          ),
        ),
      );
      if (failed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigator.mounted) {
            ScaffoldMessenger.of(navigator.context).showSnackBar(
              AppSnackBar(
                content: const Text(ContactFeedbackCopy.screenshotUnavailable),
              ),
            );
          }
        });
      }
    }

    entry = OverlayEntry(
      builder: (_) => _ContactFeedbackScreenshotOverlayButton(
        onCapture: () => finish(capture: true),
        onCancel: () => finish(capture: false),
      ),
    );
    _overlayEntry = entry;
    overlay.insert(entry);
    // Back exits selection instead of leaving an overlay on another screen.
    navigator.popUntil((route) {
      if (route is ModalRoute) {
        unawaited(
          route.completed.then((_) {
            hostRemoved = true;
            if (finished) return;
            finished = true;
            // The host is already disposed; removing its local history would
            // attempt to rebuild a disposed route overlay.
            entry.remove();
            entry.dispose();
            _overlayEntry = null;
          }),
        );
        history = LocalHistoryEntry(
          onRemove: () {
            if (!finished) {
              scheduleMicrotask(() => unawaited(finish(capture: false)));
            }
          },
        );
        route.addLocalHistoryEntry(history!);
      }
      return true;
    });
  }
}

class _ContactFeedbackScreenshotOverlayButton extends StatelessWidget {
  const _ContactFeedbackScreenshotOverlayButton({
    required this.onCapture,
    required this.onCancel,
  });
  final VoidCallback onCapture;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Positioned(
    left: glassSpacingLg,
    right: glassSpacingLg,
    bottom: glassSpacingLg,
    child: SafeArea(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(glassSurfaceRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(ContactFeedbackCopy.screenshotSelectionHint),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  AppGlassButton(
                    key: const ValueKey(
                      'contact_feedback_cancel_app_screenshot',
                    ),
                    role: AppGlassButtonRole.quiet,
                    onPressed: onCancel,
                    child: const Text(ContactFeedbackCopy.cancelButton),
                  ),
                  AppGlassButton(
                    key: const ValueKey('contact_feedback_take_app_screenshot'),
                    role: AppGlassButtonRole.primary,
                    onPressed: onCapture,
                    child: const Text(ContactFeedbackCopy.takeScreenshotButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FeedbackTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _FeedbackTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final BorderRadius borderRadius = BorderRadius.circular(
      glassSurfaceRadiusMd,
    );
    final Color borderColor = colorScheme.outline.withValues(
      alpha: isDark ? glassBorderAlphaDark : glassBorderAlphaLight,
    );

    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: inputFormatters,
      style: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: colorScheme.surface.withValues(
          alpha: isDark ? glassTintAlphaDark : glassTintAlphaLight,
        ),
        border: OutlineInputBorder(borderRadius: borderRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
