npx react-native bundle \
    --platform android \
    --dev false \
    --entry-file src/basic/index.js \
    --bundle-output ./android/app/src/main/assets/basic.android.bundle \
    --assets-dest android/app/src/main/res/ \
    --config basic.metro.config.js

npx react-native bundle \
    --platform android \
    --dev false \
    --entry-file src/business/index.js \
    --bundle-output ./android/app/src/main/assets/business.android.bundle \
    --assets-dest android/app/src/main/res/ \
    --config business.metro.config.js