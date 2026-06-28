class ReciterModel {
  const ReciterModel({
    required this.identifier,
    required this.nameAr,
    required this.nameEn,
  });

  final String identifier;
  final String nameAr;
  final String nameEn;

  static const List<ReciterModel> reciters = [
    ReciterModel(
      identifier: 'ar.alafasy',
      nameAr: 'مشاري العفاسي',
      nameEn: 'Mishary Alafasy',
    ),
    ReciterModel(
      identifier: 'ar.abdulsamad',
      nameAr: 'عبد الصمد',
      nameEn: 'Abdul Samad',
    ),
    ReciterModel(
      identifier: 'ar.abdullahbasfar',
      nameAr: 'عبدالله بصفر',
      nameEn: 'Abdullah Basfar',
    ),
    ReciterModel(
      identifier: 'ar.hudhaify',
      nameAr: 'علي الحذيفي',
      nameEn: 'Ali Hudhaify',
    ),
  ];

  static ReciterModel byIdentifier(String id) {
    return reciters.firstWhere(
      (r) => r.identifier == id,
      orElse: () => reciters.first,
    );
  }
}
