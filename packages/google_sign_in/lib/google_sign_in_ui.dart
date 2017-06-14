import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  _GoogleSignInButtonState createState() => new _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  @override
  Widget build(BuildContext context) {
    // TODO why can't I load the image in the example, the path won't work
    // TODO Do I need so specify an image bundle?
    // TODO extract into consts
    // Unable to load asset: resources/google_signin_buttons/btn_google_dark_disabled.png
    const String imagePath = 'resources/google_signin_buttons/btn_google_dark_disabled.png';

    Image image = new Image.asset(
      imagePath,
      fit: BoxFit.cover,
      bundle: DefaultAssetBundle.of(context), // TODO won't work
    );

    Row row = new Row(
      children: <Widget>[
        image,
        new Text('Sign in with Google'),
      ],
    );

    return new RaisedButton(
      color: Colors.white,
      child: row,
      onPressed: widget.onPressed,
    );
  }

  void _onPressed() {
  }
}
