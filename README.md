# Rails Starter Template

This repository contains a starter [template](https://guides.rubyonrails.org/rails_application_templates.html) for Ruby on Rails apps.

**Attention: This is currently a work in progress!**

**Open todo's**

- [x] **make it possible to use this template remotely from GitHub**
- [ ] ~~Default language to German (might require i18n gem and more work such as modifying and copying translations for default Rails content)~~ 
- [x] refactor everything into a src/ folder

## Requirements

- **Rails >= 7**. Older versions may work with at least some configurations of this template, but not guaranteed.
- **Node.js** installed on your local machine (this is only used for formatting via Prettier)
- **TailwindCSS** for styling. Configure this easily by using the flag `--css=tailwind` when creating your Rails app with this template

## What does this template do?

### 👮 Linting and security tools

### 💎 Code formatting via Prettier

We want our Rails app to use consistent formatting for `.rb` files. This is achieved with the [Ruby plugin for Prettier](https://github.com/prettier/plugin-ruby).

### 📈 Test coverage configuration

- SimpleCov
- Run with COVERAGE=true

### 👀 Component setup

- View Component
- Lookbook

### 👥 User management

- Devise
- letter_opener for email in development
- two roles: user (default) and admin

### 🕓 Set app's timezone to Berlin (optional)

You will be asked if you want to set the timezone to Berlin. Answer according to your requirements.

## Usage

Generate a new Rails app with this template by running:

```bash
rails new your-app-name [...] -m https://raw.githubusercontent.com/dnsos/rails-starter/main/template.rb
```

> Note that this template can currently only be used for _new_ Rails apps. It can not be applied to existing ones.

## After using this template

1. Create and migrate your database with `bin/rails db:create && bin/rails db:migrate`
2. It's possible that the initial Rubocop run was not able to fix all issues. Check if you need manual adjustments by running `bundle exec rubocop`.

### Other things you may want to configure

- RenovateBot
- .github/CODEOWNERS
- GitHub Actions CI (should actually be optional addition!)
- Content Security Policy
- SMTP in production
- Devise :confirmable if desired (https://github.com/heartcombo/devise/wiki/How-To%3A-Add-%3Aconfirmable-to-Users)
