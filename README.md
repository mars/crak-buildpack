Heroku Buildpack for create-react-app with Kong gateway
=======================================================

🔬👨‍🔬 **The project is currently experimental, unstable.**

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
    * [HTTPS-only](#user-content-https-only)
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
npx create-react-app $APP_NAME
cd $APP_NAME
git init
heroku create $APP_NAME --buildpack mars/crak
heroku addons:create heroku-postgresql:hobby-dev
git add .
git commit -m "Start with create-react-app"
git push heroku master
heroku open
```

Once deployed, [continue development](#user-content-continue-development) 🌱

For explanation about these steps, continue reading the [next section](#user-content-usage).


Usage
-----

### Generate a React app

✏️ *Replace `$APP_NAME` with the name for your unique app.*

```bash
npx create-react-app $APP_NAME
cd $APP_NAME
```

* [npx](https://medium.com/@maybekatz/introducing-npx-an-npm-package-runner-55f7d4bd282b) comes with npm 5.2+ and higher, see [instructions for older npm versions](https://gist.github.com/gaearon/4064d3c23a77c74a3614c498a8bb1c5f)
* If [yarn](https://yarnpkg.com) is installed locally, the new app will use it instead of [npm](https://www.npmjs.com).

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

Heroku apps may declare what processes are launched for a successful deployment by way of the [`Procfile`](https://devcenter.heroku.com/articles/procfile). This buildpack's default process comes from [`heroku-community/kong` buildpack](https://github.com/heroku/heroku-buildpack-kong). (See: 🏙 [Architecture](#user-content-architecture-)). The implicit `Procfile` to start the static web server is:

```
web: bin/heroku-buildpack-kong-web
```

To customize an app's processes, commit a `Procfile` and deploy. Include `web: bin/heroku-buildpack-kong-web` to launch the default web process, or you may replace the default web process. Additional [process types](https://devcenter.heroku.com/articles/procfile#declaring-process-types) may be added to run any number of dynos with whatever arbitrary commands you want, and scale each independently.

🚦 *If replacing the default web process, please check this buildpack's [Purpose](#user-content-purpose) to avoid misusing this buildpack (such as running a Node server) which can lead to confusing deployment issues.*

### Web server

The web server may be [configured via Kong's nginx template](config/nginx.template). Simply copy the template file from this buildpack into your own app as `config/nginx.template`, and commit your own edits to the file.

👓 See [Nginx HTTP core docs](https://nginx.org/en/docs/http/ngx_http_core_module.html).

### Changing the root

If a different web server `"root"` is required, such as with a highly customized, ejected create-react-app project, then:

* `location /`'s' `root` must be set in [`config/nginx.template`](config/nginx.template)
* the new bundle location may need to be [set to enable runtime environment variables](#user-content-custom-bundle-location).

### Routing clean URLs

*The default behavior now routes all unmatched requests to the React app for client-side routing.*

### HTTPS-only

*TODO Define HTTPS-only with Nginx*

### Proxy

Proxy XHR requests from the React UI in the browser to API backends. Use to prevent same-origin errors when [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) is not supported on the backend.

#### Proxy path prefix

To make calls through the proxy, use relative URL's in the React app which will be proxied to the configured target URL.

Using the Kong gateway included in this buildpack, there are two level of prefixing. In `/api/service/`:

  * `/api/` is Kong's prefix
  * `/api/` + `service/` is the complete backend-specific prefix

Here's how the proxy might rewrite a few requests:

```
/api/search/results
  → https://search.example.com/results
  
/api/accounts/users/me
  → https://accounts.example.com/users/me
```

#### Proxy for deployment

The [`heroku-community/kong` buildpack](https://github.com/heroku/heroku-buildpack-kong) (see: 🏙 [Architecture](#user-content-architecture-)) provides [dynamic routing & plugin configuration](https://docs.konghq.com/0.14.x/admin-api/) to utilize Nginx for high-performance proxies in production.

Define proxy config with Kong using its [Admin API](#user-content-kong-admin-api) to create a service & route:

```bash

```bash
curl http://localhost:8001/services/ -i -X POST \
  --data 'name=sushi' \
  --data 'protocol=https' \
  --data 'port=443' \
  --data 'host=sushi.herokuapp.com'
# Note the Service ID returned in previous response, use it in place of `$SERVICE_ID`.
curl http://localhost:8001/routes/ -i -X POST \
  --data 'paths[]=/api/sushi' \
  --data 'protocols[]=https' \
  --data "service.id=$SERVICE_ID"
```

List existing services & routes:

```bash
curl http://localhost:8001/services/
curl http://localhost:8001/routes/
```

👓 See: [Kong Admin API docs](https://docs.konghq.com/0.14.x/admin-api/)

#### Proxy for local development

create-react-app itself provides a built-in [proxy for development](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#user-content-proxying-api-requests-in-development). This may be configured to match the behavior of [proxy for deployment](#user-content-proxy-for-deployment).

Add `"proxy"` to `package.json`:

```json
{
  "proxy": {
    "/api/sushi": {
      "target": "http://localhost:8000",
      "pathRewrite": {
        "^/api/sushi": "/"
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
heroku config:set JS_RUNTIME_TARGET_BUNDLE=/app/my/custom/path/js/main.*.js
```

To unset this config and use the default path for **create-react-app**'s bundle, `/app/build/static/js/main.*.js`:

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
Use Kong CLI and the Admin API in a [one-off dyno](https://devcenter.heroku.com/articles/one-off-dynos):

### Admin console
✏️ *Replace `$APP_NAME` with the Heroku app name.*

```bash
heroku run bash --app $APP_NAME

# Run Kong in the background of the one-off dyno:
~ $ bin/heroku-buildpack-background-start

# Then, use `curl` to issue Admin API commands:
# (Note: the `$KONG_ADMIN_LISTEN` variable is already defined)
~ $ curl http://$KONG_ADMIN_LISTEN

# Example CLI commands:
# (Note: some commands require the config file and others the prefix)
# (Note: the `$KONG_CONF` variable is already defined)
~ $ kong migrations list -c $KONG_CONF
~ $ kong health -p /app/kong-runtime
```

### Expose the Admin API
Kong's Admin API has no built-in authentication. Its exposure must be limited to a restricted, private network. For Kong on Heroku, the Admin API listens privately on `localhost:8001`.

To make Kong Admin API accessible from other locations, let's setup a secure [loopback proxy](https://docs.konghq.com/0.14.x/secure-admin-api/#kong-api-loopback) with key authentication, HTTPS-enforcement, and request rate & size limiting.

From the [admin console](#user-content-admin-console):
```bash
# Create the authenticated `/kong-admin` API, targeting the localhost port:
curl http://localhost:8001/services/ -i -X POST \
  --data 'name=kong-admin' \
  --data 'protocol=http' \
  --data 'port=8001' \
  --data 'host=localhost'
# Note the Service ID returned in previous response, use it in place of `$SERVICE_ID`.
curl http://localhost:8001/plugins/ -i -X POST \
  --data 'name=request-size-limiting' \
  --data "config.allowed_payload_size=8" \
  --data "service_id=$SERVICE_ID"
curl http://localhost:8001/plugins/ -i -X POST \
  --data 'name=rate-limiting' \
  --data "config.minute=5" \
  --data "service_id=$SERVICE_ID"
curl http://localhost:8001/plugins/ -i -X POST \
  --data 'name=key-auth' \
  --data "config.hide_credentials=true" \
  --data "service_id=$SERVICE_ID"
curl http://localhost:8001/plugins/ -i -X POST \
  --data 'name=acl' \
  --data "config.whitelist=kong-admin" \
  --data "service_id=$SERVICE_ID"
curl http://localhost:8001/routes/ -i -X POST \
  --data 'paths[]=/api/kong-admin' \
  --data 'protocols[]=https' \
  --data "service.id=$SERVICE_ID"

# Create a consumer with username and authentication credentials:
curl http://localhost:8001/consumers/ -i -X POST \
  --data 'username=heroku-admin'
curl http://localhost:8001/consumers/heroku-admin/acls -i -X POST \
  --data 'group=kong-admin'
curl http://localhost:8001/consumers/heroku-admin/key-auth -i -X POST -d ''
# …this response contains the `"key"`, use it for `$ADMIN_KEY` below.
```

Now, access Kong's Admin API via the protected, public-facing proxy:

✏️ *Replace variables such as `$APP_NAME` with values for your unique deployment.*

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
3. [`heroku-community/kong` buildpack](https://github.com/heroku/heroku-buildpack-kong)
   * serves [static website & APIs from Kong](https://docs.konghq.com/0.14.x/configuration/#serving-both-a-website-and-your-apis-from-kong)
   * Kong proxy base URL is `/api/`

🚀 The runtime `web` process is the [last buildpack](https://github.com/mars/crak-buildpack/blob/master/.buildpacks)'s default processes. Kong buildpack uses [`bin/heroku-buildpack-kong-web`](https://github.com/heroku/heroku-buildpack-static/blob/master/bin/release) to launch its Nginx web server. Processes may be customized by committing a [Procfile](#user-content-procfile) to the app.
