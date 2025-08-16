#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Google Cloud Configuration
PROJECT_ID="ornate-glider-467114-t7"
INSTANCE_NAME="instance-20250726-141523"
ZONE="us-central1-c"
STATIC_IP="35.192.34.23"

echo -e "${BLUE}🚀 GrocerEase Google Cloud Deployment${NC}"
echo "============================================="

# Function to check if gcloud is installed and configured
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}❌ Google Cloud SDK is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        echo -e "${RED}❌ Not authenticated with Google Cloud. Please run 'gcloud auth login' first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Google Cloud SDK is configured${NC}"
}

# Function to set the project
set_project() {
    echo -e "${BLUE}🔧 Setting Google Cloud project...${NC}"
    gcloud config set project $PROJECT_ID
    echo -e "${GREEN}✅ Project set to: $PROJECT_ID${NC}"
}

# Function to copy files to the instance
copy_files() {
    echo -e "${BLUE}📁 Copying application files to instance...${NC}"
    
    # Create a temporary directory on the instance
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="mkdir -p ~/grocer-ease-temp"
    
    # Copy the application files
    gcloud compute scp --recurse --zone=$ZONE \
        ../nginx \
        ../docker-compose.yml \
        ../deploy.sh \
        ../scripts \
        $INSTANCE_NAME:~/grocer-ease-temp/
    
    echo -e "${GREEN}✅ Files copied successfully${NC}"
}

# Function to deploy on the instance
deploy_on_instance() {
    echo -e "${BLUE}🚀 Deploying application on instance...${NC}"
    
    # SSH into the instance and deploy
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
        cd ~/grocer-ease-temp
        chmod +x deploy.sh
        chmod +x scripts/*.sh
        
        # Stop any existing containers
        docker-compose down 2>/dev/null || true
        
        # Build and start services
        ./deploy.sh deploy
        
        # Check if services are running
        echo 'Checking service status...'
        docker ps
        
        # Test the application
        echo 'Testing application endpoints...'
        curl -s http://localhost/health || echo 'Health check failed'
        curl -s http://localhost:3001 | head -n 5 || echo 'Frontend check failed'
    "
    
    echo -e "${GREEN}✅ Deployment completed${NC}"
}

# Function to verify deployment
verify_deployment() {
    echo -e "${BLUE}🔍 Verifying deployment...${NC}"
    
    # Test external access
    echo -e "${YELLOW}Testing external access...${NC}"
    
    # Health check
    if curl -s http://$STATIC_IP/health > /dev/null; then
        echo -e "${GREEN}✅ Health check passed${NC}"
    else
        echo -e "${RED}❌ Health check failed${NC}"
    fi
    
    # Frontend check
    if curl -s http://$STATIC_IP | grep -q "html\|React\|GrocerEase" > /dev/null; then
        echo -e "${GREEN}✅ Frontend is accessible${NC}"
    else
        echo -e "${RED}❌ Frontend is not accessible${NC}"
    fi
    
    # Domain check
    if curl -s http://availablenear.com | grep -q "html\|React\|GrocerEase" > /dev/null; then
        echo -e "${GREEN}✅ Domain availablenear.com is accessible${NC}"
    else
        echo -e "${RED}❌ Domain availablenear.com is not accessible${NC}"
    fi
}

# Function to show deployment info
show_deployment_info() {
    echo -e "${BLUE}🌐 Deployment Information:${NC}"
    echo -e "${GREEN}   Instance:${NC} $INSTANCE_NAME"
    echo -e "${GREEN}   Zone:${NC} $ZONE"
    echo -e "${GREEN}   Static IP:${NC} $STATIC_IP"
    echo -e "${GREEN}   Domain:${NC} availablenear.com"
    echo -e "${GREEN}   Frontend:${NC} http://$STATIC_IP"
    echo -e "${GREEN}   Health Check:${NC} http://$STATIC_IP/health"
    echo ""
    echo -e "${YELLOW}💡 You can also access via domain:${NC}"
    echo -e "${GREEN}   Frontend:${NC} http://availablenear.com"
    echo -e "${GREEN}   Health Check:${NC} http://availablenear.com/health"
}

# Function to show logs
show_logs() {
    echo -e "${BLUE}📋 Connecting to instance for logs...${NC}"
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
        cd ~/grocer-ease-temp
        docker-compose logs -f
    "
}

# Function to restart services
restart_services() {
    echo -e "${BLUE}🔄 Restarting services...${NC}"
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
        cd ~/grocer-ease-temp
        ./deploy.sh restart
    "
    echo -e "${GREEN}✅ Services restarted${NC}"
}

# Function to stop services
stop_services() {
    echo -e "${YELLOW}🛑 Stopping services...${NC}"
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
        cd ~/grocer-ease-temp
        ./deploy.sh stop
    "
    echo -e "${GREEN}✅ Services stopped${NC}"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        check_gcloud
        set_project
        copy_files
        deploy_on_instance
        verify_deployment
        show_deployment_info
        ;;
    "restart")
        check_gcloud
        set_project
        restart_services
        verify_deployment
        ;;
    "stop")
        check_gcloud
        set_project
        stop_services
        ;;
    "logs")
        check_gcloud
        set_project
        show_logs
        ;;
    "verify")
        check_gcloud
        set_project
        verify_deployment
        show_deployment_info
        ;;
    *)
        echo -e "${BLUE}Usage:${NC}"
        echo -e "  ${GREEN}./gcloud-deploy.sh${NC}      - Deploy application to Google Cloud"
        echo -e "  ${GREEN}./gcloud-deploy.sh restart${NC} - Restart services"
        echo -e "  ${GREEN}./gcloud-deploy.sh stop${NC}    - Stop services"
        echo -e "  ${GREEN}./gcloud-deploy.sh logs${NC}    - Show service logs"
        echo -e "  ${GREEN}./gcloud-deploy.sh verify${NC}  - Verify deployment"
        ;;
esac 