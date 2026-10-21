# Message Me Project Review

## Purpose and Accuracy

These notes summarize the application's current state and provide a learning-oriented reconstruction of the development process. The repository does not contain a complete command history, so commands described as possible or likely are illustrative unless explicitly confirmed. The project owner confirmed that `rails generate channel Chatroom` was run.

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

This creates or prepares the database required by the application and runs pending migrations.

To load the sample data (5 users with 4 messages each; development-only password `password123`):

```bash
bin/rails db:seed
```

The seeds are idempotent: running them again does not duplicate records.

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

The chatroom now lists saved messages and includes a form for creating new ones. The form submits to `MessagesController#create`, and new messages are appended to the list in real time through Action Cable (see Action Cable implementation status).

### Generate the login controller and view

```bash
bin/rails generate controller Sessions new
```

The login form, credential validation, session handling, and logout were implemented afterwards (see Current Application State).

To undo a controller scaffold created with `generate controller`, use `destroy controller` with the same arguments. For example:

```bash
bin/rails destroy controller Chatroom index
```

This removes the generated controller and related files for the `index` action; it does not delete database records. Review the files first, since customized files may also be removed.

### Create the User and Message resources

The `users` and `messages` tables were likely created with migrations such as:

```bash
bin/rails generate migration CreateUsers username:string password_digest:string
bin/rails generate migration CreateMessages body:text user:references
bin/rails db:migrate
```

The models are written manually in `app/models/`, with `has_secure_password` (bcrypt) on `User` and `belongs_to :user` on `Message`. Do not use `generate model` for a table whose migration already exists; it would create a duplicate migration.

`bin/rails db:rollback` reverts only the last applied migration; use `STEP=n` to revert more.

To create a user from the console, pass `password:` (not `password_digest:`):

```bash
bin/rails console
```

```ruby
User.create(username: "alex", password: "my_password")
```

### Inspect records with Hirb

`hirb` is included in the development group and can format Active Record collections as tables in the Rails console. Enable it for the current console session, then query users or messages:

```ruby
Hirb.enable
User.limit(5)
Message.includes(:user).limit(5)
```

Call `Hirb.disable` to return to the default console output.

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
post "login", to: "sessions#create"
delete "logout", to: "sessions#destroy"
```

## Current Application State

Message Me is a Rails application configured to use PostgreSQL.

- `GET /` routes to `ChatroomController#index`.
- `GET /login` routes to `SessionsController#new`; `POST /login` to `SessionsController#create`; `DELETE /logout` to `SessionsController#destroy`.
- `SessionsController` redirects already logged-in users away from `new` and `create` to `/` with an "already logged in" alert.
- Flash messages are rendered by the `shared/_flash_messages` partial as dismissible Bootstrap alerts.
- `ChatroomController` uses `before_action :require_login`, so visitors without an active session are redirected to `/login` with an alert.
- `ApplicationController` defines `current_user`, `logged_in?` and `require_login`; the first two are exposed to views with `helper_method`.
- The chatroom controller loads the last 20 messages with `Message.includes(:user).recent`, and the view renders each message through a `messages/_message` partial. The message form submits to `MessagesController#create`, which saves the message for the logged-in user and responds with `204 No Content` on success (the page is not reloaded; the broadcast adds the message). On validation errors it redirects back with an alert. The online-users sidebar is still static.
- Login authenticates with `has_secure_password`, resets the session on login and logout, and shows flash messages. The layout shows Log out only when logged in, and Log in/Sign up only when logged out. The login view's Sign Up link points to `/signup`, which has no route configured.
- `User` uses `has_secure_password` (bcrypt), validates `username` (present, unique, 3 to 15 characters), and has many messages.
- `Message` belongs to a `User`, requires a `body`, has a `recent` scope (last 20 messages in chronological order), and after commit broadcasts the message as JSON (`id`, `body`, `created_at`, `user`) to the `chatroom_channel` stream.
- `db/seeds.rb` creates 5 users with 4 messages each.
- Signup is not implemented. Message creation is available to logged-in users through `POST /messages`.
- `ChatroomChannel` streams from `chatroom_channel` and the client subscribes to it. The client `received` callback appends each message to the `#messages` list using `textContent`, and a `chat-form` Stimulus controller clears the input after a successful submit.
- `config/cable.yml` uses the async adapter in development, the test adapter in tests, and Solid Cable in production. The adapter only transports the broadcasts; the UI still has to render them.
- Bootstrap CSS is configured through `cssbundling-rails`; its Sass entry point imports Bootstrap and Bootstrap Icons.

