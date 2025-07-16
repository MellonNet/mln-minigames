function execute() {
  super.execute();
  this.iXML.onLoad = mx.utils.Delegate.create(this,this.onLoadHandler);
  var _loc3_ = new LoadVars();
  for(var _loc4_ in this.postVars) {
    _loc3_[_loc4_] = com.lego.framework.net.encryption.XOR.encrypt(this.postVars[_loc4_],this._XORKey);
  }
  _loc3_.sendAndLoad(this._url,this.iXML);
}
