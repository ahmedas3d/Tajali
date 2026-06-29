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
      identifier: 'ar.husary',
      nameAr: 'محمود خليل الحصري',
      nameEn: 'Mahmoud Khalil Al-Husary',
    ),
    ReciterModel(
      identifier: 'ar.mahermuaiqly',
      nameAr: 'ماهر المعيقلي',
      nameEn: 'Maher Al Muaiqly',
    ),
    ReciterModel(
      identifier: 'ar.abdurrahmaansudais',
      nameAr: 'عبدالرحمن السديس',
      nameEn: 'Abdurrahmaan As-Sudais',
    ),
    ReciterModel(
      identifier: 'ar.saoodshuraym',
      nameAr: 'سعود الشريم',
      nameEn: 'Saood Ash-Shuraym',
    ),
    ReciterModel(
      identifier: 'ar.abdulsamad',
      nameAr: 'عبدالباسط عبدالصمد',
      nameEn: 'Abdul Samad',
    ),
    ReciterModel(
      identifier: 'ar.shaatree',
      nameAr: 'أبو بكر الشاطري',
      nameEn: 'Abu Bakr Ash-Shaatree',
    ),
    ReciterModel(
      identifier: 'ar.muhammadayyoub',
      nameAr: 'محمد أيوب',
      nameEn: 'Muhammad Ayyoub',
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
    ReciterModel(
      identifier: 'ar.hanirifai',
      nameAr: 'هاني الرفاعي',
      nameEn: 'Hani Rifai',
    ),
  ];

  static ReciterModel byIdentifier(String id) {
    return reciters.firstWhere(
      (r) => r.identifier == id,
      orElse: () => reciters.first,
    );
  }
}
