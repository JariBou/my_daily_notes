class DataStorage {
  static Map<String, dynamic> data = {};

  static void storeData(String key, dynamic value) {
    if (data.containsKey(key)){
      data[key] = value;
    } else {
      data.addAll({key: value});
    }
  }

  static dynamic getData(String key) {
    return data[key];
  }

}