part of google_maps_flutter_web;

///
class CircleController {

   GoogleMap.Circle _circle;

  bool consumeTapEvents = false;

  ui.VoidCallback onTap;

  ///
  CircleController({@required GoogleMap.Circle circle, this.consumeTapEvents, this.onTap}){
    _circle = circle;
   if(consumeTapEvents) {
     circle.onClick.listen((event) {
       if(onTap !=null) onTap.call();
     });
   }
  }

  set circle (GoogleMap.Circle circle) => {_circle = circle};

  ///TODO
  void update(GoogleMap.CircleOptions options) {
    _circle.options = options;
  }

  void remove() {
    _circle.visible = false;
    _circle.radius = 0;
    _circle.map = null;
    _circle = null;
    //_circle.remove();
  }
}