txgh-web
====

A simple web front-end for managing txgh.

What does it do?
---

txgh-web provides a simple, no-frills web interface for a running [txgh](https://github.com/lumoslabs/txgh) instance. It lists configured projects and allows you to see their corresponding resources and git branches, as well as shows translation completion percentages and allows easy one-click downloading of translations.

Getting Started
---

txgh-web is a vanilla [Rails](https://github.com/rails/rails) app. That said, it doesn't require an external cache or any database like most Rails apps do. All configuration should be added to the .env file. See .env.example for the list of required variables, and see the section below for a description of each variable. (Please note that .env will contain secrets and should never be tracked by git).

### Running Locally

1. Configure txgh-web by adding the appropriate variables to .env.
2. Bundle gem dependencies with `bundle install`.
3. Run `rails s`.

You should now be able to access txgh-web at `http://localhost:3000`.

### Using Docker

The most convenient way to run txgh-web is via Docker. Keep in mind that you will need to somehow provide all the environment variables in .env to Docker. I suggest using the [dotenv](https://github.com/bkeepers/dotenv) gem, which provides a handy executable that can load the entries in .env into the environment. Unfortunately Docker's `--env-file` command-line option doesn't work in this case because the .env file can contain double quoted values and newlines.

1. Configure txgh-web by adding the appropriate variables to .env.

2. Pull the docker image

```
docker pull quay.io/lumoslabs/txgh-web:latest
```

3. Run it like it's hot (notice the single quotes around the `docker` command)

```
dotenv 'docker run \
  -p 3000:3000 \
  -e "TX_USERNAME=$TX_USERNAME" \
  -e "TX_PASSWORD=$TX_PASSWORD" \
  -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
  -e "RAILS_SERVE_STATIC_FILES=$RAILS_SERVE_STATIC_FILES" \
  -e "HTTP_BASIC_USERNAME=$HTTP_BASIC_USERNAME" \
  -e "HTTP_BASIC_PASSWORD=$HTTP_BASIC_PASSWORD" \
  -e "PROJECTS_CONFIG=$PROJECTS_CONFIG" \
  quay.io/lumoslabs/txgh-web:latest'
```

You should now be able to access txgh-web on port 3000.

Configuration
---

Options for the .env file:

* **`TX_USERNAME`**: Your Transifex username.
* **`TX_PASSWORD`**: Your Transifex password.
* **`SECRET_KEY_BASE`**: Rails secret key. You can make this up.
* **`RAILS_SERVE_STATIC_FILES`**: Set to "true" to ask Rails to serve static assets. Pretty much required if you're running with Docker (and haven't modified the code to serve assets from an external source).
* **`HTTP_BASIC_USERNAME`**: The username to use to protect txgh-web.
* **`HTTP_BASIC_PASSWORD`**: The password to use to protect txgh-web.
* **`PROJECTS_CONFIG`**: Project config in YAML format (see below).

### Project Config Format

In order for projects to be listed in the txgh-web interface, you'll need to add them to the project config. The config is a YAML sequence, where each element is a map containing three key/value pairs.

```yaml
- slug: firstproject
  name: First Project
  external_url: http://mytxgh.com
  internal_url: http://mytxgh.mybizness.local
- slug: secondproject
  name: Second Project
  url: http://mytxgh.com
- slug: thirdproject
  name: Third Project
  url: http://myothertxgh.com
```

* **`slug`**: The project's Transifex project slug.
* **`name`**: Human-readable display name for the project.
* **`external_url`**: URL to your running txgh instance, accessible via a browser.
* **`internal_url`**: URL to your running txgh instance, accessible via txgh-web. In most cases this will be the same as `external_url`, but provides the option of specifying a URL that can be resolved inside your hosting provider's network.

Running Tests
---

Unfortunately this project doesn't have any tests. Can you help add some? Consider contributing!

Requirements
---

txgh-web does not have any external requirements like a database or cache.

Compatibility
---

txgh-web was developed with Ruby 2.1.6, but is probably compatible with all versions between 2.0 and 2.3.

Authors
---

Written and maintained by [Cameron Dutro](https://github.com/camertron).

License
---

Licensed under the Apache License, Version 2.0. See the LICENSE file included in this repository for the full text.
