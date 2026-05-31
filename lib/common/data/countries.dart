class SrCountry {
  const SrCountry({
    required this.code,
    required this.flag,
    required this.name,
    required this.sapiens,
  });

  final String code;
  final String flag;
  final String name;
  final String sapiens;
}

const kCountries = [
  SrCountry(code: 'FR', flag: '🇫🇷', name: 'France', sapiens: '184K'),
  SrCountry(code: 'US', flag: '🇺🇸', name: 'United States', sapiens: '512K'),
  SrCountry(code: 'GB', flag: '🇬🇧', name: 'United Kingdom', sapiens: '143K'),
  SrCountry(code: 'DE', flag: '🇩🇪', name: 'Germany', sapiens: '167K'),
  SrCountry(code: 'JP', flag: '🇯🇵', name: 'Japan', sapiens: '224K'),
  SrCountry(code: 'KR', flag: '🇰🇷', name: 'South Korea', sapiens: '98K'),
  SrCountry(code: 'IN', flag: '🇮🇳', name: 'India', sapiens: '301K'),
  SrCountry(code: 'BR', flag: '🇧🇷', name: 'Brazil', sapiens: '88K'),
  SrCountry(code: 'CA', flag: '🇨🇦', name: 'Canada', sapiens: '76K'),
  SrCountry(code: 'AU', flag: '🇦🇺', name: 'Australia', sapiens: '64K'),
  SrCountry(code: 'ES', flag: '🇪🇸', name: 'Spain', sapiens: '92K'),
  SrCountry(code: 'IT', flag: '🇮🇹', name: 'Italy', sapiens: '102K'),
  SrCountry(code: 'NL', flag: '🇳🇱', name: 'Netherlands', sapiens: '52K'),
  SrCountry(code: 'SE', flag: '🇸🇪', name: 'Sweden', sapiens: '38K'),
  SrCountry(code: 'NO', flag: '🇳🇴', name: 'Norway', sapiens: '22K'),
  SrCountry(code: 'CH', flag: '🇨🇭', name: 'Switzerland', sapiens: '31K'),
  SrCountry(code: 'BE', flag: '🇧🇪', name: 'Belgium', sapiens: '28K'),
  SrCountry(code: 'PT', flag: '🇵🇹', name: 'Portugal', sapiens: '24K'),
  SrCountry(code: 'AE', flag: '🇦🇪', name: 'UAE', sapiens: '19K'),
  SrCountry(code: 'SG', flag: '🇸🇬', name: 'Singapore', sapiens: '21K'),
  SrCountry(code: 'MX', flag: '🇲🇽', name: 'Mexico', sapiens: '67K'),
  SrCountry(code: 'CN', flag: '🇨🇳', name: 'China', sapiens: '442K'),
];

SrCountry countryByCode(String code) =>
    kCountries.firstWhere((c) => c.code == code,
        orElse: () => const SrCountry(code: '', flag: '🌍', name: 'Global', sapiens: '0'));
