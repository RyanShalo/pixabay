class PixabayImage {
  final int id;
  final String previewURL;
  final String largeImageURL;
  final String user;
  final int likes;
  final int views;

  PixabayImage({
    required this.id,
    required this.previewURL,
    required this.largeImageURL,
    required this.user,
    required this.likes,
    required this.views,
  });

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: json['id'],
      previewURL: json['previewURL'],
      largeImageURL: json['largeImageURL'],
      user: json['user'],
      likes: json['likes'],
      views: json['views'],
    );
  }
}