# inga

The repository for the Inga Foundation project.

## Getting Started with Development

Follow these steps to set up this project for development.

### A Note for Windows Users

Instructions provided here are for **Linux and MacOS users**. If you are on
Windows, we _strongly recommend_ installing [Windows Subsystem for Linux
(WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) to get the best
development experience, and to be able to work with the tools mentioned in this
guide.

### Prerequisites

- **Ruby 3.4.1** (required)
  - We strongly recommend using a Ruby _version manager_ such as
    [`rbenv`](https://github.com/rbenv/rbenv) to manage Ruby versions.
- `watchman` (optional but recommended): used to refresh CSS in real time
  during development with this setup
  - Can be installed using `brew install watchman` (Homebrew required first,
    see step 1 in next section for doing so)

#### Example: Installing Ruby with `rbenv` (macOS/Linux)

1. Install Homebrew (if not already installed):
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Install rbenv:
   ```
   brew install rbenv
   ```
3. Initialize rbenv:

   ```
   rbenv init
   ```

   IMPORTANT: Follow the instructions to add rbenv to your shell and restart your shell.

4. Install Ruby 3.4.1:

   ```
   rbenv install 3.4.1
   rbenv global 3.4.1
   ```

5. Install Bundler:
   ```
   gem install bundler
   ```

### Project Setup

1. Install dependencies:

   ```
   bundle install
   ```

2. Set up and seed the database (see [next
   section](#additional-info-user-database-seeds) for details on what seeding the
   database entails):

   ```
   bundle exec rails db:reset
   ```

3. Start the development server:

   ```
   bin/dev
   ```

4. [Optional] Run the tests:
   ```
   bundle exec rails test
   ```

### Additional Info: User Database Seeds

Seeding the database using `bundle exec rails db:seed` or `bundle exec rails
db:reset` (as described by the previous section) will populate the database
with **four users** that you can use to login and test the application. Each one
has a different role; you can use them to test the behaviour of pages from
different perspectives. Below are the credentials:

#### Admin User

Can manage users.

```
Username: admin
Password: a
```

#### Reporter

Can create log entries or journal entries.

```
Username: reporter
Password: a
```

#### Analyst

Can generate reports for donors.

```
Username: analyst
Password: a
```

#### Super User

Has all three of the above roles.

```
Username: super
Password: a
```

**Note:** the above roles are not disjoint; that is, one user may have multiple
roles that allow them to use the application for multiple functions.

**Note:** the above user accounts are created in the [user seeds file](db/seeds/users.rb).
There are also seeds for other models (see all seeds [here](db/seeds.rb))
that will be helpful in testing the application with some realistic data.

## Running Formatters or Linters

Running formatters and linters before making a PR is **mandatory** for CI
checks to pass. This section describes how you can run formatters/linters on
the codebase prior to submitting your changes.

### Ruby

#### Formatting and Linting

The linter/formatter is the same for Ruby: `rubocop`. You can run `rubocop` using the following command:

```
bundle exec rubocop [-a/--autocorrect]
```

**Note:** the `-a` or `--autocorrect` option is optional, and will write
changes to your files, correcting all offenses it safely can. There is also a
more forceful `-A` or `--autocorrect-all` option, which will write changes and
correct both safe and unsafe offenses.

#### HTML/ERB Files

**Note:** where the formatter and linter disagree, the linter has the final
say.

#### Formatting

You can run the formatter `htmlbeautifier` using the following command:

```
bundle exec htmlbeautifier -b 1 **/*.html.erb
```

**Note:** `-b` is for allowing up to one extra blank line (normally used for
visually separating sections and making code readable). Not including this
condenses all HTML at all times, which is not ideal.

**Note:** this will write changes to the given files.

#### Linting

You can run the linter `erb_lint` using the following command:

```
bundle exec erb_lint --lint-all [--autocorrect]
```

**Note:** the `--autocorrect` option is optional, and will write changes to
your files.

---

For any issues, please reach out to the project leads so we can help you!
