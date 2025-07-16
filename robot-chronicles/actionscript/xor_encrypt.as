static function encrypt(Input, key) {
var _loc1_ = com.lego.framework.net.encryption.XOR.UTF8Encode(Input);
return com.lego.framework.net.encryption.XOR.EncodeBase64(_loc1_,key);
}

static function UTF8Encode(string) {
  var _loc2_ = new String();
  var _loc3_ = 0;
  var _loc1_;
  while(_loc3_ < string.length) {
    _loc1_ = string.charCodeAt(_loc3_);
    if(_loc1_ < 128) {
      _loc2_ += String.fromCharCode(_loc1_);
    } else if(_loc1_ > 127 && _loc1_ < 2048) {
      _loc2_ += String.fromCharCode(_loc1_ >> 6 | 0xC0);
      _loc2_ += String.fromCharCode(_loc1_ & 0x3F | 0x80);
    } else {
      _loc2_ += String.fromCharCode(_loc1_ >> 12 | 0xE0);
      _loc2_ += String.fromCharCode(_loc1_ >> 6 & 0x3F | 0x80);
      _loc2_ += String.fromCharCode(_loc1_ & 0x3F | 0x80);
    }
    _loc3_ = _loc3_ + 1;
  }
  return _loc2_;
}

static function EncodeBase64(Input, key) {
  var _loc5_ = new String();
  var _loc6_ = Number(Input.length);
  var _loc3_ = 0;
  var _loc1_ = 0;
  while(_loc1_ < _loc6_) {
    _loc3_ = (Input.charCodeAt(_loc1_) ^ key.charCodeAt(_loc1_ % key.length)) >> 2;
    _loc5_ += com.lego.framework.net.encryption.XOR.a_B64Chars[_loc3_];
    if(_loc6_ - _loc1_ == 1) {
      _loc3_ = (Input.charCodeAt(_loc1_) ^ key.charCodeAt(_loc1_ % key.length)) << 4 & 0x30;
      _loc5_ += com.lego.framework.net.encryption.XOR.a_B64Chars[_loc3_];
      _loc5_ += "==";
      _loc1_ = _loc1_ + 1;
    } else if(_loc6_ - _loc1_ == 2) {
      _loc3_ = (Input.charCodeAt(_loc1_) ^ key.charCodeAt(_loc1_ % key.length)) << 4 & 0x30 | (Input.charCodeAt(_loc1_ + 1) ^ key.charCodeAt((_loc1_ + 1) % key.length)) >> 4;
      _loc5_ += com.lego.framework.net.encryption.XOR.a_B64Chars[_loc3_];
      _loc3_ = Input.charCodeAt(_loc1_ + 1) ^ key.charCodeAt((_loc1_ + 1) % key.length);
      _loc3_ = _loc3_ << 2 & 0x3C;
      _loc5_ += com.lego.framework.net.encryption.XOR.a_B64Chars[_loc3_];
      _loc5_ += "=";
      _loc1_ += 2;
    } else {
      _loc3_ = (Input.charCodeAt(_loc1_) ^ key.charCodeAt(_loc1_ % key.length)) << 4 & 0x30 | (Input.charCodeAt(_loc1_ + 1) ^ key.charCodeAt((_loc1_ + 1) % key.length)) >> 4;
      _loc5_ += com.lego.framework.net.encryption.XOR.a_B64Chars[_loc3_];
      _loc3_ = (Input.charCodeAt(_loc1_ + 1) ^ key.charCodeAt((_loc1_ + 1) % key.length)) << 2 & 0x3C | (Input.charCodeAt(_loc1_ + 2) ^ key.charCodeAt((_loc1_ + 2) % key.length)) >> 6;
      _loc5_ += com.lego.framework.net.encryption.XOR.a_B64Chars[_loc3_];
      _loc3_ = (Input.charCodeAt(_loc1_ + 2) ^ key.charCodeAt((_loc1_ + 2) % key.length)) & 0x3F;
      _loc5_ += com.lego.framework.net.encryption.XOR.a_B64Chars[_loc3_];
      _loc1_ += 3;
    }
    _loc1_;
  }
  return _loc5_;
}
