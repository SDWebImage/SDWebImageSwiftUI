# carthage.sh
# Usage example: ./carthage.sh build --platform iOS

set -euo pipefail
 
xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT
 
# For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.

echo 'EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
echo 'EXCLUDED_ARCHS[sdk=appletvsimulator*] = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
echo 'EXCLUDED_ARCHS[sdk=watchsimulator*] = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"
carthage "$@"