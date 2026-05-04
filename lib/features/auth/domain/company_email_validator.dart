class CompanyEmailValidator {
  const CompanyEmailValidator();

  static const _blockedDomains = {
    'gmail.com',
    'googlemail.com',
    'yahoo.co.jp',
    'yahoo.com',
    'icloud.com',
    'me.com',
    'mac.com',
    'outlook.com',
    'hotmail.com',
    'live.com',
    'proton.me',
    'protonmail.com',
    'docomo.ne.jp',
    'ezweb.ne.jp',
    'softbank.ne.jp',
  };

  CompanyEmailValidation validate(String rawEmail) {
    final email = rawEmail.trim().toLowerCase();
    final parts = email.split('@');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
      return const CompanyEmailValidation.invalid('会社メールを入力してください');
    }

    final domain = parts.last;
    if (!domain.contains('.') || _blockedDomains.contains(domain)) {
      return const CompanyEmailValidation.invalid(
        '個人メールでは登録できません',
      );
    }

    return CompanyEmailValidation.valid(domain);
  }
}

class CompanyEmailValidation {
  const CompanyEmailValidation._({
    required this.isValid,
    required this.domain,
    required this.errorMessage,
  });

  const CompanyEmailValidation.valid(String domain)
      : this._(isValid: true, domain: domain, errorMessage: null);

  const CompanyEmailValidation.invalid(String errorMessage)
      : this._(isValid: false, domain: null, errorMessage: errorMessage);

  final bool isValid;
  final String? domain;
  final String? errorMessage;
}
