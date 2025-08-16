#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 GrocerEase Complete Setup${NC}"
echo "============================="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git is not installed. Please install Git and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Git is available${NC}"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed. Please install Docker and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker is available${NC}"
    
    # Check if Docker Compose is available
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not available. Please install Docker Compose.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker Compose is available${NC}"
}

# Function to install repositories
install_repositories() {
    echo -e "${BLUE}📦 Installing repositories...${NC}"
    
    if [ -f "$SCRIPT_DIR/install.sh" ]; then
        cd "$PROJECT_ROOT"
        "$SCRIPT_DIR/install.sh"
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Repository installation failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Install script not found at $SCRIPT_DIR/install.sh${NC}"
        return 1
    fi
}

# Function to setup environment
setup_environment() {
    echo -e "${BLUE}⚙️  Setting up environment...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        echo -e "${YELLOW}📝 Creating .env file...${NC}"
        cat > .env << EOF
# GrocerEase Environment Variables
GEMINI_API_KEY=AIzaSyD4PRV5vHdCy8kWr9WiQUbZ4I-p0r4sTCc
STRUCTURED_PROMPTING_API_KEY=AIzaSyD4PRV5vHdCy8kWr9WiQUbZ4I-p0r4sTCc

# Database Configuration
MONGO_URI=mongodb://grocerEase:pinakisir123@mongodb:27017/grocer_ease_db?authSource=admin
DB_NAME=grocer_ease_db

# Application Configuration
LOG_LEVEL=INFO
CLASSIFIER_TYPE=bart
PREFERENCE_MODEL_TYPE=bart
EOF
        echo -e "${GREEN}✅ .env file created${NC}"
    else
        echo -e "${GREEN}✅ .env file already exists${NC}"
    fi
}

# Function to build and start services
deploy_services() {
    echo -e "${BLUE}🔧 Building and starting services...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Build all services
    echo -e "${YELLOW}📦 Building Docker images...${NC}"
    docker-compose build --no-cache
    
    # Start services
    echo -e "${YELLOW}🚀 Starting services...${NC}"
    docker-compose up -d
    
    echo -e "${GREEN}✅ Services started successfully!${NC}"
}

# Function to check service health
check_health() {
    echo -e "${BLUE}🏥 Checking service health...${NC}"
    
    # Wait for services to be ready
    sleep 15
    
    # Check MongoDB
    if docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ MongoDB is healthy${NC}"
    else
        echo -e "${RED}❌ MongoDB is not responding${NC}"
    fi
    
    # Check Chatbot Backend
    if curl -s http://localhost:8000/health > /dev/null; then
        echo -e "${GREEN}✅ Chatbot Backend is healthy${NC}"
    else
        echo -e "${RED}❌ Chatbot Backend is not responding${NC}"
    fi
    
    # Check Roomba Mapping
    if curl -s http://localhost:8001/health > /dev/null; then
        echo -e "${GREEN}✅ Roomba Mapping is healthy${NC}"
    else
        echo -e "${RED}❌ Roomba Mapping is not responding${NC}"
    fi
    
    # Check Frontend
    if curl -s http://localhost:8080 > /dev/null; then
        echo -e "${GREEN}✅ Frontend is healthy${NC}"
    else
        echo -e "${RED}❌ Frontend is not responding${NC}"
    fi
    
    # Check Nginx
    if curl -s http://localhost:80/health > /dev/null; then
        echo -e "${GREEN}✅ Nginx is healthy${NC}"
    else
        echo -e "${RED}❌ Nginx is not responding${NC}"
    fi
}

# Function to show service URLs
show_urls() {
    echo -e "${BLUE}🌐 Service URLs:${NC}"
    echo -e "${GREEN}   Frontend:${NC} http://localhost"
    echo -e "${GREEN}   Chatbot API:${NC} http://localhost/api/v1"
    echo -e "${GREEN}   Roomba API:${NC} http://localhost/roomba"
    echo -e "${GREEN}   API Documentation:${NC} http://localhost/api/v1/docs"
    echo -e "${GREEN}   Health Check:${NC} http://localhost/health"
    echo ""
    echo -e "${YELLOW}💡 You can also access services directly:${NC}"
    echo -e "${GREEN}   Frontend:${NC} http://localhost:8080"
    echo -e "${GREEN}   Chatbot Backend:${NC} http://localhost:8000"
    echo -e "${GREEN}   Roomba Mapping:${NC} http://localhost:8001"
}

# Function to show help
show_help() {
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ${GREEN}./setup.sh${NC}              - Complete setup (install repos + deploy)"
    echo -e "  ${GREEN}./setup.sh install${NC}       - Install repositories only"
    echo -e "  ${GREEN}./setup.sh deploy${NC}        - Deploy services only"
    echo -e "  ${GREEN}./setup.sh health${NC}        - Check service health"
    echo -e "  ${GREEN}./setup.sh urls${NC}          - Show service URLs"
    echo -e "  ${GREEN}./setup.sh help${NC}          - Show this help"
    echo
    echo -e "${YELLOW}Setup Steps:${NC}"
    echo -e "  1. Check prerequisites (Git, Docker, Docker Compose)"
    echo -e "  2. Install repositories using git clone"
    echo -e "  3. Setup environment variables"
    echo -e "  4. Build and start Docker services"
    echo -e "  5. Check service health"
}

# Function to run complete setup
complete_setup() {
    echo -e "${BLUE}🚀 Starting complete GrocerEase setup...${NC}"
    
    check_prerequisites
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    install_repositories
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Repository installation failed. Please check the errors above.${NC}"
        exit 1
    fi
    
    setup_environment
    deploy_services
    check_health
    show_urls
    
    echo -e "${GREEN}🎉 GrocerEase setup completed successfully!${NC}"
}

# Main script logic
case "${1:-setup}" in
    "setup")
        complete_setup
        ;;
    "install")
        check_prerequisites
        install_repositories
        ;;
    "deploy")
        setup_environment
        deploy_services
        check_health
        show_urls
        ;;
    "health")
        check_health
        ;;
    "urls")
        show_urls
        ;;
    "help")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac 