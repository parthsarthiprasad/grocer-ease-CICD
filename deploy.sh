#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 GrocerEase Docker Deployment${NC}"
echo "=================================="

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running. Please start Docker Desktop and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker is running${NC}"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! docker-compose --version > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker Compose is not available. Please install Docker Compose.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker Compose is available${NC}"
}

# Function to create environment file
create_env_file() {
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
    sleep 10
    
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
    if curl -s http://localhost:3000 > /dev/null; then
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
    echo -e "${GREEN}   Frontend:${NC} http://localhost:3000"
    echo -e "${GREEN}   Chatbot Backend:${NC} http://localhost:8000"
    echo -e "${GREEN}   Roomba Mapping:${NC} http://localhost:8001"
}

# Function to stop services
stop_services() {
    echo -e "${YELLOW}🛑 Stopping services...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Services stopped${NC}"
}

# Function to show logs
show_logs() {
    echo -e "${BLUE}📋 Service logs:${NC}"
    docker-compose logs -f
}

# Function to clean up
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up Docker resources...${NC}"
    docker-compose down -v --remove-orphans
    docker system prune -f
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        check_docker
        check_docker_compose
        create_env_file
        deploy_services
        check_health
        show_urls
        ;;
    "stop")
        stop_services
        ;;
    "logs")
        show_logs
        ;;
    "cleanup")
        cleanup
        ;;
    "restart")
        stop_services
        deploy_services
        check_health
        show_urls
        ;;
    *)
        echo -e "${BLUE}Usage:${NC}"
        echo -e "  ${GREEN}./deploy.sh${NC}          - Deploy all services"
        echo -e "  ${GREEN}./deploy.sh stop${NC}      - Stop all services"
        echo -e "  ${GREEN}./deploy.sh logs${NC}      - Show service logs"
        echo -e "  ${GREEN}./deploy.sh cleanup${NC}   - Clean up Docker resources"
        echo -e "  ${GREEN}./deploy.sh restart${NC}   - Restart all services"
        ;;
esac 