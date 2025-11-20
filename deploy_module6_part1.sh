#!/usr/bin/env bash
set -Eeuo pipefail

# Script to deploy Module 6 Part 1 Docker Compose project

echo "Starting Module 6 Part 1 Deployment Script..."
# --- 1. Check prerequisites ---
echo -e "\n--- Checking for Docker, Docker Compose, and jq ---"
command -v docker >/dev/null || { echo "Docker is not installed. Install Docker first."; exit 1; }
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
else
    echo "Docker Compose is not installed."; exit 1
fi
command -v jq >/dev/null || { echo "jq not found. Installing..."; sudo apt update -y && sudo apt install -y jq; }

echo "Prerequisites verified successfully."

# --- 2. Validate docker-compose.yml ---
echo -e "\n--- Checking for docker-compose.yml file ---"
[ -f docker-compose.yml ] || { echo "docker-compose.yml not found. Make sure you are in Module_6_part1 folder."; exit 1; }
echo "docker-compose.yml found."

# --- 3. Build and Deploy Containers ---
echo -e "\n--- Building and starting Docker containers ---"
$DOCKER_COMPOSE up -d --build || { echo "Docker Compose build failed."; exit 1; }
echo "Containers started successfully."
sleep 6

# --- 4. Health Checks ---
echo -e "\n--- Running Health Checks ---"
# Frontend container check
echo "Checking frontend container (module_6_part1-frontend-1)..."
docker ps | grep module_6_part1-frontend-1 >/dev/null && echo "Frontend container running." || echo "Frontend container NOT running."

# Frontend via nginx (port 80)
echo "Checking frontend via nginx on port 80..."
curl -s http://localhost >/dev/null && echo "Frontend OK." || echo "Frontend NOT responding."

# Backend container check
echo "Checking backend container (module_6_part1-backend-1)..."
docker ps | grep module_6_part1-backend-1 >/dev/null && echo "Backend container running." || echo "Backend container NOT running."

# Backend internal check (docker exec)
echo "Checking backend internally on port 5000..."
curl -s http://localhost:5000 >/dev/null && echo "Backend OK." || echo "Backend NOT responding."


echo -e "\nDeployment completed successfully."
