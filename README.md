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
$ docker run -d -p 8022:22 -p 80:80 --name web -v $PWD/nginx:/etc/nginx/sites-enabled -v $PWD/www:/var/www/html --link mariadb rpayanm/drupal
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
For drupal 6:
```
server {
  server_name <site>.local;
  root /var/www/html/<site>;

  include snippets/drupal-6.conf;
}
```
Reload nginx:

`$ docker exec web service nginx reload`

Add to `/etc/host`:

`$ sudo nano /etc/hosts`

`127.0.0.1 <site>.local`

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

`$ apt-get install mariabd-client`

Connect to mariadb server:

`$ mysql -uroot -p -h127.0.0.1`


