part of firebase_dynamic_links;

class GoogleAnalyticsParameters {
  GoogleAnalyticsParameters._({
    @required this.campaign,
    this.content,
    @required this.medium,
    @required this.source,
    this.term,
  });

  final String campaign;
  final String content;
  final String medium;
  final String source;
  final String term;

  Map<String, dynamic> get _data => <String, dynamic>{
        'campaign': campaign,
        'content': content,
        'medium': medium,
        'source': source,
        'term': term,
      };
}
