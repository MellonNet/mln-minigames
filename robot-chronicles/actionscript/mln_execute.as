function execute() {
  this.serverRequest = new com.lego.framework.net.requests.XMLRequest_XOR(
    com.lego.framework.application.Configuration.file.carrierService.serviceUrl
      + "/"
      + this._service,
  );
  this.serverRequest.addEventListener(
    com.lego.framework.net.requests.ServerRequestEvent.COMPLETE,
    mx.utils.Delegate.create(this, this.onComplete),
  );
  this.serverRequest.addEventListener(
    com.lego.framework.net.requests.ServerRequestErrorEvent.ERROR,
    mx.utils.Delegate.create(this, this.onError),
  );
  this.serverRequest.XORKey = com.lego.framework.application.Configuration.MLN_CARRIERSERVICE_XOR_KEY;
  this.serverRequest.postVars.awardCategory = com.lego.framework.application.Configuration.file.carrierService.awardCategory;
  this.serverRequest.postVars.awardCode = this._awardCode;
  this.serverRequest.postVars.localeId = com.lego.framework.application.Configuration.file.carrierService.localeId;
  this.serverRequest.execute();
}
