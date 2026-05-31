#!/bin/bash

# Integration Test Runner for LilyFit
# This script runs all integration tests for the mobile app

set -e

echo "════════════════════════════════════════════════════════════════"
echo "  LilyFit Integration Test Suite"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check if device/emulator is available
echo -e "${BLUE}Checking for available devices...${NC}"
flutter devices

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: No devices available. Please start an emulator or connect a device.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Select test suite to run:${NC}"
echo "  1) All tests (comprehensive)"
echo "  2) Onboarding flow"
echo "  3) Nutrition tracking flow"
echo "  4) Water tracking flow"
echo "  5) Progress tracking flow"
echo "  6) Profile management flow"
echo "  7) Complete user journey"
echo "  8) Quick smoke test (existing app_test.dart)"
echo ""

read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        echo -e "${GREEN}Running ALL integration tests...${NC}"
        flutter test integration_test/onboarding_flow_test.dart
        flutter test integration_test/nutrition_tracking_flow_test.dart
        flutter test integration_test/water_tracking_flow_test.dart
        flutter test integration_test/progress_flow_test.dart
        flutter test integration_test/profile_flow_test.dart
        flutter test integration_test/complete_user_journey_test.dart
        flutter test integration_test/app_test.dart
        ;;
    2)
        echo -e "${GREEN}Running onboarding flow tests...${NC}"
        flutter test integration_test/onboarding_flow_test.dart
        ;;
    3)
        echo -e "${GREEN}Running nutrition tracking flow tests...${NC}"
        flutter test integration_test/nutrition_tracking_flow_test.dart
        ;;
    4)
        echo -e "${GREEN}Running water tracking flow tests...${NC}"
        flutter test integration_test/water_tracking_flow_test.dart
        ;;
    5)
        echo -e "${GREEN}Running progress tracking flow tests...${NC}"
        flutter test integration_test/progress_flow_test.dart
        ;;
    6)
        echo -e "${GREEN}Running profile management flow tests...${NC}"
        flutter test integration_test/profile_flow_test.dart
        ;;
    7)
        echo -e "${GREEN}Running complete user journey test...${NC}"
        flutter test integration_test/complete_user_journey_test.dart
        ;;
    8)
        echo -e "${GREEN}Running quick smoke test...${NC}"
        flutter test integration_test/app_test.dart
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

echo ""
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Tests completed successfully!${NC}"
else
    echo -e "${RED}✗ Tests failed. Check the output above for details.${NC}"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════"

