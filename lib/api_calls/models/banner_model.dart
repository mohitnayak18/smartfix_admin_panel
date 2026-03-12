class BannerModel {
  String id;
  String imageUrl;
  bool active;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.active,
  });

  factory BannerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BannerModel(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      active: data['active'] ?? true,
    );
  }
}