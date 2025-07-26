# Nginx Docker Ansible Playbook

This Ansible playbook deploys Nginx with Docker Compose, includes Certbot for SSL certificate management, and provides comprehensive configuration options for multiple domains.

## Features

- ✅ Runs Nginx container using Docker Compose
- ✅ Includes Certbot container for SSL certificate management
- ✅ **Dummy SSL certificates** for immediate HTTPS support
- ✅ **Automatic certificate switching** from dummy to real certificates
- ✅ **Containerized logging** (logs to stdout/stderr)
- ✅ Configurable Nginx settings via variables
- ✅ HTTP to HTTPS redirect support
- ✅ Custom robots.txt for each domain
- ✅ Configurable location blocks for each domain
- ✅ Basic authentication support per domain
- ✅ Automatic SSL certificate generation and renewal
- ✅ **Conditional SSL deployment** (only starts certbot when SSL is enabled)

## Prerequisites

- Ubuntu 18.04+ server
- Ansible 2.9+
- SSH access to target server
- Domain names pointing to your server

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd test_task_01
```

2. Install required Ansible collections:
```bash
ansible-galaxy collection install -r requirements.yml
```

3. Update the inventory file with your server details:
```bash
# Edit inventory file
vim inventory.ini
```

4. Configure your domains in `group_vars/all.yml`:
```yaml
domains:
  - domain: "{{ public_ipv4 }}.nip.io"  # Auto-detected public IP
    locations:
      - path: "/"
        proxy_pass: "http://backend:8080"
        proxy_set_header: "Host $host"
    enable_ssl: true
    redirect_http_to_https: true
    basic_auth:
      enabled: false
      username: "admin"
      password: "password123"
    robots_txt: |
      User-agent: *
      Disallow: /admin/
      Allow: /
```

## Configuration

### Domain Configuration

Each domain can be configured with the following options:

```yaml
domains:
  - domain: "your-domain.com"
    locations:                    # List of location blocks
      - path: "/"
        proxy_pass: "http://backend:8080"
        proxy_set_header: "Host $host"
        proxy_set_header: "X-Real-IP $remote_addr"
      - path: "/api"
        proxy_pass: "http://api:3000"
        proxy_set_header: "Host $host"
    enable_ssl: true             # Enable SSL certificate
    redirect_http_to_https: true # Redirect HTTP to HTTPS
    basic_auth:                  # Basic authentication
      enabled: true
      username: "admin"
      password: "secure_password"
    robots_txt: |                # Custom robots.txt content
      User-agent: *
      Disallow: /admin/
      Allow: /
```

### SSL Configuration

```yaml
certbot_email: "admin@example.com"  # Email for SSL certificates
certbot_staging: false              # Use staging environment for testing
```

### Nginx Configuration

```yaml
nginx_worker_processes: "auto"      # Number of worker processes
nginx_worker_connections: 1024      # Connections per worker
nginx_keepalive_timeout: 65         # Keep-alive timeout
nginx_client_max_body_size: "100M"  # Max upload size
```

## Usage

### Deploy the entire stack:
```bash
ansible-playbook -i inventory.ini site.yml
```

### Deploy to specific hosts:
```bash
ansible-playbook -i inventory.ini site.yml --limit web-server
```

### Check syntax:
```bash
ansible-playbook -i inventory.ini site.yml --check
```

### Verbose output:
```bash
ansible-playbook -i inventory.ini site.yml -v
```

## File Structure

```
.
├── ansible.cfg                 # Ansible configuration
├── inventory.ini               # Host inventory
├── site.yml                    # Main playbook
├── requirements.yml            # Ansible collections
├── group_vars/
│   └── all.yml                # Global variables
├── roles/
│   ├── docker/                # Docker installation role
│   │   ├── tasks/
│   │   │   └── main.yml       # Docker installation tasks
│   │   ├── defaults/
│   │   │   └── main.yml       # Docker role variables
│   │   └── meta/
│   │       └── main.yml       # Role metadata
│   └── nginx/                 # Nginx configuration role
│       ├── tasks/
│       │   └── main.yml       # Nginx setup tasks
│       ├── templates/
│       │   ├── nginx.conf.j2  # Nginx main config (logs to stdout)
│       │   ├── domain.conf.j2 # Domain-specific config
│       │   └── docker-compose.yml.j2 # Docker Compose
│       ├── handlers/
│       │   └── main.yml       # Handlers
│       ├── defaults/
│       │   └── main.yml       # Nginx role variables
│       └── meta/
│           └── main.yml       # Role metadata
├── examples/
│   └── sample-config.yml      # Sample configuration
└── README.md                   # This file
```

## Role Dependencies

The playbook uses two roles with clear separation of concerns:

1. **`docker`** - Installs Docker and Docker Compose
2. **`nginx`** - Configures and deploys Nginx with SSL and basic auth

The `nginx` role depends on the `docker` role and will automatically install Docker if not already present.

## SSL Certificate Management

The playbook automatically:
- **Generates dummy SSL certificates** for immediate HTTPS support
- **Starts nginx with HTTPS** using self-signed certificates
- **Generates real Let's Encrypt certificates** in the background
- **Automatically switches** from dummy to real certificates
- Uses Let's Encrypt for free SSL certificates
- Handles certificate renewal automatically
- Supports staging environment for testing

### SSL Deployment Process

1. **Dummy certificates**: Self-signed certificates are generated for each domain
2. **Nginx starts**: Container starts with HTTPS support immediately
3. **HTTP redirect**: All HTTP traffic redirects to HTTPS
4. **Real certificates**: Certbot generates real Let's Encrypt certificates
5. **Automatic switch**: Configuration updates to use real certificates

## Logging

Both Nginx and Certbot logs are configured to write to stdout/stderr:
- **Nginx access logs**: Available via `docker logs nginx`
- **Nginx error logs**: Available via `docker logs nginx`
- **Certbot logs**: Available via `docker logs certbot`

### View logs:
```bash
# Nginx logs
docker logs nginx

# Follow nginx logs in real-time
docker logs -f nginx

# Certbot logs
docker logs certbot

# Follow certbot logs in real-time
docker logs -f certbot
```

## Security Features

- HTTP to HTTPS redirects
- HSTS headers
- Security headers (X-Frame-Options, X-XSS-Protection, etc.)
- Basic authentication per domain
- SSL/TLS 1.2+ only
- Secure cipher suites
- **Containerized logging** (no log files on host)

## Troubleshooting

### Check container status:
```bash
docker ps -a
```

### View nginx logs:
```bash
docker logs nginx
```

### View certbot logs:
```bash
docker logs certbot
```

### Test nginx configuration:
```bash
docker exec nginx nginx -t
```

### Manual SSL certificate renewal:
```bash
docker exec certbot certbot renew
```

### Check SSL certificate status:
```bash
docker exec nginx nginx -T | grep ssl_certificate
```

### Common Issues

#### 404 Errors
- Ensure the domain is properly configured in `group_vars/all.yml`
- Check that the proxy_pass URL is accessible
- Verify nginx configuration with `docker exec nginx nginx -t`

#### SSL Certificate Issues
- Check certbot logs: `docker logs certbot`
- Verify domain DNS is pointing to the server
- Ensure port 80 and 443 are open in firewall
- Use staging environment for testing: `certbot_staging: true`

#### Container Restart Loops
- Check container logs for errors
- Verify docker-compose configuration
- Ensure all required volumes are accessible

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.