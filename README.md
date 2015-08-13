# Ankoromochi

konashi (Koshian) にI2C接続の加速度センサ(ADXL345)をつないだ場合の動作確認用サンプルアプリです

* konashi2.0 もしくは Koshian で動作します。  
* konashi(Koshian)とADXL345は、PIO6,7を使用してI2C接続させてください。 I2Cの2本の信号線(SDA，SCL)はプルアップしておく必要がありますが、秋月電子のモジュールの場合、モジュール内でプルアップ済みのものが販売されています(たとえば  http://akizukidenshi.com/catalog/g/gM-06724/ )。その場合は、SDA，SCLをそのままつなげば動作します。
* Uzuki センサーシールドを使用している場合は、シールドを接続すれば動作します。

アプリを起動したら、画面上の「Find」ボタンを押し、konashi (Koshian) の番号を確認の上で接続して下さい。
