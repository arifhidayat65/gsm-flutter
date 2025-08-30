class ProvinsiOption {
  final String key; // internal key (e.g., JABAR, DIY, BANTEN)
  final String name; // display name
  final String apiId; // slug for path variable (e.g., jabar, diy, banten)
  final String defaultKodeWilayah; // default plate prefix (e.g., D, AB, A)
  const ProvinsiOption(this.key, this.name, this.apiId, this.defaultKodeWilayah);
}

const List<ProvinsiOption> provinsiOptions = [
  ProvinsiOption('JABAR', 'Jawa Barat', 'jabar', 'D'),
  ProvinsiOption('DIY', 'DI Yogyakarta', 'diy', 'AB'),
  ProvinsiOption('BANTEN', 'Banten', 'banten', 'A'),
];

