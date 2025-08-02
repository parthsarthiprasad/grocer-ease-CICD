# GrocerEase Docker Deployment

This document describes how to deploy the complete GrocerEase application stack using Docker and Docker Compose.

## 🏗️ Architecture Overview

The deployment consists of 5 main services:

1. **MongoDB Database** - Stores user data, chat history, and shopping lists
2. **Chatbot Backend** - Python FastAPI service with AI capabilities
3. **Roomba Mapping Service** - Python service for floorplan processing
4. **React Frontend** - Modern web interface
5. **Nginx Reverse Proxy** - Routes traffic and provides SSL termination

## 📋 Prerequisites

- Docker Desktop installed and running
- Docker Compose available
- At least 4GB of available RAM
- At least 10GB of available disk space

## 🚀 Quick Start

### 1. Clone and Navigate
```bash
cd /path/to/GrocerEaseRepos
```

### 2. Deploy All Services
```bash
./deploy.sh
```

This will:
- Check Docker and Docker Compose availability
- Create environment configuration
- Build all Docker images
- Start all services
- Verify service health
- Display access URLs

### 3. Access the Application
- **Main Application**: http://localhost
- **API Documentation**: http://localhost/api/v1/docs
- **Health Check**: http://localhost/health

## 🔧 Service Details

### MongoDB Database
- **Port**: 27017
- **Container**: grocer-ease-mongodb
- **Data**: Persisted in Docker volume
- **Authentication**: Username: grocerEase, Password: pinakisir123

### Chatbot Backend
- **Port**: 8000 (internal), 8000 (external)
- **Container**: grocer-ease-chatbot
- **API Base**: http://localhost/api/v1
- **Features**: AI chat, shopping list management, user preferences

### Roomba Mapping Service
- **Port**: 8001 (external)
- **Container**: grocer-ease-roomba-mapping
- **API Base**: http://localhost/roomba
- **Features**: Floorplan upload and processing

### React Frontend
- **Port**: 3000 (internal), 3000 (external)
- **Container**: grocer-ease-frontend
- **Features**: Interactive UI, chat interface, store navigation

### Nginx Reverse Proxy
- **Port**: 80 (HTTP), 443 (HTTPS)
- **Container**: grocer-ease-nginx
- **Features**: Load balancing, SSL termination, rate limiting

## 📁 File Structure

```
GrocerEaseRepos/
├── docker-compose.yml          # Main orchestration file
├── deploy.sh                   # Deployment script
├── .env                        # Environment variables
├── nginx/
│   └── nginx.conf             # Nginx configuration
├── scripts/
│   └── init-mongo.js          # MongoDB initialization
├── grocer-ease-chatbot/
│   ├── Dockerfile             # Chatbot backend image
│   └── src/                   # Python application
├── grocer-ease-ui/
│   ├── Dockerfile             # React frontend image
│   └── src/                   # React application
└── roomba_mapping/
    └── roomba_mapping/
        ├── Dockerfile         # Roomba mapping image
        └── app.py             # Python application
```

## 🛠️ Management Commands

### Start Services
```bash
./deploy.sh
```

### Stop Services
```bash
./deploy.sh stop
```

### View Logs
```bash
./deploy.sh logs
```

### Restart Services
```bash
./deploy.sh restart
```

### Clean Up (Remove all containers and volumes)
```bash
./deploy.sh cleanup
```

### Manual Docker Compose Commands
```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Scale services
docker-compose up -d --scale chatbot-backend=2
```

## 🔍 Monitoring and Debugging

### Check Service Status
```bash
docker-compose ps
```

### View Individual Service Logs
```bash
# Chatbot backend logs
docker-compose logs chatbot-backend

# Frontend logs
docker-compose logs frontend

# MongoDB logs
docker-compose logs mongodb
```

### Access Service Shells
```bash
# Chatbot backend shell
docker-compose exec chatbot-backend bash

# Frontend shell
docker-compose exec frontend sh

# MongoDB shell
docker-compose exec mongodb mongosh
```

