# Building JS8Call Plus on a Mac

Build on the Mac itself. Do not use GitHub Actions or any other outside
build service.

The steps below are the ones in `.github/workflows/ci-macos.yml`, written
out to run in Terminal on your own Mac. GitHub's Macs built both versions
with them at commit ff51a91d.

The Apple silicon steps were also run on a real Mac (macOS 27.2,
Xcode 27.2, CMake 4.5.0) at commit 21476d48. The signing steps for
Apple silicon, and the "Signing for release" section, come from that
run; the workflow does not have them.

The Intel steps have not been run on a real Mac yet. They use a Python
virtual environment for Qt's installer, which the workflow does not.

Use the section for your Mac:

- Apple silicon (M1 and later): gives `JS8Call-Plus-1.0.1-AppleSilicon.dmg`
- Intel: gives `JS8Call-Plus-1.0.1-Intel.dmg`

## What the Mac needs

- Xcode, the full app from the App Store, opened once. The command line
  tools alone are not enough: the build uses `xcodebuild`.
- CMake, with `cmake` working in Terminal.
- Intel Mac only: Python 3 (`python3` in Terminal).
- Your Mac password: two steps use `sudo` to put the libraries in
  `/usr/local`.
- Only for a .dmg that other people will download: a paid Apple
  Developer Program membership. See "Signing for release" below.

The build downloads:

- js8lib and ffmpeg from the JS8Call-improved js8lib releases:
  https://github.com/JS8Call-improved/js8lib/releases/tag/lib%2F3.0
- Intel Mac only: Qt 6.9.3 from the Qt download servers.

## Get the code

Terminal, in the folder where the code should go:

```sh
git clone https://github.com/RobBobbins/JS8Call-Plus.git
cd JS8Call-Plus
```

Every step below runs inside that `JS8Call-Plus` folder.

## Apple silicon (M1 and later)

1. Libraries (js8lib with Qt, and ffmpeg):

```sh
curl --location --output /tmp/js8lib3.0-MacOS_with_Qt.tar.gz https://github.com/JS8Call-improved/js8lib/releases/download/lib%2F3.0/js8lib3.0-MacOS_with_Qt.tar.gz
(cd /tmp && tar zxf /tmp/js8lib3.0-MacOS_with_Qt.tar.gz)
sudo mv /tmp/js8lib /usr/local/js8lib

curl --location --output /tmp/ffmpeg_MacOS_arm64.tar.gz https://github.com/JS8Call-improved/js8lib/releases/download/lib%2F3.0/ffmpeg_MacOS_arm64.tar.gz
(cd /tmp && tar zxf /tmp/ffmpeg_MacOS_arm64.tar.gz)
sudo mv /tmp/ffmpeg /usr/local/ffmpeg
```

2. Configure and build:

```sh
mkdir -p build && cd build
cmake -G Xcode -DCMAKE_PREFIX_PATH="/usr/local/js8lib" ..
xcodebuild -scheme JS8Call -configuration Release
cd ..
```

