part of 'main.dart';

Future<void> _showAdminSheet(BuildContext context, Widget sheet) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          child: sheet,
        ),
      ),
    );

Color _verificationColor(VerificationStatus status) => switch (status) {
      VerificationStatus.verified => AppColors.success,
      VerificationStatus.pending => AppColors.amberText,
      _ => AppColors.danger,
    };

Future<void> _setVerification(BuildContext context, WidgetRef ref, HelperProfile helper, VerificationStatus status) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(madadgaarApiProvider).setHelperVerification(helper.id, status.name);
    ref.invalidate(_helpersProvider);
    ref.invalidate(_dashboardProvider);
    final verb = switch (status) {
      VerificationStatus.verified => 'approved',
      VerificationStatus.rejected => 'rejected',
      VerificationStatus.suspended => 'suspended',
      VerificationStatus.pending => 'moved back to pending',
    };
    messenger.showSnackBar(SnackBar(content: Text('${helper.name} $verb.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Could not update ${helper.name}: $e')));
  }
}

class _PendingHelperCard extends ConsumerWidget {
  final HelperProfile helper;
  const _PendingHelperCard({required this.helper});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: surfaceDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialsAvatar(name: helper.name, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(helper.name, style: AppTextStyles.bodyStrong),
                    Text(
                      '${helper.city} · ${helper.vehicleType.label} · ${helper.servicesOffered.join(', ')}',
                      style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TextButton(
                onPressed: () => _showAdminSheet(context, _HelperSheet(helperId: helper.id)),
                style: TextButton.styleFrom(minimumSize: const Size(0, 40)),
                child: const Text('Details'),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => _setVerification(context, ref, helper, VerificationStatus.rejected),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, minimumSize: const Size(0, 40)),
                child: const Text('Reject'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => _setVerification(context, ref, helper, VerificationStatus.verified),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }
}

class _HelperSheet extends ConsumerWidget {
  final String helperId;
  const _HelperSheet({required this.helperId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helper = ref.watch(_helpersProvider).value?.where((h) => h.id == helperId).firstOrNull;
    if (helper == null) return const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView());

    final vehicle = [helper.vehicleMake, helper.vehicleModel].whereType<String>().join(' ');
    final status = helper.verificationStatus;
    final muted = AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InitialsAvatar(name: helper.name, size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(helper.name, style: AppTextStyles.h2)),
            PillTag(label: status.label, color: _verificationColor(status)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _DetailRow('Phone', Text(helper.phone)),
        _DetailRow('City', Text(helper.city)),
        _DetailRow(
          'Vehicle',
          Text([helper.vehicleType.label, if (vehicle.isNotEmpty) vehicle, if (helper.vehicleReg != null) helper.vehicleReg!].join(' · ')),
        ),
        _DetailRow('Services', Text(helper.servicesOffered.join(', '))),
        _DetailRow('Experience', Text('${helper.experienceYears} years')),
        _DetailRow('Jobs', Text('${helper.completedJobs} completed · ${helper.cancelledJobs} cancelled')),
        _DetailRow('Rating', Text(helper.completedJobs > 0 ? '★ ${helper.rating.toStringAsFixed(1)}' : 'No ratings yet')),
        _DetailRow('Right now', Text(helper.activeRequestId != null ? 'On a job' : (helper.isOnline ? 'Online' : 'Offline'))),
        _DetailRow('Member since', Text(helper.memberSince)),
        const SizedBox(height: AppSpacing.xl),
        if (status == VerificationStatus.pending)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _setVerification(context, ref, helper, VerificationStatus.rejected),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _setVerification(context, ref, helper, VerificationStatus.verified),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Approve'),
                ),
              ),
            ],
          )
        else if (status == VerificationStatus.verified) ...[
          OutlinedButton.icon(
            onPressed: () => _setVerification(context, ref, helper, VerificationStatus.suspended),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.block_rounded, size: 18),
            label: const Text('Suspend helper'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Suspending takes them offline immediately and stops new job offers.', style: muted),
        ] else
          FilledButton.icon(
            onPressed: () => _setVerification(context, ref, helper, VerificationStatus.verified),
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reactivate helper'),
          ),
      ],
    );
  }
}

const _adminCancellable = {
  RequestStatus.searching,
  RequestStatus.accepted,
  RequestStatus.helperOnTheWay,
  RequestStatus.arrived,
  RequestStatus.serviceStarted,
};

class _RequestSheet extends ConsumerStatefulWidget {
  final String requestId;
  const _RequestSheet({required this.requestId});

  @override
  ConsumerState<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends ConsumerState<_RequestSheet> {
  bool _confirming = false;
  bool _cancelling = false;

  Future<void> _cancel(ServiceRequest request) async {
    setState(() => _cancelling = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(madadgaarApiProvider).cancelRequest(request.id, cancelledBy: 'admin', reason: 'Cancelled by Madadgaar support');
      ref.invalidate(_allRequestsProvider);
      ref.invalidate(_activeRequestsProvider);
      ref.invalidate(_dashboardProvider);
      ref.invalidate(_helpersProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Request cancelled. The customer and helper have been notified.')));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not cancel: $e')));
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(_allRequestsProvider).value?.where((r) => r.id == widget.requestId).firstOrNull;
    if (request == null) return const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView());

    final serviceName =
        ref.watch(_servicesProvider).value?.where((s) => s.key == request.serviceKey).firstOrNull?.name ?? request.serviceKey;
    final helperId = request.helperId;
    final helperName = helperId == null ? null : ref.watch(_helpersProvider).value?.where((h) => h.id == helperId).firstOrNull?.name;
    final problem = request.details['problem'] ?? request.details['note'];
    final canCancel = _adminCancellable.contains(request.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ServiceIconBadge(serviceKey: request.serviceKey, size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(serviceName, style: AppTextStyles.h2),
                  Text('#${request.id.substring(request.id.length - 6)}', style: AppTextStyles.caption),
                ],
              ),
            ),
            StatusBadge(request.status),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (problem != null) _DetailRow('Problem', Text('$problem')),
        _DetailRow('Location', Text(request.pickupLocation.address ?? '—')),
        _DetailRow('Helper', Text(helperName ?? helperId ?? 'Not assigned yet')),
        _DetailRow('Price', MoneyText(request.pricing.breakdown.total, style: AppTextStyles.bodyStrong)),
        _DetailRow('Distance', Text('${request.distanceKm.toStringAsFixed(1)} km')),
        _DetailRow('Created', Text(relativeTime(request.createdAt))),
        if (request.status == RequestStatus.cancelled)
          _DetailRow('Cancelled', Text('by ${request.cancelledBy ?? '—'}${request.cancelReason != null ? ' · ${request.cancelReason}' : ''}')),
        if (canCancel) ...[
          const SizedBox(height: AppSpacing.xl),
          if (!_confirming)
            OutlinedButton.icon(
              onPressed: () => setState(() => _confirming = true),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel this request'),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Cancel this request? The customer and helper will be notified, and no fee is charged.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelling ? null : () => setState(() => _confirming = false),
                          child: const Text('Keep it'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                          onPressed: _cancelling ? null : () => _cancel(request),
                          child: Text(_cancelling ? 'Cancelling…' : 'Yes, cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
