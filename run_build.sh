#!/bin/zsh

cd packages
for x in _core_layer _domain_layer _data_layer _presentation_layer _di_layer; do
	cd $x
	flutter pub get
	grep -q build_runner pubspec.yaml && flutter pub run build_runner build --delete-conflicting-outputs
	grep -q flutter_localizations pubspec.yaml && flutter gen-l10n
	cd ..
done
cd ..
flutter pub get
