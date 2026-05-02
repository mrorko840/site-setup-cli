
# 🚀 Site Setup CLI

A lightweight and interactive VPS website deployment tool for **Laravel**, **React.js**, and **Node.js** projects.

This CLI helps you quickly configure and deploy websites on a fresh VPS without manually writing Nginx configs, enabling sites, installing SSL, or repeating common server setup steps.

---

# ✨ Features

✅ Interactive step-by-step setup wizard  
✅ Laravel website deployment  
✅ React.js static website deployment  
✅ Node.js / API reverse proxy deployment  
✅ Automatic Nginx configuration  
✅ Auto enable site (`sites-available` → `sites-enabled`)  
✅ Nginx config test + reload  
✅ Free SSL with Let's Encrypt (Certbot)  
✅ Basic project permission setup  
✅ Clean reusable template system

---

# 📦 Supported Project Types

| Type | Description |
|------|-------------|
| Laravel | PHP Laravel apps using PHP-FPM |
| React | Static frontend build (`dist`) |
| Node | Node.js / Express / NestJS apps |

---

# 🖥️ Recommended Server

- Ubuntu 22.04 / 24.04
- Root access
- Fresh VPS preferred
- Domain pointed to server IP

---

# ⚡ Quick Install

Run directly on your VPS:

```bash
curl -fsSL https://raw.githubusercontent.com/mrorko840/site-setup-cli/main/install.sh | bash
````

---

# 🛠️ How It Works

After running the installer, it will ask for some information:

```text
Project Type (laravel/react/node):
Domain Name:
Project Path:
```

Then the tool automatically:

* Creates Nginx config
* Enables website
* Reloads Nginx
* Installs SSL certificate
* Applies required permissions
* Finalizes deployment

---

# 📌 Example Usage

---

## Example 1: Laravel Website

```text
Project Type: laravel
Domain Name: crm.example.com
Project Path: /var/www/crm-project
```

### Auto Configures:

* Root path: `/var/www/crm-project/public`
* PHP-FPM support
* Laravel routing
* Storage/cache permissions
* SSL certificate

---

## Example 2: React Website

```text
Project Type: react
Domain Name: app.example.com
Project Path: /var/www/react-app
```

### Auto Configures:

* Root path: `/var/www/react-app/dist`
* SPA routing (`index.html`)
* Static file serving
* SSL certificate

---

## Example 3: Node.js API

```text
Project Type: node
Domain Name: api.example.com
Project Path: /var/www/node-api
```

### Auto Configures:

* Reverse proxy to `localhost:5000`
* Nginx frontend
* SSL certificate

> Default Node port: `5000`

---

# 📁 Generated Nginx Config Location

```bash
/etc/nginx/sites-available/your-domain.com
```

Enabled automatically via:

```bash
/etc/nginx/sites-enabled/
```

---

# 🔐 SSL Support

Free HTTPS certificates are installed using:

* Certbot
* Let's Encrypt

---

# 📂 Project Structure

```text
site-setup-cli/
├── install.sh
├── setup.sh
├── lib/
├── templates/
└── README.md
```

---

# 🚀 Manual Installation (Optional)

```bash
git clone https://github.com/mrorko840/site-setup-cli.git
cd site-setup-cli
chmod +x install.sh setup.sh
bash install.sh
```

---

# 🧠 Notes

* Make sure your domain DNS A record points to the VPS IP.
* Use root user or sudo privileges.
* Recommended for fresh Ubuntu servers.

---

# 🔄 Future Planned Features

* PM2 auto setup
* MySQL database creation
* GitHub auto deploy
* Firewall setup
* Backup system
* Delete website command
* Multi-site dashboard

---

# 🤝 Contributing

Pull requests and suggestions are welcome.

---

# 📄 License

MIT License

---

# 👨‍💻 Author

Built by **Hemel**
GitHub: [https://github.com/mrorko840](https://github.com/mrorko840)
