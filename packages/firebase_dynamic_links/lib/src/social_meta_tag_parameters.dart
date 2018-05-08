part of firebase_dynamic_links;

class SocialMetaTagParameters {
  SocialMetaTagParameters({this.description, this.imageUrl, this.title});

  final String description;
  final Uri imageUrl;
  final String title;

  Map<String, dynamic> get _data => <String, dynamic>{
        'description': description,
        'imageUrl': imageUrl?.toString(),
        'title': title,
      };
}
