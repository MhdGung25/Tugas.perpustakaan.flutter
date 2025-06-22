import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppKey {
  static String USER_ID = "user_id";
  static String USER_NAME = "user_name";
  static String USER_PICTURE = "picture";
  static String USER_EMAIL = "email";
  static String USER_PASSWORD = "user_password";
  static String USER_SCH_TYPE = "schedule_type";
  static String USER_PATH_KEY = "path_key";
  static String USER_RECORD_KEY = "record_key";
  static String USER_DARKMODE_AVAILABLE = "user_darkmode_available";
  static String USER_IS_ACTIVE = "user_is_active";
  static String USER_SALES_ID = "user_sales_id";
  static String USER_STORE_ID = "store_id";
}

class AppKeyEncrypted {
  static String TOKEN = "token";
  static String REFRESH_TOKEN = "refresh_token";
  static String SSO_KEY = "key";
}

class Session {
  SharedPreferences? preferences;
  EncryptedSharedPreferences? encryptedSharedPreferences;

  putString(key, String value) async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!.setString(key, value);
  }

  putInt(key, int value) async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!.setInt(key, value);
  }

  putDouble(key, double value) async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!.setDouble(key, value);
  }

  putBoolean(key, bool value) async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!.setBool(key, value);
  }

  Future<String> getString(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = (prefs.getString(key) ?? "");
    return value;
  }

  Future<int> getInt(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = (prefs.getInt(key) ?? 0);
    return value;
  }

  Future<double> getDouble(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double value = (prefs.getDouble(key) ?? 0);
    return value;
  }

  getBoolean(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = (prefs.getBool(key) ?? false);
    return value;
  }

  putEncryptedString(key, String value) async {
    encryptedSharedPreferences ??= EncryptedSharedPreferences();
    return encryptedSharedPreferences!.setString(key, value);
  }

  getEncryptedString(key) async {
    encryptedSharedPreferences ??= EncryptedSharedPreferences();
    String value = encryptedSharedPreferences!.getString(key) as String;
    return (value == "");
  }

  clearAllEncrypted() async {
    encryptedSharedPreferences ??= EncryptedSharedPreferences();
    return encryptedSharedPreferences!.clear();
  }

  removeSF(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  clearSF() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.clear();
  }
}
