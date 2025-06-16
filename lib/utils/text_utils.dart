class TextUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    
    // Supprime tous les caractères non numériques
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format: +XXX XX XX XX XX
    if (digits.length >= 10) {
      return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)} ${digits.substring(9, 11)}';
    }
    
    return phone;
  }

  static String formatAddress(String address) {
    if (address.isEmpty) return address;
    return capitalizeEachWord(address.trim());
  }

  static String formatName(String name) {
    if (name.isEmpty) return name;
    return capitalizeEachWord(name.trim());
  }
} 