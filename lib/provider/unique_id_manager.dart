class UniqueIdManager {
  // Map to store unique IDs for each item based on their quantities
  static final Map<String, List<String>> _uniqueIdMap = {};

  // Method to generate unique IDs for a given item and its quantity
  static void generateUniqueIds(String itemName, int quantity) {
    if (!_uniqueIdMap.containsKey(itemName)) {
      _uniqueIdMap[itemName] = [];
    }

    // Generate IDs only if necessary to avoid duplicates
    for (int i = _uniqueIdMap[itemName]!.length; i < quantity; i++) {
      String uniqueId =
          '${itemName}_${DateTime.now().millisecondsSinceEpoch}_$i';
      _uniqueIdMap[itemName]!.add(uniqueId);
    }
  }

  // Method to get unique IDs for a given item and quantity
  static List<String> getUniqueIdsForItem(String itemName, int quantity) {
    // Ensure the unique IDs are generated for the given quantity
    generateUniqueIds(itemName, quantity);

    // Return a sublist of the required unique IDs for this item
    return _uniqueIdMap[itemName]!.sublist(0, quantity);
  }

  // Method to get a single unique ID for a given item and its index
  static String getUniqueIdForIndex(String itemName, int index) {
    // Ensure the unique IDs are generated for the given index
    generateUniqueIds(itemName, index + 1);

    return _uniqueIdMap[itemName]![index];
  }

  // Method to remove unique IDs for a given item and quantity
  static void removeUniqueIds(String itemName, int quantity) {
    if (_uniqueIdMap.containsKey(itemName)) {
      for (int i = 0; i < quantity && _uniqueIdMap[itemName]!.isNotEmpty; i++) {
        _uniqueIdMap[itemName]!.removeLast();
      }
    }
  }

  // Method to clear all unique IDs (for resetting, if needed)
  static void clearAllUniqueIds() {
    _uniqueIdMap.clear();
  }
}
