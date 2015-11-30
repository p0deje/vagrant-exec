## 0.5.3 (Unreleased)

* Support Windows guests

## 0.5.2

* Allow to configure binstubs directory (#11)

## 0.5.1

* Fixed binstubs for defined primary VM (#10 thanks @mikechau)

## 0.5.0

* Added binstubs support

## 0.4.1

* Fixed problem with environment variable values containing spaces by wrapping them in quotes
* Ensured `:prepend` option is added in the end of constructed command

## 0.4.0

* Brand new Commands API (#5)

## 0.3.1

* Ensure `--` is removed from command (#2)

## 0.3.0

* Renamed `:folder` option to `:root`
* Replaced `:bundler` option with `:prepend_with`
* Updated to work on Vagrant 1.4.1

## 0.2.1

* Changed plugin name from "Vagrant Exec" to "vagrant-exec"
* Added (dirty) fix to make it work on Vagrant 1.4
* Added MIT license

## 0.2.0

* Added support for exporting environment variables via `config.exec.env`
* Removed `--machine` switch
* Fixed handling of `--help` switch

## 0.1.0

* Initial release
