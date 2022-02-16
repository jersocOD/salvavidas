#!/bin/bash

echo  "                "
echo ****************FLUTTER APP RELEASE GENERATOR*******************
#read -p "Enter version(0.0.1+15): " version
commands_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
project_dir="$(dirname "$commands_dir")"

echo "Retrieving Flutter App Info..."

# include parse_yaml function
. $commands_dir/parse_yaml.sh
eval $(parse_yaml $project_dir/pubspec.yaml)


echo ""
echo $name | tr a-z A-Z
echo $description
echo "Version: $version"
echo "Project Location: $project_dir"

cd "$project_dir/outputs/android"
mkdir -p "$version"
cd "$project_dir/outputs/ios"
mkdir -p "$version"


echo "******Preparing for Release******"

echo "********Cleaning Project*********"
cd $project_dir
flutter clean


echo "********Deploying for IOS********"
flutter build ipa --release --obfuscate --split-debug-info="$project_dir/outputs/ios/$version"
 open "$project_dir/build/ios/archive/Runner.xcarchive"
osascript -e 'display notification "'$name' ready to be archived." with title "iOS Build Succeeded"'



# echo "**Archiving IOS App Simultaneously**"
# sh -m $commands_dir/ios_archive.sh &

echo "******Deploying for Android******"
flutter build appbundle --obfuscate --split-debug-info="$project_dir/outputs/android/$version"

echo "******Generating APK******."
cd "$project_dir/build/app/outputs/bundle/release"
apk_path="$project_dir/build/app/outputs/bundle/release/app-release.apks"
java -jar "/Users/usuario/Development/bundletool-all-1.2.0.jar" build-apks --bundle=$project_dir/build/app/outputs/bundle/release/app-release.aab --output=$apk_path --mode=universal

unzip $apk_path -x toc.pb
rm $apk_path

mv universal.apk $name-release.apk
mv app-release.aab $name-release.aab

# unzip $apk_path -d apks


cd $project_dir
osascript -e 'display notification "'$name' ready to be uploaded." with title "Android Build Succeeded"'
#     open "https://appstoreconnect.apple.com/apps/1524711553/testflight/ios"
#     open "https://play.google.com/console/u/0/developers/7303397817458829857/app/4974320955071770680/tracks/4700044202158792870/create"
open "$project_dir/build/app/outputs/bundle/release/"

echo "*******Returning to Debug********"
#     sed -i '' "s/$release_boolean_in_true/$release_boolean_in_false/g" "$project_dir/lib/main.dart"

echo "************Finished*************" 