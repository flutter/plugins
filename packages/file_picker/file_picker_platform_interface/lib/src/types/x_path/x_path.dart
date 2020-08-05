/// Cross platform path class
class XPath {
  /// XPath constructor
  XPath(this._path, {String name, int modified, int created}):
        _modified = modified,
        _created = created,
        _name = name;

  final String _path;
  final String _name;
  final int _modified;
  final int _created;

  String get path => _path;
  int get modified => _modified;
  int get created => _created;
  String get name => _name;
}