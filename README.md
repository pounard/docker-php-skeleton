# Simple PHP project skeleton

This is not meant to be used for entreprise grade projects or production.

This is a simple PHP project base Docker Compose stack, including:

 - configured PostgreSQL,
 - configured PHP with Opcache,
 - configured Nginx,
 - dev variant with Xdebug working with no additional configuration,
 - suitable for Drupal, Symfony, and any other PHP project.

Nginx, PHP and PostgreSQL are *not* performance tuned. It is mostly suitable
for development environements or small personal hosting.

# Overview

The `/etc` folder contains configuration for services. Almost every
configuration file will be bind mounted as volume in each revelant container
instance, you can modify files on your host file system and restart target
containers without the need to rebuild.

Your application will live in the `app/` folder, which means that it is your
project root, and it must not leak outside of this folder, in short, you will
find this structure for a Symfony project:

 - `app/composer.json`,
 - `app/.env` for Symfony specific `.env` file, which should not contain much
   since the root `.env` file already contains valuable configuration such as
   `APP_ENV` and `DATABASE_URL`,
 - `app/public/index.php`.

The `app` folder is mounted inside the `php` container, whose `UID` and `GID`
are bound to the current user identification. This allows you to continue
editing files which live inside the container for development environements.

There is one exception for the PHP container which has a `Dockerfile` because
we need to run additional PHP extensions compilation and configuration.

The `./control.sh` script will allow you to manage your containers:

 - `./control.sh build` runs a docker compose build,
 - `./control.sh pull` pulls everything to the latest version,
 - `./control.sh up` run the project,
 - `./control.sh down` shutdown everything,
 - `./control.sh up CONTAINER_NAME` run a single container,
 - `./control.sh down CONTAINER_NAME` shutdown a single container.

This control script requires that you have a `.env` file, which contains
at the very least:

 - `PROJECT_NAME=foo` where `foo` is the docker compose project name,
 - `APP_ENV=dev|prod` which derives which docker compose yaml file to use,
   but also will propagate this variable to PHP environment, which gives
   Symfony projects their own environment name.

All other variables are required too but they target containers and not
the control script, they are documented inside the file.

# Setup

Clone this repository, and remove the `.git` folder in order to add
your own.

```sh
git clone https:// your_project_name
cd your_project_name
rm -rf .git
git init
```

Then copy the `.env.dist` file:

```sh
cp .env.dist .env
```

Then edit the `.env` file following the comments inside. For all the rest,
files are yours, so adapt to your needs.

Then build and start:

```sh
./control.sh build
./control.sh up
```

You now can install your PHP application inside the `app/` folder, and adapt
nginx configuration to point toward your index PHP file.

If you required changes in the nginx or other configuration files, restart
your containers, as well as when you change environment variables:

```sh
./control.sh restart
```

Per default, containers are configured for a Symfony project and require no
additional configuration, tested with Symfony 6.2.

# Known bugs and annoyances

As of now, there is something wrong with Xdebug temporary bind mounted volumes,
Xdebug can't write inside, I have to explore why.
