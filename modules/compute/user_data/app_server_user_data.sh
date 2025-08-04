#!/bin/bash

# Update system
yum update -y

# Install necessary packages
yum install -y \
    htop \
    vim \
    curl \
    wget \
    unzip \
    git \
    docker \
    amazon-cloudwatch-agent

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Start and enable Docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "metrics": {
        "namespace": "${project_name}-${environment}",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/${project_name}-${environment}/app-server/messages",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/docker",
                        "log_group_name": "/aws/ec2/${project_name}-${environment}/app-server/docker",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    }
}
EOF

# Start and enable CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Create application directory
mkdir -p /opt/app
chown ec2-user:ec2-user /opt/app

# Create a simple health check endpoint
cat > /opt/app/health.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Health Check</title>
</head>
<body>
    <h1>Application Server Health Check</h1>
    <p>Status: OK</p>
    <p>Environment: ${environment}</p>
    <p>Project: ${project_name}</p>
    <p>Timestamp: <span id="timestamp"></span></p>
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
EOF

# Install and configure nginx for basic health checks
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Configure nginx
cat > /etc/nginx/conf.d/health.conf << 'EOF'
server {
    listen 8080;
    server_name _;
    
    location /health {
        alias /opt/app/health.html;
    }
    
    location / {
        return 200 'Application Server is running\n';
        add_header Content-Type text/plain;
    }
}
EOF

# Restart nginx to apply configuration
systemctl restart nginx

# Configure log rotation
cat > /etc/logrotate.d/app-server << 'EOF'
/var/log/app-server/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 ec2-user ec2-user
    postrotate
        systemctl reload nginx || true
    endscript
}
EOF

# Create log directory
mkdir -p /var/log/app-server
chown ec2-user:ec2-user /var/log/app-server

echo "Application server setup completed at $(date)" >> /var/log/user-data.log