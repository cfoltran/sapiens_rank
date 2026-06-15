class SrCountry {
  const SrCountry({required this.code, required this.flag, required this.name});

  final String code;
  final String flag;
  final String name;
}

const kCountries = [
  SrCountry(code: 'FR', flag: '🇫🇷', name: 'France'),
  SrCountry(code: 'US', flag: '🇺🇸', name: 'United States'),
  SrCountry(code: 'GB', flag: '🇬🇧', name: 'United Kingdom'),
  SrCountry(code: 'DE', flag: '🇩🇪', name: 'Germany'),
  SrCountry(code: 'JP', flag: '🇯🇵', name: 'Japan'),
  SrCountry(code: 'KR', flag: '🇰🇷', name: 'South Korea'),
  SrCountry(code: 'IN', flag: '🇮🇳', name: 'India'),
  SrCountry(code: 'BR', flag: '🇧🇷', name: 'Brazil'),
  SrCountry(code: 'CA', flag: '🇨🇦', name: 'Canada'),
  SrCountry(code: 'AU', flag: '🇦🇺', name: 'Australia'),
  SrCountry(code: 'ES', flag: '🇪🇸', name: 'Spain'),
  SrCountry(code: 'IT', flag: '🇮🇹', name: 'Italy'),
  SrCountry(code: 'NL', flag: '🇳🇱', name: 'Netherlands'),
  SrCountry(code: 'SE', flag: '🇸🇪', name: 'Sweden'),
  SrCountry(code: 'NO', flag: '🇳🇴', name: 'Norway'),
  SrCountry(code: 'CH', flag: '🇨🇭', name: 'Switzerland'),
  SrCountry(code: 'BE', flag: '🇧🇪', name: 'Belgium'),
  SrCountry(code: 'PT', flag: '🇵🇹', name: 'Portugal'),
  SrCountry(code: 'AE', flag: '🇦🇪', name: 'UAE'),
  SrCountry(code: 'SG', flag: '🇸🇬', name: 'Singapore'),
  SrCountry(code: 'MX', flag: '🇲🇽', name: 'Mexico'),
  SrCountry(code: 'CN', flag: '🇨🇳', name: 'China'),
];

SrCountry countryByCode(String code) => kCountries.firstWhere(
  (c) => c.code == code,
  orElse: () => const SrCountry(code: '', flag: '🌍', name: 'Global'),
);
