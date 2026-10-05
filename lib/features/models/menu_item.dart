class CustomizationOption {
  final String id;
  final String name;
  final double extraPrice;

  CustomizationOption({
    required this.id,
    required this.name,
    this.extraPrice = 0.0,
  });
}

class CustomizationGroup {
  final String id;
  final String title;
  final bool isRequired;
  final List<CustomizationOption> options;

  CustomizationGroup({
    required this.id,
    required this.title,
    this.isRequired = false,
    required this.options,
  });
}

class MenuItem {
  final String id;
  final String kitchenId;
  final String name;
  final String description;
  final String category;
  final double basePrice;
  final int preparationTimeMinutes;
  bool isAvailable;
  final String imageUrl;
  final List<CustomizationGroup> customizationGroups;

  MenuItem({
    required this.id,
    required this.kitchenId,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.preparationTimeMinutes,
    this.isAvailable = true,
    required this.imageUrl,
    this.customizationGroups = const [],
  });

  MenuItem copyWith({
    String? id,
    String? kitchenId,
    String? name,
    String? description,
    String? category,
    double? basePrice,
    int? preparationTimeMinutes,
    bool? isAvailable,
    String? imageUrl,
    List<CustomizationGroup>? customizationGroups,
  }) {
    return MenuItem(
      id: id ?? this.id,
      kitchenId: kitchenId ?? this.kitchenId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      customizationGroups: customizationGroups ?? this.customizationGroups,
    );
  }
}
