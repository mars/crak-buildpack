Heroku Buildpack for create-react-app with Kong gateway
=======================================================

⭐️ A new version of [create-react-app-buildpack](https://github.com/mars/create-react-app-buildpack) that replaces the basic Nginx server with a [Kong gateway](https://konghq.com/) to support sophisticated access control, backend proxies, and more.

Deploy React.js web apps generated with [create-react-app](https://github.com/facebook/create-react-app). Automates deployment with the built-in bundler and serves it up via [Kong](https://konghq.com/), which is fundamentally the [Nginx](http://nginx.org/en/) web server.

* 🚦 [Purpose](#user-content-purpose)
* ⚠️ [Requirements](#user-content-requires)
* 🚀 [Quick Start](#user-content-quick-start)
* 🛠 [Usage](#user-content-usage)
  1. [Generate a React app](#user-content-generate-a-react-app)
  1. [Make it a git repo](#user-content-make-it-a-git-repo)
  1. [Create the Heroku app](#user-content-create-the-heroku-app)
  1. [Commit & deploy ♻️](#user-content-commit--deploy-️)
  1. [Continue Development](#user-content-continue-development)
  1. [Push to Github](#user-content-push-to-github)
  1. [Testing](#user-content-testing)
* 👓 [Customization](#user-content-customization)
  * [Procfile](#user-content-procfile)
  * [Web server](#user-content-web-server)
    * [Changing the root](#user-content-changing-the-root)
    * [Routing](#user-content-routing)
    * [HTTPS-only](#user-content-https-only)
    * [Authentication](#user-content-authentication)
    * [Proxy](#user-content-proxy)
  * [Environment variables](#user-content-environment-variables)
    * [Set vars on Heroku](#user-content-set-vars-on-heroku)
    * [Set vars for local dev](#user-content-set-vars-for-local-dev)
    * [Compile-time vs Runtime](#user-content-compile-time-vs-runtime)
      * [Compile-time config](#user-content-compile-time-configuration)
      * [Runtime config](#user-content-runtime-configuration)
        * [Custom bundle location](#user-content-custom-bundle-location)
    * [using an Add-on's config](#user-content-add-on-config-vars)
  * [npm Private Packages](#user-content-npm-private-packages)
  * [Kong Admin API](#user-content-kong-admin-api)
* 🕵️ [Troubleshooting](#user-content-troubleshooting)
* 📍 [Version compatibility](#user-content-version-compatibility)
* 🏙 [Architecture](#user-content-architecture-)

-----

Purpose
-------

**This buildpack deploys a React UI as a static web site.** [Kong](https://konghq.com/) serves the high-performance static site and provides dynamic proxy/gateway capabilities. See [Architecture](#user-content-architecture-) for details.

If your goal is to combine React UI + API (Node, Ruby, Python…) into a *single app*, then this buildpack is not the answer. The simplest combined solution is all javascript:

▶️ **[create-react-app + Node.js server](https://github.com/mars/heroku-cra-node)** on Heroku

Combination with other languages is possible too, like [create-react-app + Rails 5 server](https://medium.com/superhighfives/a-top-shelf-web-stack-rails-5-api-activeadmin-create-react-app-de5481b7ec0b).

Requires
--------

* [Heroku](https://www.heroku.com/home)
  * [command-line tools (CLI)](https://toolbelt.heroku.com)
  * [a free account](https://signup.heroku.com)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Node.js](https://nodejs.org)

Quick Start
-----------

Ensure [requirements](#user-content-requires) are met, then execute the following in a terminal.

✏️ *Replace `$APP_NAME` with the name for your unique app.*

```bash
npx create-react-app@2.x $APP_NAME
cd $APP_NAME
git init
heroku create $APP_NAME --buildpack mars/crak
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set TERRAFORM_BIN_URL=https://terraforming-buildpack.s3.amazonaws.com/terraform_0.11.9-pg.02_linux_amd64.zip
git add .
git commit -m "Start with create-react-app"
git push heroku master
heroku open
```

Then, [continue development](#user-content-continue-development) 🌱

For explanation about these steps, continue reading the [next section](#user-content-usage).


Usage
-----

### Generate a React app

✏️ *Replace `$APP_NAME` with the name for your unique app.*

```bash
npx create-react-app@2.x $APP_NAME
cd $APP_NAME
```

* [npx](https://medium.com/@maybekatz/introducing-npx-an-npm-package-runner-55f7d4bd282b) comes with npm 5.2+ and higher, see [instructions for older npm versions](https://gist.github.com/gaearon/4064d3c23a77c74a3614c498a8bb1c5f)
* if [yarn](https://yarnpkg.com) is installed locally, the new app will use it instead of [npm](https://www.npmjs.com)

### Make it a git repo

```bash
git init
```

At this point, this new repo is local, only on your computer. Eventually, you may want to [push to Github](#user-content-push-to-github).

### Create the Heroku app

✏️ *Replace `$APP_NAME` with the name for your unique app.*

```bash
heroku create $APP_NAME --buildpack mars/crak
```

This command:

* sets the [app name](https://devcenter.heroku.com/articles/creating-apps#creating-a-named-app) & its default URL `https://$APP_NAME.herokuapp.com`
* sets the app to use this [buildpack](https://devcenter.heroku.com/articles/buildpacks)
* configures the [`heroku` git remote](https://devcenter.heroku.com/articles/git#creating-a-heroku-remote) in the local repo, so `git push heroku master` will push to this new Heroku app.

### Create the database for Kong

The web server is a [Kong gateway](https://konghq.com/) that uses [Heroku Postgre](https://www.heroku.com/postgres) to store configuration of services, route, and plugins.

```bash
heroku addons:create heroku-postgresql:hobby-dev
```

### Enable Terraform with Postgres

[Terraform](https://www.terraform.io) is used to configure Kong routes. To enable [Heroku Postgres](https://www.heroku.com/postgres) as the Terraform backend, this app uses the `terraform` binary built from an unmerged pull request to Terraform (see: [hashicorp/terraform #19070](https://github.com/hashicorp/terraform/pull/19070)).

```bash
heroku config:set TERRAFORM_BIN_URL=https://terraforming-buildpack.s3.amazonaws.com/terraform_0.11.9-pg.02_linux_amd64.zip
```

### Commit & deploy ♻️

```bash
git add .
git commit -m "Start with create-react-app"
git push heroku master
```

…or if you are ever working on a branch other than `master`:

✏️ *Replace `$BRANCH_NAME` with the name for the current branch.*

```bash
git push heroku $BRANCH_NAME:master
```

### Visit the app's public URL in your browser

```bash
heroku open
```

### Visit the Heroku Dashboard for the app

Find the app on [your dashboard](https://dashboard.heroku.com).

### Continue Development

Work with your app locally using `npm start`. See: [create-react-app docs](https://github.com/facebookincubator/create-react-app#getting-started)

Then, commit & deploy ♻️

### Push to Github

Eventually, to share, collaborate, or simply back-up your code, [create an empty repo at Github](https://github.com/new), and then follow the instructions shown on the repo to **push an existing repository from the command line**.

### Testing

Use [create-react-app's built-in Jest testing](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#user-content-running-tests) or whatever testing library you prefer.

[Heroku CI](https://devcenter.heroku.com/articles/heroku-ci) is supported with minimal configuration. The CI integration is compatible with npm & yarn (see [`bin/test`](bin/test)).

#### Minimal `app.json`

Heroku CI uses [`app.json`](https://devcenter.heroku.com/articles/app-json-schema) to provision test apps. To support Heroku CI, commit this minimal example `app.json`:

```json
{
  "buildpacks": [
    {
      "url": "mars/crak"
    }
  ]
}
```

Customization
-------------

### Procfile

Heroku apps may declare what processes are launched for a successful deployment by way of the [`Procfile`](https://devcenter.heroku.com/articles/procfile). This buildpack's default process comes from [`heroku-community/kong` buildpack](https://github.com/heroku/heroku-buildpack-kong). (See: 🏙 [Architecture](#user-content-architecture-)).

The implicit `Procfile` for this buildpack is:

```
web: bin/heroku-buildpack-kong-web
release: bin/heroku-buildpack-crak-release
```

To customize an app's processes, commit a `Procfile` and deploy. Include the `web` & `release` processes as shown above to keep the default behaviors. Additional [process types](https://devcenter.heroku.com/articles/procfile#declaring-process-types) may be added to run any number of dynos with whatever arbitrary commands you want, and scale each independently.

### Web server

The web server may be [configured via Kong's nginx template](config/nginx.template). Simply copy the template file from this buildpack into your own app as `config/nginx.template`, and commit your own edits to the file.

👓 See [Nginx HTTP core docs](https://nginx.org/en/docs/http/ngx_http_core_module.html).

### Changing the root

If a different web server `"root"` is required, such as with a highly customized, ejected create-react-app project, then:

* `location /`'s' `root` must be set in [`config/nginx.template`](config/nginx.template)
* the new bundle location may need to be [set to enable runtime environment variables](#user-content-custom-bundle-location).

### Routing

🚥 *This buildpack automatically configures Kong to serve the React app from the root. **Client-side routing is supported by default.** Any server request that would result in 404 Not Found returns the React app.*

Create a [`routes.tf`](routes.tf) file to configure services, routes, & plugins with the [Kong Terraform provider](https://github.com/kevholditch/terraform-provider-kong).

Default [`routes.tf`](routes.tf) contains:

```hcl
resource "kong_service" "react" {
  name     = "create-react-app"
  protocol = "http"
  host     = "127.0.0.1"
  port     = 3000
}

resource "kong_route" "web_root" {
  protocols  = ["https", "http"]
  paths      = ["/"]
  service_id = "${kong_service.react.id}"
}
```

✏️ *When creating a custom [`routes.tf`](routes.tf), keep these `react` & `web_root` resources to preserve the original routing behavior.*

🔌 [Kong plugins](https://docs.konghq.com/hub/) may be used to provide access control and more. Configure them through the [Kong Terraform provider](https://github.com/kevholditch/terraform-provider-kong).


### HTTPS-only

Setup secure routes using Kong [Route `protocols`](https://docs.konghq.com/0.14.x/admin-api/#route-object).

Example HTTPS-only route defined in [`routes.tf`](routes.tf):

```hcl
resource "kong_route" "web_root" {
  protocols  = ["https"]
  paths      = ["/"]
  service_id = "${kong_service.react.id}"
}
```

### Authentication

Password-protect the app by adding the [basic-auth](https://docs.konghq.com/hub/kong-inc/basic-auth/) plugin to the `/` root route.

Example basic auth config, appended to [`routes.tf`](routes.tf):

```hcl
provider "random" {
  version = "~> 2.0"
}

resource "random_id" "private_access_password" {
  byte_length = 32
}

output "private_access_password" {
  value = "${random_id.private_access_password.b64_url}"
}

resource "kong_plugin" "react_basic_auth" {
  name        = "basic-auth"
  service_id  = "${kong_service.react.id}"

  config = {
    hide_credentials = "true"
  }
}

resource "kong_consumer" "private_access" {
  username = "private"
}

resource "kong_consumer_plugin_config" "private_access_credentials" {
  consumer_id = "${kong_consumer.private_access.username}"
  plugin_name = "basic-auth"

  config = {
    username = "private"
    password = "${random_id.private_access_password.b64_url}"
  }
}
```

Output the generated password with:

```
heroku run terraform output private_access_password
```

⚠️ *create-react-app's default ServiceWorker config may allow the site to reload without authentication. [Unregister the ServiceWorker](https://github.com/facebook/create-react-app/blob/v2.0.5/packages/react-scripts/template/README.md#making-a-progressive-web-app), if password should be required for every page load. Depending on the version of create-react-app used to generate the app, the ServiceWorker may or may not be enabled by default.*

🔌 [Kong plugins](https://docs.konghq.com/hub/) may be used to provide other types of authentication. Configure them through the [Kong Terraform provider](https://github.com/kevholditch/terraform-provider-kong).

### Proxy

Proxy XHR requests from the React UI in the browser to API backends. Use to prevent same-origin errors when [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) is not supported on the backend.

#### Proxy path prefix

To make calls through the proxy, use relative URL's in the React app which will be proxied to the configured target URL.

Using the Kong gateway included in this buildpack, here's how the proxy can rewrite requests:

```
/api/search-results
  → https://search.example.com/results
  
/api/accounts/users/me
  → https://accounts.example.com/users/me
```

#### Proxy for deployment

The [`heroku-community/kong` buildpack](https://github.com/heroku/heroku-buildpack-kong) (see: 🏙 [Architecture](#user-content-architecture-)) provides [dynamic routing & plugin configuration](https://docs.konghq.com/0.14.x/admin-api/) to utilize Nginx for high-performance proxies in production.

Define proxy config in [`routes.tf`](routes.tf) using the [Kong Terraform provider](https://github.com/kevholditch/terraform-provider-kong) to create a service & route.

For example, to configure this proxy:

```
/api/search-results
  → https://search.example.com/results
```

…use this config:

```hcl
resource "kong_service" "search_api" {
  name     = "search"
  protocol = "https"
  host     = "search.example.com"
  port     = 443
  path     = "/results"
}

resource "kong_route" "search_api" {
  protocols  = ["https"]
  paths      = ["/api/search-results"]
  service_id = "${kong_service.search_api.id}"
}
```

#### Proxy for local development

create-react-app itself provides a built-in [proxy for development](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#user-content-proxying-api-requests-in-development). This may be configured to match the behavior of [proxy for deployment](#user-content-proxy-for-deployment).

For example add `"proxy"` to `package.json`:

```json
{
  "proxy": {
    "/api/search-results": {
      "target": "http://localhost:8000",
      "pathRewrite": {
        "^/api/search-results": "/results"
      }
    }
  }
}
```

Replace `http://localhost:8000` with the URL to your local or remote backend service.


### Environment variables

[`REACT_APP_*` environment variables](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables) are fully supported with this buildpack.

🚫🤐 ***Not for secrets.** These values may be accessed by anyone who can see the React app.*

### [Set vars on Heroku](https://devcenter.heroku.com/articles/config-vars)

```bash
heroku config:set REACT_APP_HELLO='I love sushi!'
```

### Set vars for local dev

*Requires at least create-react-app 0.7. Earlier versions only support Compile-time.*

Create a `.env` file that sets a variable per line:

```bash
REACT_APP_API_URL=http://api.example.com
REACT_APP_CLIENT_ID=XyzxYzxyZ
```

### Compile-time vs Runtime

Two versions of variables are supported. In addition to compile-time variables applied during [build](https://github.com/facebookincubator/create-react-app#npm-run-build) the app supports variables set at runtime, applied as each web dyno starts-up.

Requirement | [Compile-time](#user-content-compile-time-configuration) | [Runtime](#user-content-runtime-configuration)
:--- |:---:|:---: 
never changes for a build | ✓ |  
support for [continuous delivery](https://www.heroku.com/continuous-delivery) |  | ✓
updates immediately when setting new [config vars](https://devcenter.heroku.com/articles/config-vars) |   | ✓
different values for staging & production (in a [pipeline](https://devcenter.heroku.com/articles/pipelines)) |   | ✓
ex: `REACT_APP_BUILD_VERSION` (static fact about the bundle) | ✓ | 
ex: `REACT_APP_DEBUG_ASSERTIONS` ([prune code from bundle](https://webpack.github.io/docs/list-of-plugins.html#defineplugin)) | ✓ | 
ex: `REACT_APP_API_URL` (transient, external reference) |   | ✓
ex: `REACT_APP_FILEPICKER_API_KEY` ([Add-on config vars](#user-content-add-on-config-vars)) |   | ✓

### Compile-time configuration

Supports [`REACT_APP_`](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables), `NODE_`, `NPM_`, & `HEROKU_` prefixed variables.

Use Node's [`process.env` object](https://nodejs.org/dist/latest-v10.x/docs/api/process.html#process_process_env).

```javascript
import React, { Component } from 'react';

class App extends Component {
  render() {
    return (
      <code>Runtime env var example: { process.env.REACT_APP_HELLO }</code>
    );
  }
}
```

♻️ The app must be re-deployed for compiled changes to take effect, because during the build, these references will be replaced with their quoted string value.

```bash
heroku config:set REACT_APP_HELLO='I love sushi!'

git commit --allow-empty -m "Set REACT_APP_HELLO config var"
git push heroku master
```

Only `REACT_APP_` vars are replaced in create-react-app's build. To make any other variables visible to React, they must be prefixed for the build command in `package.json`, like this:

```bash
REACT_APP_HEROKU_SLUG_COMMIT=$HEROKU_SLUG_COMMIT react-scripts build
```

### Runtime configuration

Supports only [`REACT_APP_`](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables) prefixed variables.

🚫🤐 ***Not for secrets.** These values may be accessed by anyone who can see the React app.*

Install the [runtime env npm package](https://www.npmjs.com/package/@mars/heroku-js-runtime-env):

```bash
npm install @mars/heroku-js-runtime-env --save
```

Then, require/import it to use the vars within components:

```javascript
import React, { Component } from 'react';
import runtimeEnv from '@mars/heroku-js-runtime-env';

class App extends Component {
  render() {
    // Load the env object.
    const env = runtimeEnv();

    // …then use values just like `process.env`
    return (
      <code>Runtime env var example: { env.REACT_APP_HELLO }</code>
    );
  }
}
```

⚠️ *Avoid setting backslash escape sequences, such as `\n`, into Runtime config vars. Use literal UTF-8 values only; they will be automatically escaped.*

#### Custom bundle location

If the javascript bundle location is customized, such as with an ejected created-react-app project, then the runtime may not  be able to locate the bundle to inject runtime variables.

To solve this so the runtime can locate the bundle, set the custom bundle path:

```bash
heroku config:set JS_RUNTIME_TARGET_BUNDLE=/app/my/custom/path/js/*.js
```

✳️ *Note this path is a `*` glob, selecting multiple files, because as of create-react-app version 2 the [bundle is split](https://reactjs.org/blog/2018/10/01/create-react-app-v2.html).*

To unset this config and use the default path for **create-react-app**'s bundle, `/app/build/static/js/*.js`:

```bash
heroku config:unset JS_RUNTIME_TARGET_BUNDLE
```

### Add-on config vars

🚫🤐 ***Be careful not to export secrets.** These values may be accessed by anyone who can see the React app.*

Use a custom [`.profile.d` script](https://devcenter.heroku.com/articles/buildpack-api#profile-d-scripts) to make variables set by other components available to the React app by prefixing them with `REACT_APP_`.

1. create `.profile.d/000-react-app-exports.sh`
1. make it executable `chmod +x .profile.d/000-react-app-exports.sh`
1. add an `export` line for each variable:

   ```bash
   export REACT_APP_ADDON_CONFIG=${ADDON_CONFIG:-}
   ```
1. set-up & use [Runtime configuration](#user-content-runtime-configuration) to access the variables

For example, to use the API key for the [Filestack](https://elements.heroku.com/addons/filepicker) JS image uploader:

```bash
export REACT_APP_FILEPICKER_API_KEY=${FILEPICKER_API_KEY:-}
```

npm Private Packages
-------------------
Private modules are supported during build.

1. Setup your app with a `.npmrc` file following [npm's guide for CI/deployment](https://docs.npmjs.com/private-modules/ci-server-config).
1. Set your secret in the `NPM_TOKEN` config var:

    ```bash
    heroku config:set NPM_TOKEN=xxxxx
    ```

Kong Admin API
--------------

### Admin console

Use `kong` CLI and access [Kong's HTTP/REST Admin API](http://docs.konghq.com/0.14.x/admin-api/) in a [one-off dyno](https://devcenter.heroku.com/articles/one-off-dynos):

✏️ *Replace `$APP_NAME` with the Heroku app name.*

```bash
heroku run bash --app $APP_NAME
```

Run Kong in the background of the one-off dyno:

```bash
~ $ bin/heroku-buildpack-kong-background-start
```

Use [`curl`](https://ec.haxx.se/cmdline-options.html) to issue Admin API commands:

```bash
~ $ curl http://localhost:8001
~ $ curl http://localhost:8001/status
~ $ curl http://localhost:8001/services
~ $ curl http://localhost:8001/routes
```

Execute CLI commands:

⚠️ *Some commands require the config file and others the prefix.*

✏️ *The `$KONG_CONF` variable is already defined.*

```bash
~ $ kong migrations list -c $KONG_CONF
~ $ kong health -p /app/kong-runtime
```

### Expose the Admin API
[Kong Admin API](http://docs.konghq.com/0.14.x/admin-api/) has no built-in authentication. Its exposure must be limited to a restricted, private network. For Kong on Heroku, the Admin API listens privately on `localhost:8001`.

To make Kong Admin API accessible from other locations, let's setup a secure [loopback proxy](https://docs.konghq.com/0.14.x/secure-admin-api/#kong-api-loopback) with key authentication, HTTPS-enforcement, and request rate & size limiting.

First, set a strong, cryptographic Admin Key into the Heroku config var:

```bash
heroku config:set TF_VAR_kong_admin_key=<your unique key>
```

Then, define Admin API config in the [`routes.tf`](routes.tf) file using the [Kong Terraform provider](https://github.com/kevholditch/terraform-provider-kong) to create a service, route, & plugins:

```hcl
variable "kong_admin_key" {
  type = "string"
}

resource "kong_service" "kong_admin_api" {
  name     = "kong-admin"
  protocol = "http"
  host     = "127.0.0.1"
  port     = 8001
}

resource "kong_route" "kong_admin_api" {
  protocols  = ["https"]
  paths      = ["/kong-admin"]
  service_id = "${kong_service.kong_admin_api.id}"
}

resource "kong_plugin" "kong_admin_api_request_size" {
  name       = "request-size-limiting"
  service_id = "${kong_service.kong_admin_api.id}"

  config = {
    allowed_payload_size = 8
  }
}

resource "kong_plugin" "kong_admin_api_rate" {
  name       = "rate-limiting"
  service_id = "${kong_service.kong_admin_api.id}"

  config = {
    minute = 5
  }
}

resource "kong_plugin" "kong_admin_api_key_auth" {
  name       = "key-auth"
  service_id = "${kong_service.kong_admin_api.id}"

  config = {
    hide_credentials = true
  }
}

resource "kong_plugin" "kong_admin_api_acl" {
  name       = "acl"
  service_id = "${kong_service.kong_admin_api.id}"

  config = {
    whitelist = "kong-admin"
  }
}

resource "kong_consumer" "kong_admin_api_consumer" {
  username  = "heroku-admin"
}

resource "kong_consumer_plugin_config" "kong_admin_api_consumer_config_acls" {
  consumer_id = "${kong_consumer.kong_admin_api_consumer.id}"
  plugin_name = "acls"

  config = {
    group = "kong-admin"
  }
}

resource "kong_consumer_plugin_config" "kong_admin_api_consumer_config_key_auth" {
  consumer_id = "${kong_consumer.kong_admin_api_consumer.id}"
  plugin_name = "key-auth"
  
  config = {
    key = "${var.kong_admin_key}"
  }
}
```

Commit & deploy these [`routes.tf`](routes.tf) changes to the app.

Now, access Kong's Admin API via the protected, public-facing proxy:

✏️ *Replace variables such as `$ADMIN_KEY` & `$APP_NAME` with values for your unique deployment.*

```bash
# Set the key in the request header:
curl -H "apikey: $ADMIN_KEY" https://$APP_NAME.herokuapp.com/api/kong-admin/status
```

Troubleshooting
---------------

1. Confirm that your app is using this buildpack:

    ```bash
    heroku buildpacks
    ```
    
    If it's not using `crak-buildpack`, then set it:

    ```bash
    heroku buildpacks:set mars/crak
    ```

    …and deploy with the new buildpack:

    ```bash
    git commit --allow-empty -m 'Switch to crak-buildpack'
    git push heroku master
    ```
    
    If the error still occurs, then at least we know it's really using this buildpack! Proceed with troubleshooting.
1. Check this README to see if it already mentions the issue.
1. Search our [issues](https://github.com/mars/crak-buildpack/issues?utf8=✓&q=is%3Aissue%20) to see if someone else has experienced the same problem.
1. Search the internet for mentions of the error message and its subject module, e.g. `ENOENT "node-sass"`
1. File a new [issue](https://github.com/mars/crak-buildpack/issues/new). Please include:
   * build log output
   * link to GitHub repo with the source code (if private, grant read access to @mars)


Version compatibility
---------------------

This buildpack will never intentionally cause previously deployed apps to become undeployable. Using master [as directed in the main instructions](#user-content-create-the-heroku-app) will always deploy an app with the most recent version of this buildpack.

[Releases are tagged](https://github.com/mars/crak-buildpack/releases), so you can lock an app to a specific version, if that kind of determinism pleases you:

```bash
heroku buildpacks:set https://github.com/mars/crak-buildpack.git#v6.0.0
```

✏️ *Replace `v6.0.0` with the desired [release tag](https://github.com/mars/crak-buildpack/releases).*

♻️ Then, commit & deploy to rebuild on the new buildpack version.


Architecture 🏙
------------

This buildpack combines several buildpacks, specified in [`.buildpacks`](.buildpacks), to support **zero-configuration deployment** on Heroku:

1. [`heroku/nodejs` buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
   * installs `node`, puts on the `$PATH`
   * version specified in [`package.json`, `engines.node`](https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version)
   * `node_modules/` cached between deployments
   * `NODE_ENV` at buildtime:
     * defaults to `NODE_ENV=development` to install the build tooling of create-react-app's dev dependencies, like `react-scripts`
     * honors specific setting of `NODE_ENV`, like `NODE_ENV=test` for [automated testing](#user-content-testing) in [`bin/test`](bin/test-compile)
     * but forces `NODE_ENV=production` to be `development` to ensure dev dependencies are available for build
2. [`mars/create-react-app-inner-buildpack`](https://github.com/mars/create-react-app-inner-buildpack)
   * production build for create-react-app
     * executes the npm package's build script; create-react-app default is `react-scripts build`
     * exposes `REACT_APP_`, `NODE_`, `NPM_`, & `HEROKU_` prefixed env vars to the build script
     * generates a production bundle regardless of `NODE_ENV` setting
   * sets default [web server config](#user-content-web-server) unless `static.json` already exists
   * enables [runtime environment variables](#user-content-environment-variables)
3. [`mars/terraforming`](https://github.com/mars/terraforming-buildpack)
   * declarative configuration of routing behavior with the [Kong Terraform provider](https://github.com/kevholditch/terraform-provider-kong)
   * `terraform apply` is run in [release phase](https://devcenter.heroku.com/articles/release-phase)
3. [`heroku-community/kong` buildpack](https://github.com/heroku/heroku-buildpack-kong)
   * [root route automatically configured](#user-content-routing) to serve the React app

🚀 The runtime `web` process is [`bin/heroku-buildpack-kong-web`](https://github.com/heroku/heroku-buildpack-kong/blob/master/bin/app/heroku-buildpack-kong-web), which launches Kong's Nginx web server. Processes may be customized by committing a [Procfile](#user-content-procfile) to the app.
