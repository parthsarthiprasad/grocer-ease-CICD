#!/bin/bash

# Example usage of GrocerEase installation scripts
# This script demonstrates a typical workflow for setting up the project

echo "🚀 GrocerEase Installation Example"
echo "=================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Step 1: Check current repository status${NC}"
./scripts/install.sh status

echo -e "\n${BLUE}Step 2: Show current configuration${NC}"
./scripts/install.sh config

echo -e "\n${BLUE}Step 3: Example of installing a specific repository${NC}"
echo -e "${YELLOW}Note: This would clone the grocer-ease-chatbot repository${NC}"
echo -e "${YELLOW}Uncomment the line below to actually run it:${NC}"
# ./scripts/install.sh grocer-ease-chatbot

echo -e "\n${BLUE}Step 4: Example of updating all repositories${NC}"
echo -e "${YELLOW}Note: This would update all repositories to latest${NC}"
echo -e "${YELLOW}Uncomment the line below to actually run it:${NC}"
# ./scripts/install.sh update

echo -e "\n${BLUE}Step 5: Example of complete setup${NC}"
echo -e "${YELLOW}Note: This would install repos and deploy services${NC}"
echo -e "${YELLOW}Uncomment the line below to actually run it:${NC}"
# ./scripts/setup.sh

echo -e "\n${BLUE}Step 6: Example of checking service health${NC}"
echo -e "${YELLOW}Note: This would check if all services are running${NC}"
echo -e "${YELLOW}Uncomment the line below to actually run it:${NC}"
# ./scripts/setup.sh health

echo -e "\n${GREEN}✅ Example completed!${NC}"
echo -e "${YELLOW}To run the actual commands, uncomment the lines above.${NC}" 