# !/bin/bash
SOURCEIPA="$1"
MOBILEPROV="$2"
DYLIB="$3"

cd ${SOURCEIPA%/*}

security find-identity -v -p codesigning > cers.txt
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ "iPhone Developer" ]]; then
      DEVELOPER=${line:47:${#line}-48}
    fi
done < cers.txt

unzip -qo "$SOURCEIPA" -d extracted

APPLICATION=$(ls extracted/Payload/)

echo "Copying dylib and mobileprovision"
cp "$DYLIB" "extracted/Payload/$APPLICATION/${DYLIB##*/}"
cp "$MOBILEPROV" "extracted/Payload/$APPLICATION/embedded.mobileprovision"

echo "Insert dylib into Mach-O file"
yololib "extracted/Payload/$APPLICATION/${APPLICATION%.*}" "${DYLIB##*/}"

echo "Resigning with certificate: $DEVELOPER"
find -d extracted  \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > directories.txt
security cms -D -i "extracted/Payload/$APPLICATION/embedded.mobileprovision" > t_entitlements_full.plist
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' t_entitlements_full.plist > t_entitlements.plist
while IFS='' read -r line || [[ -n "$line" ]]; do
    /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "t_entitlements.plist"  "$line"
done < directories.txt

echo "Creating the Signed IPA"
cd extracted
zip -qry ../extracted.ipa *
cd ..

rm -rf "extracted"
rm directories.txt
rm cers.txt
rm t_entitlements.plist
rm t_entitlements_full.plist
echo "Installing APP to your iOS Device"
mobiledevice install_app extracted.ipa

# rm extracted.ipa
