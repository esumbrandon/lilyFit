#!/bin/bash

# Quick Start Guide for LilyFit Integration Tests
# This script demonstrates how to run your first integration test

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║      LilyFit Integration Tests - Quick Start Guide            ║"
echo "╔════════════════════════════════════════════════════════════════╗"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check Flutter
echo -e "${BLUE}Step 1: Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi
echo -e "${GREEN}✓ Flutter found: $(flutter --version | head -1)${NC}"
echo ""

# Step 2: Check devices
echo -e "${BLUE}Step 2: Checking for available devices...${NC}"
flutter devices | head -5
echo ""

# Check if any device is available
if ! flutter devices | grep -q "•"; then
    echo -e "${YELLOW}⚠️  No devices found!${NC}"
    echo ""
    echo "To run integration tests, you need either:"
    echo "  1. iOS Simulator: open -a Simulator"
    echo "  2. Android Emulator: emulator -avd <name>"
    echo "  3. Physical device connected via USB"
    echo ""
    read -p "Would you like to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 3: Check dependencies
echo -e "${BLUE}Step 3: Checking dependencies...${NC}"
if [ ! -d ".dart_tool" ]; then
    echo "Running flutter pub get..."
    flutter pub get
fi
echo -e "${GREEN}✓ Dependencies ready${NC}"
echo ""

# Step 4: Run a quick test
echo -e "${BLUE}Step 4: Running a quick smoke test...${NC}"
echo ""
echo "This will run the fastest test suite (app_test.dart)"
echo "to verify everything is working correctly."
echo ""
read -p "Press Enter to start the test..."

echo ""
echo "Running: flutter test integration_test/app_test.dart"
echo "This may take 1-2 minutes..."
echo ""

if flutter test integration_test/app_test.dart; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 SUCCESS! 🎉                              ║${NC}"
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo ""
    echo "Your integration test suite is working correctly!"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Run all tests:"
    echo "   ${BLUE}./run_integration_tests.sh${NC}"
    echo ""
    echo "2. Run specific test suite:"
    echo "   ${BLUE}flutter test integration_test/onboarding_flow_test.dart${NC}"
    echo "   ${BLUE}flutter test integration_test/nutrition_tracking_flow_test.dart${NC}"
    echo "   ${BLUE}flutter test integration_test/water_tracking_flow_test.dart${NC}"
    echo "   ${BLUE}flutter test integration_test/progress_flow_test.dart${NC}"
    echo "   ${BLUE}flutter test integration_test/profile_flow_test.dart${NC}"
    echo "   ${BLUE}flutter test integration_test/complete_user_journey_test.dart${NC}"
    echo ""
    echo "3. Read the documentation:"
    echo "   ${BLUE}cat integration_test/README.md${NC}"
    echo "   ${BLUE}cat INTEGRATION_TESTS_SUMMARY.md${NC}"
    echo ""
    echo "4. Use VS Code debugger:"
    echo "   - Open VS Code"
    echo "   - Go to Run & Debug (⇧⌘D)"
    echo "   - Select a test configuration"
    echo "   - Press F5 to run/debug"
    echo ""
else
    echo ""
    echo "❌ Test failed. Please check the output above for errors."
    echo ""
    echo "Common issues:"
    echo "  - No device/emulator running"
    echo "  - Missing dependencies"
    echo "  - Compilation errors"
    echo ""
    echo "Try:"
    echo "  1. Start a device/emulator"
    echo "  2. Run: flutter pub get"
    echo "  3. Run: flutter clean && flutter pub get"
    echo ""
    exit 1
fi

echo -e "${GREEN}Happy testing! 🚀✨${NC}"
echo ""

