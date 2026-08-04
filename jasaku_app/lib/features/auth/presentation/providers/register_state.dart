import 'dart:io';

class RegisterPortfolioEntry {
  String type;
  File? file;
  String url;
  String label;

  RegisterPortfolioEntry({
    this.type = 'image',
    this.file,
    this.url = '',
    this.label = '',
  });
}

class RegisterState {
  String phone = '';
  List<Map<String, dynamic>> selectedServices = [];
  String fullName = '';
  String nickname = '';
  String email = '';
  String password = '';
  String birthDate = '';
  String gender = '';
  String address = '';
  String domicile = '';
  String province = '';
  String city = '';
  String district = '';
  String village = '';
  String? profilePhotoPath;
  String? ktpPhotoPath;
  String? selfiePhotoPath;
  String? ijazahPhotoPath;
  List<Map<String, dynamic>> certificates = [];
  List<RegisterPortfolioEntry> portfolios = [];
  bool termsAgreed = false;

  // OCR KTP
  String? ocrNik;
  String? ocrFullName;
  String? ocrBirthPlace;
  String? ocrBirthDate;
  String? ocrAddress;
  String? ocrGender;
  String? ocrBloodType;
  String? ocrReligion;

  // Liveness
  Map<String, dynamic>? livenessData;
}