### Database Operations
```bash
# Connect to MongoDB
docker-compose exec mongodb mongosh grocer_ease_db

# Backup database
docker-compose exec mongodb mongodump --db grocer_ease_db --out /backup

# Restore database
docker-compose exec mongodb mongorestore --db grocer_ease_db /backup/grocer_ease_db
```

## 🔐 Security Configuration

### Environment Variables
Create a `.env` file with your API keys:
```bash
GEMINI_API_KEY=your_gemini_api_key
STRUCTURED_PROMPTING_API_KEY=your_structured_prompting_key
```

### SSL/HTTPS Setup
1. Place SSL certificates in `nginx/ssl/`
2. Uncomment HTTPS server block in `nginx/nginx.conf`
3. Update certificate paths in nginx configuration

### Database Security
- MongoDB is configured with authentication
- Default credentials: grocerEase/pinakisir123
- Change credentials in production

## 📊 Performance Optimization

### Resource Limits
Add to docker-compose.yml services:
```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
    reservations:
      memory: 512M
      cpus: '0.25'
```

### Scaling
```bash
# Scale chatbot backend
docker-compose up -d --scale chatbot-backend=3

# Scale roomba mapping
docker-compose up -d --scale roomba-mapping=2
```

### Caching
- Nginx is configured with static file caching
- MongoDB indexes are created for performance
- React build is optimized for production

## 🐛 Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using the port
   lsof -i :8000
   
   # Kill the process
   kill -9 <PID>
   ```

2. **Docker Out of Space**
   ```bash
   # Clean up Docker
   docker system prune -a
   ```

3. **MongoDB Connection Issues**
   ```bash
   # Check MongoDB logs
   docker-compose logs mongodb
   
   # Restart MongoDB
   docker-compose restart mongodb
   ```

4. **Build Failures**
   ```bash
   # Rebuild without cache
   docker-compose build --no-cache
   ```

### Health Checks
```bash
# Check all services
curl http://localhost/health

# Check individual services
curl http://localhost:8000/health  # Chatbot
curl http://localhost:8001/health  # Roomba
curl http://localhost:3000         # Frontend
```

## 🔄 Updates and Maintenance

### Update Application Code
```bash
# Stop services
./deploy.sh stop

# Pull latest code
git pull

# Rebuild and restart
./deploy.sh restart
```

### Update Dependencies
```bash
# Rebuild specific service
docker-compose build chatbot-backend

# Restart service
docker-compose up -d chatbot-backend
```

### Database Migrations
```bash
# Access MongoDB
docker-compose exec mongodb mongosh grocer_ease_db

# Run migration scripts
# (Add your migration scripts here)
```

## 📈 Production Deployment

### Environment Variables
Set production environment variables:
```bash
export GEMINI_API_KEY=your_production_key
export STRUCTURED_PROMPTING_API_KEY=your_production_key
```

### SSL Certificates
1. Obtain SSL certificates
2. Place in `nginx/ssl/`
3. Update nginx configuration
4. Restart nginx container

### Monitoring
Consider adding monitoring tools:
- Prometheus for metrics
- Grafana for visualization
- ELK stack for logging

### Backup Strategy
```bash
# Database backup
docker-compose exec mongodb mongodump --db grocer_ease_db --out /backup

# Volume backup
docker run --rm -v grocer-ease-mongodb_data:/data -v $(pwd):/backup alpine tar czf /backup/mongodb_backup.tar.gz -C /data .
```

## 🤝 Contributing

When making changes to the Docker setup:

1. Test locally with `./deploy.sh`
2. Update documentation
3. Test all services work correctly
4. Commit changes with descriptive messages

## 📞 Support

For issues with the Docker deployment:
1. Check the troubleshooting section
2. Review service logs
3. Verify Docker and Docker Compose versions
4. Ensure sufficient system resources 