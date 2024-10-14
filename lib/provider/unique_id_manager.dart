class UniqueIdManager {
  // Map to store unique IDs for each item based on their quantities
  static final Map<String, List<String>> _uniqueIdMap = {};
  static final Map<String, int> _itemCounterMap = {}; // Counter for each item

  // Method to generate unique IDs for a given item and its quantity
  static void generateUniqueIds(String itemName, int quantity) {
    if (!_uniqueIdMap.containsKey(itemName)) {
      _uniqueIdMap[itemName] = [];
      _itemCounterMap[itemName] = 0; // Initialize counter for new items
    }

    // Generate unique IDs using both a counter and timestamp to ensure uniqueness
    for (int i = _uniqueIdMap[itemName]!.length; i < quantity; i++) {
      _itemCounterMap[itemName] = _itemCounterMap[itemName]! + 1;
      String uniqueId =
          '${itemName}_${DateTime.now().millisecondsSinceEpoch}_${_itemCounterMap[itemName]}';
      _uniqueIdMap[itemName]!.add(uniqueId);
    }
  }

  // Method to get unique IDs for a given item and quantity
  static List<String> getUniqueIdsForItem(String itemName, int quantity) {
    generateUniqueIds(itemName, quantity);
    return _uniqueIdMap[itemName]!.sublist(0, quantity);
  }

  // Method to get a single unique ID for a given item and its index
  static String getUniqueIdForIndex(String itemName, int index) {
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
    _itemCounterMap.clear(); // Clear counters too
  }
}
