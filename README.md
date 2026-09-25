# Message Me

Quick local setup guide for running the app in development.

## Requirements

- Ruby 3.3.10
- PostgreSQL running locally

## Local setup (step by step)

1. Go to the project directory.

	cd /.../message-me

2. Create your local environment file.

	cp .env.example .env

3. Edit .env with real values.

	PGHOST=localhost
	PGPORT=5433
	PGUSER=postgres
	PGPASSWORD=your_real_password

4. Prepare the database. Rails loads `.env` automatically in development and test.

	bin/rails db:prepare

5. Start the app.

	bin/rails s

## About environment variables

- .env is used for local development values such as PGHOST, PGPORT, PGUSER, and PGPASSWORD.
- dotenv-rails loads `.env` automatically when Rails starts in development or test, so `bin/rails` commands and the server receive those values.
- A terminal opened before Rails starts will not show those variables automatically. Use direnv or source `.env` only when shell commands themselves need them.
- direnv is optional. It helps load those variables automatically when you enter the project directory. It is most common in Linux/macOS shells, although it can also be used in Windows through WSL or other compatible setups.
- dotenv is another common option for local development. It loads values from a .env file when the application starts, which can be useful if you prefer that approach. It can be used on Linux and Windows as long as the app or runtime is configured to load the .env file.
- On Windows, you can also set the same variables manually in PowerShell. This is a simple alternative when you do not want to use direnv or dotenv.
- In production, these values are usually provided directly by the deployment platform or server (for example Docker, Heroku, Render, AWS, or Kubernetes), rather than from a local .env file.

## Automatic per-project loading with direnv (Linux/macOS)

This step is optional. direnv is mainly useful on Linux/macOS shells. If you are on Windows, you can set the same variables manually in PowerShell or use WSL for a Linux-like environment.

1. Install direnv and enable zsh hook.

	sudo apt-get install -y direnv
	echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
	source ~/.zshrc

2. Create .envrc in the project root.

	set -a
	source .env
	set +a

3. Allow direnv for this project.

	direnv allow

After this, environment variables are loaded automatically when entering the project directory.

## Why localhost worked better than 127.0.0.1

In this environment, PGHOST=localhost behaved better than PGHOST=127.0.0.1.

Possible reasons:

- localhost may resolve differently (IPv4 or IPv6) depending on OS configuration.
- PostgreSQL authentication rules in pg_hba.conf can differ by address family.
- PostgreSQL listener settings (listen_addresses and port) may not match a forced address.

Practical recommendation:

- If 127.0.0.1 fails and localhost works, use localhost in .env.

## Troubleshooting commands

Use these commands to quickly diagnose DB connection issues.

1. Check local PostgreSQL listeners.

	ss -lnt '( sport = :5432 or sport = :5433 )'

2. Check readiness on common ports.

	pg_isready -h 127.0.0.1 -p 5432
	pg_isready -h 127.0.0.1 -p 5433

3. Verify values loaded from .env without showing password.

	awk -F= '/^(PGHOST|PGPORT|PGUSER)=/{print $0} /^PGPASSWORD=/{print "PGPASSWORD="(length($2)>0?"SET":"EMPTY")}' .env

4. Validate Rails DB connection.

	bin/rails db:prepare
	bin/rails runner 'puts ActiveRecord::Base.connection.select_value("SELECT 1")'
