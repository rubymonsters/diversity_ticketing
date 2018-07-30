[Travis says](https://travis-ci.org/rubymonsters/diversity_ticketing): [![Build Status](https://travis-ci.org/rubymonsters/diversity_ticketing.svg?branch=master)](https://travis-ci.org/rubymonsters/diversity_ticketing)

This is a Ruby on Rails app made by RubyMonstas (a RailsGirls study group based in Berlin), to make diversifying conferences easier.

Supported by the [Travis Foundation](http://foundation.travis-ci.org/).

## Contribution Workflow
If you want to contribute, you can look at the [open issues](https://github.com/rubymonsters/diversity_ticketing/issues). We'll behappy to answer your questions if you consider to help.

If you have other ideas to enhance the site or have found a bug, feel free to open an [issue](https://github.com/rubymonsters/diversity_ticketing/issues)!

Here’s how we suggest you go about proposing a change to this project:

1. [Fork this project][fork] to your account.
2. [Create a branch][branch] for the change you intend to make.
3. Make your changes to your fork.
4. Test your changes by running `bundle exec rake`.
5. [Send a pull request][pr] from your fork’s branch to our `master` branch.
    - For bonus points, include screenshots in the description.

Using the web-based interface to make changes is fine too, and will help you
by automatically forking the project and prompting to send a pull request.

[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository
[pr]: https://help.github.com/articles/using-pull-requests/

# Build Setup
This following text describes how to set up your workstation to develop for [diversity tickets](https://diversitytickets.org).

1. Check that you have the correct version of Ruby by running `ruby --version` in your terminal. You should expect to see `ruby 2.4.3`. If you have another version please install our specified version with `rvm` or `rbenv` or whatever your preferred version of installing Rubies.

1. Next, install bundler by running `gem install bundler` if you haven't already done so.

1. Run `bundle install` to install the dependencies specified in the Gemfile.


## PostgreSQL Setup
### macOS 

Run the following in order in your terminal:
    1. `createuser -s pguser`
    2. `psql postgres` to open the PostgreSQL terminal then
    3. Enter `pguser_password` (twice).
    4. When done, quit the PostgreSQL console with `\q`.

### Ubuntu

Run the following in order in your terminal:
    1. `sudo -u postgres createuser -s pguser`
    2. `sudo -u postgres psql` to open the PostgreSQL terminal then
    3. Enter `\password pguser`
    4. Enter the password `pguser_password` (twice).
    5. When done, quit the postgresql console with `\q`


Finally, run `rails db:create db:migrate` to set up the database, followed by `rails s` to have the project running in your browswer at `0.0.0.0.:3000`.
