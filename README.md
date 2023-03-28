# Installation





```sh
git clone https://github.com/PythonSwiftLink/Swiftonize-CLI

xcodebuild \
    -project './Swiftonize-CLI/SwiftonizeCLI/SwiftonizeCLI.xcodeproj' \
    -config Release \
    -scheme 'SwiftonizeCLI' \
    -archivePath ./archive archive

cp archive.xcarchive/Products/usr/local/bin/SwiftonizeCLI swiftonize
cp -R Swiftonize-CLI/python-stdlib ./
cp -R Swiftonize-CLI/python-extra ./

rm -rf Swiftonize-CLI
rm -rf archive.xcarchive
```

