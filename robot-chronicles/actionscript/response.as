this.MLNCallback = function(event) {
  trace("Received call back:" + event.status + event);
  var info = event.data.result.message.attributes;
  this.parent.confirm(
    info.title.toUpperCase(),
    info.text.toUpperCase(),
    this,
    function() {
      getURL(info.link.toString(),"");
    },
    null,
    null,
    info.buttonText.toUpperCase(),
    dialogue("INT_buttonMLNNo"),
  );
  for(var _loc3_ in event.data.result.items) {
    this.printItem(event.data.result.items[_loc3_]);
  }
};

this.printItem = function(itemData) {
  if(!itemData) {
    return undefined;
  }
  var _loc4_ = this.parent.border.confirm.items;
  var _loc3_ = _loc4_.getNextHighestDepth();
  var _loc2_ = _loc4_.createEmptyMovieClip("item" + _loc3_,_loc3_);
  _loc2_._x = 270 + _loc3_ * 70;
  _loc2_._y = 200;
  _loc2_.loadMovie(itemData.attributes.thumbnail);
};
