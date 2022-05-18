# Rails Starter Template

This repository contains a starter [template](https://guides.rubyonrails.org/rails_application_templates.html) for Ruby on Rails apps.

**Attention: This is currently a work in progress!**

## Requirements

- **Node.js** installed on your local machine: This is only used for formatting via Prettier.
- **TailwindCSS** for styling. Configure this easily by using the flag `--css=tailwind` when creating your Rails app with this template

## To add

- [x] Bundler Audit and Brakeman for security
- [x] Prettier ruby-plugin
- [x] Rubocop + rubocop.yml
- [x] `letter_opener` for emails in development
- [x] SimpleCov for test coverage
- [x] Time zone to Berlin
- [x] ViewComponent and Lookbook
- [x] Devise (with user and admin roles)
- [ ] Default language to German (might require i18n gem and more work such as modifying and copying translations for default Rails content)
- [ ] refactor everything into a src/ folder

## Usage

...

## What does this template do?

### Code quality and security tools 👮

### Code formatting via Prettier 💎

We want our Rails app to use consistent formatting for Ruby files. This is achieved with the [Ruby plugin for Prettier](https://github.com/prettier/plugin-ruby)

### Test coverage configuration 📈

- SimpleCov
- Run with COVERAGE=true

### Component setup 👀

- View Component
- Lookbook

### User management 👥

- Devise
- letter_opener for email in development
- two roles: user (default) and admin

### Set app's timezone to Berlin (optional) 🕓

You will be asked if you want to set the timezone to Berlin. Answer according to your requirements.

## A couple more things you might wanna do

- RenovateBot
- .github/CODEOWNERS
- GitHub Actions CI (should actually be optional addition!)
- Content Security Policy
- Rubocop manual fixes
- Create DB and migrate
- SMTP in production
- Devise :confirmable if desired (https://github.com/heartcombo/devise/wiki/How-To%3A-Add-%3Aconfirmable-to-Users)
