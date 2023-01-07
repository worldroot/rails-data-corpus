# Rails Template
A rapid Rails 6 application template for personal use. This particular template utilizes [Tailwind CSS](https://tailwindcss.com/), a utility-first CSS framework for rapid UI development.

Tailwind depends on Webpack so this also comes bundled with [webpacker](https://github.com/rails/webpacker) support.

Inspired heavily by [Rails Kickoff - Tailwind](https://github.com/justalever/kickoff_tailwind) from [Andy Leverenz](https://github.com/justalever). Credits to him for most of the heavy lifting here.

### Included gems

- [devise](https://github.com/plataformatec/devise)
- [friendly_id](https://github.com/norman/friendly_id)
- [sidekiq](https://github.com/mperham/sidekiq)
- [name_of_person](https://github.com/basecamp/name_of_person)
- [local_time](https://github.com/basecamp/local_time)
- [simple_form](https://github.com/heartcombo/simple_form)
- [mini_magick](https://github.com/minimagick/minimagick)
- [stripe](https://github.com/stripe/stripe-ruby)
- [figaro](https://github.com/laserlemon/figaro)

### Tailwind CSS by default
With Rails 6 we have webpacker by default now. Using PostCSS we can install Tailwind as a base CSS framework to harness. I prefer Tailwind due to it's un-opinionated approach.

## How it works

When creating a new rails app simply pass the template file through.

### Creating a new app

```bash
$ rails new app_name -d <postgresql, mysql, sqlite3> -m template.rb
```

### Once installed what do I get?

- Webpack support + Tailwind CSS configured in the `app/javascript` directory.
- Devise with a new `name` field already migrated in. The name field maps to the `first_name` and `last_name` fields in the database thanks to the `name_of_person` gem.
- Devise User already has Stripe fields and JavaScript file (charges.js).
- Support for Friendly IDs thanks to the handy [friendly_id](https://github.com/norman/friendly_id) gem. Note that you'll still need to do some work inside your models for this to work. This template installs the gem and runs the associated generator.
- Optional Foreman support thanks to a `Procfile`. Once you scaffold the template, run `foreman start` to initalize and head to `locahost:5000` to get `rails server`, `sidekiq` and `bin/webpack-dev-server` running all in one terminal instance. Note: Webpack will still compile down with just `rails server` if you don't want to use Foreman. Foreman needs to be installed as a global gem on your system for this to work. i.e. `gem install foreman`
- Git initialization out of the box
- PurgeCSS configuration to help with CSS file sizes 
- Custom defaults for button and form elements

### Boot it up

`$ rails server`

### Boot it up (with foreman)
Run `foreman start`. Head to `locahost:5000` to see your app. You'll have hot reloading on `js` and `css` and `scss/sass` files by default. Feel free to configure to look for more to compile reload as your app scales.