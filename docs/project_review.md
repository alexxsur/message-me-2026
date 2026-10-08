# Message Me Project Review

## Purpose and Accuracy

These notes summarize the application's current state and provide a learning-oriented reconstruction of the development process. The repository does not contain a verified command history, so commands described as possible or likely are illustrative, not confirmed records.

## Prerequisites

The project README lists Ruby 3.3.10 and PostgreSQL as local requirements.

This application uses PostgreSQL. The `pg` gem is the Ruby adapter; it does not install the PostgreSQL server.

The project also uses `cssbundling-rails` with Bootstrap. Node.js and Yarn are required to install JavaScript packages and build the CSS. The repository uses `yarn.lock` and Yarn commands in its package scripts.

On Debian or Ubuntu, PostgreSQL and its development headers can be installed with:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib libpq-dev
```

Installation commands vary by operating system. Start PostgreSQL using the service manager available on the system.

## Local Setup Sequence

Run these steps from the project directory.

### 1. Configure local database environment variables

The project README documents copying the example environment file:

```bash
cp .env.example .env
```

Set local values for `PGHOST`, `PGPORT`, `PGUSER`, and `PGPASSWORD` in `.env`. Do not commit real credentials.

The project's `config/database.yml` reads these variables and defaults to port `5433`.

### 2. Install project dependencies

```bash
bundle install
```

Bundler installs the gems declared in the `Gemfile`, using `Gemfile.lock` to keep dependency versions consistent.

Install the JavaScript and CSS build dependencies from `package.json` using the existing Yarn lockfile:

```bash
yarn install --frozen-lockfile
```

### 3. Check that PostgreSQL accepts connections

```bash
pg_isready -h localhost -p 5433
```

Use the host and port configured for the local PostgreSQL server.

### 4. Prepare the Rails database

```bash
bin/rails db:prepare
```

This creates or prepares the database required by the application.

### 5. Verify the Rails database connection

```bash
bin/rails runner 'puts ActiveRecord::Base.connection.select_value("SELECT 1")'
```

### 6. Build the CSS

```bash
yarn build:css
```

This compiles `application.bootstrap.scss` into the CSS asset served by Rails. Run this command again after changing the SCSS source files.

### 7. Start the Rails server

```bash
bin/rails s
```

This starts the Rails server. Open `http://localhost:3000` to test the application locally.

## Possible Original Development Steps

The following commands are plausible ways to create the initial application and screens, but cannot be verified from the repository. The `rails new` command is for creating a new project; do not run it from inside this existing project.

### Create the Rails application

```bash
rails new message-me --database=postgresql
```

This creates a Rails project configured to use PostgreSQL.

### Generate the chatroom controller and view

```bash
bin/rails generate controller Chatroom index
```

The existing chatroom view is still a placeholder.

### Generate the login controller and view

```bash
bin/rails generate controller Sessions new
```

The login form, credential validation, and session handling still need to be implemented.

### Add Bootstrap CSS support

The following commands are a plausible way the current CSS integration was added:

```bash
bundle add cssbundling-rails
bin/rails css:install:bootstrap
```

The installer configures the Sass entry point and package scripts. The current project declares Bootstrap `5.3.8`, Bootstrap Icons `1.13.1`, and Popper `2.11.8` in `package.json`; `yarn.lock` records the resolved package versions.

The routes currently present in `config/routes.rb` are:

```ruby
root "chatroom#index"
get "login", to: "sessions#new"
```

## Current Application State

Message Me is a Rails application configured to use PostgreSQL.

- `GET /` routes to `ChatroomController#index`.
- `GET /login` routes to `SessionsController#new`.
- The chatroom view has a static messaging interface with sample activity, a message input, and a sidebar; messaging and online-user data are not dynamic.
- The login view has a visual username/password form, but authentication is not implemented. Its Sign Up link points to `/signup`, which has no route configured.
- No user or message models or domain migrations were found.
- No feature tests were found.
- Turbo, Stimulus, and Solid Cable are dependencies, but real-time messaging has not been implemented.
- Bootstrap CSS is configured through `cssbundling-rails`; its Sass entry point imports Bootstrap and Bootstrap Icons.


## Dependency Maintenance

Check whether the current dependencies are installed:

```bash
bundle check
```

Check which gems have newer versions available:

```bash
bundle outdated
```

Update all gems to the newest versions allowed by the `Gemfile`:

```bash
bundle update
```

This may update many entries in `Gemfile.lock`. Review the changes and run the test suite afterward:

```bash
bin/rails test
```

Update one gem and its compatible dependencies:

```bash
bundle update <gem_name>
```

For example, update the PostgreSQL adapter with:

```bash
bundle update pg
```

Review changes to `Gemfile.lock` and run the test suite after updating. Use Bundler to manage project dependencies rather than `gem update`, which does not follow the project's lockfile workflow.