#!/bin/sh
help="please input ipa name"
help_pro="please input provision name like "



if [ -z $1 ]; then
echo $help_pro
exit -1
fi
provision_name=$1

if [ -z $2 ]; then
echo $help_pro
exit -1
fi
ipa_name=$2

#provision_name="miao_in_house.mobileprovision"
provision_name_tmp="${provision_name}_tmp"
cp ./$provision_name ./$provision_name_tmp
distribution_name="iPhone Distribution: Shanghai Gengshang Network Technology Co., Ltd."
echo "reset ipa name $ipa_name"
unzip $ipa_name.ipa

rm -rf ./Payload/$ipa_name.app/_CodeSignature
cp ./$provision_name ./Payload/$ipa_name.app/embedded.mobileprovision
/usr/libexec/PlistBuddy -x -c "print :Entitlements " /dev/stdin <<< $(security cms -D -i Payload/*.app/embedded.mobileprovision) > entitlements.plist
#input project build setttings [Code Signing Resource Rules Path] = $(SDKROOT)/ResourceRules.plist
/usr/bin/codesign -f -s "$distribution_name" --resource-rules ./Payload/$ipa_name.app/ResourceRules.plist --entitlements entitlements.plist ./Payload/$ipa_name.app

zip -qr New_$ipa_name.ipa Payload
echo "---------rm $provision_name"
rm ./$provision_name
echo "---------rm Payload"
rm -rf ./Payload
echo "---------rm Symbols"
rm -rf ./Symbols
echo "---------rm entitlements.plist"
rm  ./entitlements.plist
echo "---------mv $provision_name_tmp to $provision_name"
mv ./$provision_name_tmp ./$provision_name

echo "done"
