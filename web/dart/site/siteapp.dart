part of SiteLib;

// ALL OF THIS CODE IS HORRIBLE - I DIDNT CARE TOO MUCH ABOUT THE INTERFACE STUFF IN THIS PROJECT
// INSTEAD I FOCUSED ON THE FUN DRAWING STUFF - LOOK AT THAT INSTEAD!
class SiteApp {
  TopMenuController _topMenu;
  DrawingTool _drawingModule;

  SiteApp( this._drawingModule ) {
    // Check if on the site
    _topMenu = new TopMenuController();
    new ThumbnailList();
    _setupToolbar();
  }

  void _setupToolbar(){
    if( this._drawingModule == null ) return;

    querySelector("#nu-interface-save-svg").onClick.listen( _onSvgSave );
    querySelector("#nu-interface-save-image").onClick.listen( _onSaveImage );
    querySelector("#nu-interface-publish").onClick.listen( _displaySubmissionForm);
    querySelector("#submission-form .submit").onClick.listen( _onPublishRequested );
  }


  /// Save out an SVG version of the mandala
  void _onSvgSave(e) {
    // Create the SVG
    Svg.SvgElement svg = _drawingModule.saveSvg();

    // Convert to blob
    var blob = new Blob([svg.outerHtml], "image/svg+xml");
//
//    // Open preview window with download link
//    var previewWindow = window.open("", "");
//    var a = new AnchorElement(href: Url.createObjectUrlFromBlob( blob ) );
//    a.text = "Download";
//    a.style.display = "block";
//    a.download = "mandala.svg";
//    a.onClick.listen((e) { // clenaup
//      new Future.delayed(new Duration(seconds:2), () => Url.revokeObjectUrl(a.href));
//    });
//
//    // Add the <a> tag, followed by the SVG
//    previewWindow.document.body.nodes.add(a);
//    previewWindow.document.body.nodes.add(svg);

    // Open window with just SVG data as XML
    window.open(Url.createObjectUrlFromBlob( blob ), "svg-text");
  }

  /// Saves out an image representation of the mandala
  void _onSaveImage(e) {
//    print("ImageSave");
//    ImageElement img = new ImageElement();
//    img.src = _drawingModule.getDataUrl();

    var newWindow = window.open(_drawingModule.getDataUrl(), "");
//    newWindow.document.body.nodes.add(img);
  }

  void _displaySubmissionForm( e ) {
    HtmlElement form = querySelector("#submission-form");
    if( querySelector("body").dataset["isLoggedIn"] == "false" ) {
      if( form.style.display == "flex" ) {
        form.style.display = "none";
        return;
      }
      form.style.display = "flex";
      querySelector("#submission-form .ui.form .info.message .header").text = "You must be signed in to publish";
      querySelector("#submission-form .ui.form .info.message").style.display = "block";
      querySelector("#submission-form .submit").style.display = "none";
      querySelector("#submission-form .field").style.display = "none";
      return;
    }

    // Renable the submit button - hide the info box
    querySelector("#submission-form .ui.form .info.message").style.display = "none";
    querySelector("#submission-form .submit").style.pointerEvents = "auto";
    querySelector("#submission-form .submit").style.opacity = "1";

    form.style.display = form.style.display == "flex" ? "none" : "flex";
  }

  void _onPublishRequested(e) {
    // Disable the button
    querySelector("#submission-form .submit").style.pointerEvents = "none";
    querySelector("#submission-form .submit").style.opacity = "0.25";

    //submission-form-title
    String imageData = _drawingModule.getDataUrl();
    HttpRequest.postFormData("/mandalas/create_from_tool", {
        "image_data": imageData,
        "title"     : (querySelector("#submission-form-title") as InputElement).value,
        "id"        : _drawingModule.mandalaId == null ? "" : _drawingModule.mandalaId
    }).then( (HttpRequest req ) {
      var responseJson = JSON.decode( req.responseText );
      querySelector("#submission-form .ui.form .info.message").style.display = "block";
      if( responseJson['status'] == false ) {
        querySelector("#submission-form .ui.form .info.message .header").text = responseJson['error'];
      } else {
        querySelector("#submission-form .ui.form .info.message .header").text = "All done";
        new Future.delayed(new Duration(seconds:1), () => window.location.assign( "/mandalas/${responseJson['info']['id']}" ) );
      }

    });
  }
}