part of firebase_dynamic_links;

enum ShortDynamicLinkPathLength {unguessable, short}

class DynamicLinkComponentsOptions {
  DynamicLinkComponentsOptions({this.shortDynamicLinkPathLength});

  ShortDynamicLinkPathLength shortDynamicLinkPathLength;

  Map<String, dynamic> get _data => <String, dynamic>{
        'shortDynamicLinkPathLength': shortDynamicLinkPathLength?.index,
      };
}
