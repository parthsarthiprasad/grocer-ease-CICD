# GrocerEase Installation Scripts

This directory contains scripts for installing and setting up the GrocerEase project components.

## Scripts Overview

### `install.sh` - Repository Installation Script
Installs individual git repositories using `git clone` during setup.

**Features:**
- Clone individual repositories from git
- Handle existing directories gracefully
- Update existing repositories
- Show repository status
- Support for custom repository URLs

**Usage:**
```bash
# Install all repositories
./scripts/install.sh

# Install specific repository
./scripts/install.sh grocer-ease-chatbot

# Show repository status
./scripts/install.sh status

# Update all repositories
./scripts/install.sh update

# Show configuration
./scripts/install.sh config

# Show help
./scripts/install.sh help
```

### `setup.sh` - Complete Setup Script
Combines repository installation with Docker deployment.

**Features:**
- Check prerequisites (Git, Docker, Docker Compose)
- Install repositories
- Setup environment variables
- Build and start Docker services
- Health checks
- Service URL display

**Usage:**
```bash
# Complete setup (install repos + deploy)
./scripts/setup.sh

# Install repositories only
./scripts/setup.sh install

# Deploy services only
./scripts/setup.sh deploy

# Check service health
./scripts/setup.sh health

# Show service URLs
./scripts/setup.sh urls

# Show help
./scripts/setup.sh help
```

### `repos.conf` - Repository Configuration
Configuration file for repository URLs and settings.

**Customization:**
Edit this file to point to your own repositories:

```bash
# Chatbot Backend Repository
GROCER_EASE_CHATBOT_URL=https://github.com/your-org/grocer-ease-chatbot.git

# Frontend UI Repository  
GROCER_EASE_UI_URL=https://github.com/your-org/grocer-ease-ui.git

# Roomba Mapping Repository
ROOMBA_MAPPING_URL=https://github.com/your-org/roomba-mapping.git

# Default branch for all repositories
DEFAULT_BRANCH=main
```

## Environment Variables

You can also override repository URLs using environment variables:

```bash
export GROCER_EASE_CHATBOT_URL=https://github.com/your-org/grocer-ease-chatbot.git
export GROCER_EASE_UI_URL=https://github.com/your-org/grocer-ease-ui.git
export ROOMBA_MAPPING_URL=https://github.com/your-org/roomba-mapping.git
```

## Quick Start

1. **Clone the main repository:**
   ```bash
   git clone https://github.com/your-org/grocer-ease.git
   cd grocer-ease
   ```

2. **Configure repository URLs:**
   Edit `scripts/repos.conf` to point to your repositories.

3. **Run complete setup:**
   ```bash
   ./scripts/setup.sh
   ```

4. **Access the application:**
   - Frontend: http://localhost
   - Chatbot API: http://localhost/api/v1
   - Roomba API: http://localhost/roomba
   - API Documentation: http://localhost/api/v1/docs

## Repository Structure

The setup will create the following directory structure:

```
GrocerEaseRepos/
├── grocer-ease-chatbot/     # Python chatbot backend
├── grocer-ease-ui/          # React frontend
├── roomba_mapping/          # Roomba mapping service
├── nginx/                   # Nginx configuration
├── scripts/                 # Installation scripts
├── docker-compose.yml       # Docker services
├── deploy.sh               # Original deployment script
└── .env                    # Environment variables
```

## Troubleshooting

### Repository Installation Issues
- Ensure Git is installed and configured
- Check repository URLs in `scripts/repos.conf`
- Verify network connectivity to git repositories

### Docker Issues
- Ensure Docker and Docker Compose are installed
- Check if Docker daemon is running
- Verify port availability (80, 8080, 8000, 8001, 27017)

### Service Health Issues
- Check Docker container logs: `docker-compose logs`
- Verify environment variables in `.env` file
- Ensure all required services are running

## Script Dependencies

- **Git**: For cloning repositories
- **Docker**: For containerized services
- **Docker Compose**: For multi-service orchestration
- **curl**: For health checks (usually pre-installed)

## Security Notes

- Repository URLs in `scripts/repos.conf` should point to trusted sources
- Environment variables in `.env` contain sensitive API keys
- Consider using SSH keys for private repositories 