import 'package:flutter/material.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class _LegalDoc {
  final String title;
  final String body;
  const _LegalDoc(this.title, this.body);
}

const _docs = <String, _LegalDoc>{
  'terms': _LegalDoc(
    'Terms of Service',
    'Madadgaar connects customers who need roadside assistance with independent, '
        'verified helpers. Madadgaar facilitates the connection, pricing and payment for '
        'a request; the helper performs the actual assistance. Use of the app is subject '
        'to acceptable-use, cancellation and payment terms.',
  ),
  'privacy': _LegalDoc(
    'Privacy Policy',
    'Madadgaar collects the information needed to match you with a nearby helper: your '
        'phone number, approximate location while a request is active, vehicle details you '
        'choose to save, and request/rating history. Location is only shared with a helper '
        'for the duration of an active request.',
  ),
  'cancellation': _LegalDoc(
    'Cancellation Policy',
    'You can cancel a request any time before it is completed. If a helper has already '
        'been dispatched and is on the way, a cancellation fee may apply — this is always '
        'shown to you before you confirm a cancellation, never charged silently.',
  ),
  'fuel': _LegalDoc(
    'Fuel Delivery Policy',
    'Fuel delivered through Madadgaar is fulfilled through approved fuel-station or '
        'licensed delivery partners under Madadgaar\'s fuel fulfillment policy — never through '
        'informal or unsafe storage/transport of fuel. Fulfillment partners are responsible '
        'for complying with applicable fuel-handling and transport regulations.',
  ),
  'helper-agreement': _LegalDoc(
    'Helper Agreement',
    'Helpers on Madadgaar are independent service providers, not employees. Helpers must '
        'complete verification before accepting requests, keep their vehicle and service '
        'information accurate, and follow Madadgaar\'s safety guidelines while assisting '
        'customers.',
  ),
  'safety': _LegalDoc(
    'Safety Guidelines',
    'Meet in well-lit, accessible locations where possible. Verify the helper\'s name, '
        'vehicle and photo in the app before engaging. Madadgaar is not an emergency '
        'service — for a life-threatening situation, contact official emergency services '
        'directly.',
  ),
};

class LegalScreen extends StatelessWidget {
  final String doc;
  const LegalScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final entry = _docs[doc] ?? const _LegalDoc('Document', 'Not found.');
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(entry.body, style: AppTextStyles.bodyLarge, textAlign: TextAlign.left),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Text(
              'This is placeholder policy text for demonstration purposes. A real launch '
              'requires review against applicable Pakistani laws, fuel transportation rules, '
              'payment regulations and tax requirements — Madadgaar is not represented as '
              'legally licensed in this demo.',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