3. Sign the whole app ad hoc, then check the signature. Without this the
   check fails on the Qt frameworks the build copies into the app
   ("code has no resources but signature indicates they must be
   present"). For a .dmg other people will download, skip this step and
   step 5 and use "Signing for release" below instead:

```sh
codesign --force --deep --sign - "build/Release/JS8Call-Plus.app"
codesign --verify --deep --strict --verbose=2 "build/Release/JS8Call-Plus.app"
```

4. Check the app. `lipo` should print `arm64`:

```sh
app="build/Release/JS8Call-Plus.app"
test -x "$app/Contents/MacOS/JS8Call-Plus" && echo "program is there"
lipo -archs "$app/Contents/MacOS/JS8Call-Plus"
ls "$app/Contents/Frameworks" | grep -i -E "avcodec|avformat|Qt" | head -20
```

5. Make the .dmg. On macOS 27 `hdiutil` prints a warning that this form
   of the command is deprecated; it still works:

```sh
hdiutil create -volname "JS8Call Plus" -srcfolder "build/Release/JS8Call-Plus.app" -format UDZO "JS8Call-Plus-1.0.1-AppleSilicon.dmg"
```

## Intel

1. js8lib (the Intel package has no Qt):

```sh
curl --location --output /tmp/js8lib-intel.tar.gz https://github.com/JS8Call-improved/js8lib/releases/download/lib%2F3.0/js8lib3.0-MacOS_Intel.tar.gz
mkdir -p /tmp/js8lib-intel
tar zxf /tmp/js8lib-intel.tar.gz -C /tmp/js8lib-intel
inc=$(find /tmp/js8lib-intel -maxdepth 3 -type d -name include | head -1)
sudo mv "$(dirname "$inc")" /usr/local/js8lib
ls /usr/local/js8lib /usr/local/js8lib/lib
```

2. Qt 6.9.3, installed into `~/Qt`:

```sh
python3 -m venv ~/aqt-venv
~/aqt-venv/bin/pip install aqtinstall
~/aqt-venv/bin/python -m aqt install-qt mac desktop 6.9.3 clang_64 -m qtmultimedia qtserialport -O "$HOME/Qt"
ls "$HOME/Qt/6.9.3"
```

3. Configure and build. The build is unsigned, because js8lib's Intel
   libusb is unsigned and Xcode's own signing step fails on it:

```sh
mkdir -p build && cd build
cmake -G Xcode -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_PREFIX_PATH="/usr/local/js8lib;$HOME/Qt/6.9.3/macos" ..
xcodebuild -scheme JS8Call -configuration Release CODE_SIGNING_ALLOWED=NO
cd ..
```

4. Sign the whole app ad hoc, then check the signature:

```sh
codesign --force --deep --sign - "build/Release/JS8Call-Plus.app"
codesign --verify --deep --strict --verbose=2 "build/Release/JS8Call-Plus.app"
```

5. Check the app. `lipo` should print `x86_64`:

```sh
app="build/Release/JS8Call-Plus.app"
test -x "$app/Contents/MacOS/JS8Call-Plus" && echo "program is there"
lipo -archs "$app/Contents/MacOS/JS8Call-Plus"
ls "$app/Contents/Frameworks" | grep -i -E "avcodec|avformat|Qt" | head -20
ls "$app/Contents/PlugIns/multimedia"
```

6. Make the .dmg:

```sh
hdiutil create -volname "JS8Call Plus" -srcfolder "build/Release/JS8Call-Plus.app" -format UDZO "JS8Call-Plus-1.0.1-Intel.dmg"
```

## Signing for release

Skip this section for a build you only run yourself. Use it for a .dmg
other people will download: it signs the app with a Developer ID and has
Apple notarize it, so their Macs open it without a warning.

It needs a paid Apple Developer Program membership. These steps were run
for the Apple silicon build. They have not been run for the Intel build.

### Set up once on the Mac

1. A Developer ID Application certificate in your keychain. Only the
   Account Holder of the membership can create one.

   In Xcode: Settings > Apple Accounts > your team > Manage Certificates
   > + > Developer ID Application.

   If Xcode refuses ("This operation can only be performed by the
   Account Holder") although you are the Account Holder, create it on
   Apple's site instead. Make a request file in Keychain Access
   (Keychain Access > Certificate Assistant > Request a Certificate From
   a Certificate Authority, saved to disk), upload it at
   https://developer.apple.com/account/resources/certificates/add under
   Developer ID Application, download the `.cer` and double-click it.

   Check it. This should list one "Developer ID Application" line:

```sh
security find-identity -v -p codesigning
```

   If it says `0 valid identities found`, the "Developer ID - G2"
   intermediate certificate is missing. Xcode has a copy:

```sh
security import "/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/DeveloperIDCA-G2.cer" -k ~/Library/Keychains/login.keychain-db
```

2. A saved login for notarization. Make an app-specific password at
   https://account.apple.com under Sign-In and Security > App-Specific
   Passwords, and copy it when Apple shows it (it looks like
   `abcd-efgh-ijkl-mnop` and is shown only once). Then run this with
   your own Apple ID and Team ID:

```sh
xcrun notarytool store-credentials "js8-notary" --apple-id "you@example.com" --team-id "TEAMID"
```

   When it asks for the password, paste the app-specific password, not
   your Apple account password. Nothing shows as you paste.

### For each release

Do these after "Configure and build", in place of the ad hoc signing
step and the "Make the .dmg" step. Put your own certificate name in the
first line, as `security find-identity` printed it.

1. Sign every library, every framework, then the app. The app gets the
   audio input entitlement, which the hardened runtime needs before it
   allows the microphone:

```sh
id="Developer ID Application: Your Name (TEAMID)"
app="build/Release/JS8Call-Plus.app"

cat > build/JS8Call-Plus.entitlements <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.device.audio-input</key>
    <true/>
</dict>
</plist>
EOF

find "$app/Contents/Frameworks" "$app/Contents/PlugIns" -type f -name "*.dylib" -exec codesign --force --timestamp --options runtime --sign "$id" {} \;
for fw in "$app"/Contents/Frameworks/*.framework; do codesign --force --timestamp --options runtime --sign "$id" "$fw"; done
codesign --force --timestamp --options runtime --entitlements build/JS8Call-Plus.entitlements --sign "$id" "$app"
codesign --verify --deep --strict --verbose=2 "$app"
```

   The first time, macOS asks to let `codesign` use the key: enter your
   Mac password and click Always Allow. If `codesign` stops with
   "timestamps differ by ... seconds", run the commands again.

2. Make the .dmg and sign it (use the Intel file name on an Intel Mac):

```sh
dmg="JS8Call-Plus-1.0.1-AppleSilicon.dmg"
hdiutil create -ov -volname "JS8Call Plus" -srcfolder "$app" -format UDZO "$dmg"
codesign --force --timestamp --sign "$id" "$dmg"
```

3. Send it to Apple and wait for the answer, which should be
   `status: Accepted`. The first one from a new developer account took
   about 40 minutes; if the wait runs out, the submission is not lost
   and `xcrun notarytool wait` with the printed id picks it up again:

```sh
xcrun notarytool submit "$dmg" --keychain-profile "js8-notary" --wait
```

4. Attach Apple's answer to the .dmg and check it. `spctl` should print
   `accepted` and `source=Notarized Developer ID`:

```sh
xcrun stapler staple "$dmg"
spctl -a -t open --context context:primary-signature -vv "$dmg"
```

## The finished file

The .dmg is in the `JS8Call-Plus` folder.

A .dmg that was only signed ad hoc is blocked on first open: go to
System Settings > Privacy & Security and click Open Anyway. A .dmg that
went through "Signing for release" opens without that step.
