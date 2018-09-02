[![](https://images.microbadger.com/badges/image/rpayanm/drupal.svg)](https://microbadger.com/images/rpayanm/drupal "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/rpayanm/drupal.svg)](https://microbadger.com/images/rpayanm/drupal "Get your own version badge on microbadger.com")

# Drupal
Docker Image with Nginx and PHP-FPM for Drupal development.

# Get started
1. [Install docker](https://docs.docker.com/engine/installation/)
2. Download the containers
```
$ cd /home/$USER
$ git clone https://github.com/rpayanm/drupal.git
$ cd drupal
$ docker create --name web_data -v /var/lib/mysql busybox
$ docker run -d -p 3306:3306 --name mariadb --volumes-from web_data -e MYSQL_ROOT_PASSWORD=toor mariadb:latest
$ docker run -d -p 1025:1025 -p 8025:8025 --name mailhog mailhog/mailhog
$ docker run -d -p 8022:22 -p 80:80 --name web -v $PWD/nginx:/etc/nginx/sites-enabled -v $PWD/www:/var/www/html --link mariadb --link mailhog rpayanm/drupal
```
`$ sudo nano /etc/hosts`

Add:

```
127.0.0.1 mariadb
127.0.0.1 mailhog
```

# Create a new site
`$ cd /home/$USER/drupal/www`

Copy the project files or clone you site
```
$ git clone ...
$ cd /home/$USER/drupal/nginx
$ nano <site>.conf
```
Put in:

For drupal 7 and 8:
```
server {
  server_name <site>.local;
  root /var/www/html/<site>;

  include snippets/drupal-7-8.conf;
}
```
Reload nginx:

`$ docker exec web service nginx reload`

Add to `/etc/host`:

`$ sudo nano /etc/hosts`

`127.0.0.1 <site>.local`

**Note**: Replace wherever `<site>` appears with the machine name of your site

In settings.php:

```
$databases['default']['default'] = array(
  ...
  'host' => 'mariadb',
  ...
);
```

# Start containers
`$ docker start mariadb web`

# Access

Mysql:
```
user: root
pass: toor
```
Install a client for mysql

`$ sudo apt-get install mariadb-client`

Connect to mariadb server:

`$ mysql -uroot -p -h127.0.0.1`

# Mailhog
We used  [MailHog](https://github.com/mailhog/MailHog) is an email testing tool for developers. Web and API based SMTP testing.
You can check in your browser copying on it this url: http://127.0.0.1:8025

# Portainer
[Portainer](https://portainer.io) is an open-source lightweight management UI which allows you to easily manage your Docker hosts or Swarm clusters 

To have this:

1. Run in terminal:
```
$ docker run -d -p 1000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer --no-auth
```

2. Open the browser and copy http://127.0.0.1:1000

3. Choose local endpoint. It is the first option.