### Action Cable implementation status

Done: the channel scaffold, the `chatroom_channel` stream, the JSON broadcast from `Message` (`after_create_commit`), rendering of received messages in the list, and no redirect after a successful create.

Pending:

- `ApplicationCable::Connection` is empty; identify the connection with `current_user` and reject unauthenticated connections.
- Update the controller test and add a channel test.

This command was run to generate the Action Cable channel scaffolding:

```bash
rails generate channel Chatroom
```

The generated `ChatroomChannel` and client subscription files are present. Do not rerun the generator because the scaffold already exists.

### Action Cable allowed origins

By default Action Cable only accepts WebSocket connections from the app's own origin. Both options below are commented out in `config/environments/development.rb`; use only one:

- `config.action_cable.disable_request_forgery_protection = true` turns the origin check off and accepts every origin. Least secure; avoid it outside quick local tests.
- `config.action_cable.allowed_request_origins = ["http://localhost:3000"]` keeps the check and accepts only the listed origins (strings or regexes). Recommended when the app is opened from another host/port or from a separate frontend, and required in production (for example `["https://yourdomain.com"]`).

If the first option is set, the second is ignored.

### Model code ordering convention

Keep model declarations in this order, as in `app/models/message.rb`:

1. Constants, `include` and `enum`
2. Associations (`belongs_to`, `has_many`)
3. Validations
4. Callbacks (for example `after_create_commit :broadcast_message`)
5. Scopes and class methods
6. Public instance methods
7. `private`, including the methods used by callbacks

Order only matters between callbacks of the same type, which run in the order declared; the rest is convention. Keep callback methods such as `broadcast_message` private.

### Design decision: broadcast from the model, not a service object

The message broadcast lives in a `Message` `after_create_commit` callback rather than in the controller or a service object. It runs for every creation path (controller, seeds, console, a future API), only after the transaction commits, and keeps `MessagesController` thin.

A service object is a plain Ruby class in `app/services/` that wraps one business action behind a `call` method (for example `Messages::Create.call(user:, body:)`). It is not used here because creating a message is a single, simple step. Consider extracting one if creation grows to several steps (notifications, email, auditing) or if side effects depend on context, such as not broadcasting during seeds or imports. Moving the broadcast out of the callback at that point is a small refactor. Delegating the broadcast to a job (`MessageBroadcastJob`) is a lighter option if the model should not know the JSON format.

### The `recent` scope

`Message.recent(limit = 20)` is defined as `order(:created_at).last(limit)`. Rails runs a single query (`ORDER BY created_at DESC LIMIT 20`) and returns those messages in chronological order.

`last` executes the query and returns an Array, not an `ActiveRecord::Relation`, so nothing can be chained after `recent`. Put `includes(:user)` and any filters before it:

```ruby
Message.includes(:user).recent
```

Only the initial page load is limited. Messages arriving through Action Cable are appended without trimming the list. The chat list has a fixed height (`.chatroom-messages`) with internal scrolling, and `scrollToBottom` in `chatroom_channel.js` keeps the latest message visible.

For a chainable scope, use a subquery instead: `where(id: unscoped.order(created_at: :desc).limit(limit).select(:id)).order(:created_at)`.

### Rendering messages with a partial

The chatroom view uses `<%= render @messages %>` to render the `@messages` collection. Rails infers that each record is a `Message`, looks for `app/views/messages/_message.html.erb`, and renders that partial once per record. Each record is available in the partial as the local variable `message`.

The underscore at the start of `_message.html.erb` identifies it as a partial; when referencing it with an explicit render call, use the path without the underscore:

```erb
<%= render partial: "messages/message", collection: @messages, as: :message %>
```

The explicit form above is equivalent to `<%= render @messages %>` here. Keep the partial in the view folder for its resource (`app/views/messages/`) and use the singular resource name for the filename and local variable.


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