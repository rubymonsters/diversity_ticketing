[Travis says](https://travis-ci.org/rubymonsters/diversity_ticketing): [![Build Status](https://travis-ci.org/rubymonsters/diversity_ticketing.svg?branch=master)](https://travis-ci.org/rubymonsters/diversity_ticketing)

This is a Ruby on Rails app made by the RubyMonstas (a RailsGirls study group based in Berlin), to make diversifying conferences easier.

Supported by the [Travis Foundation](http://foundation.travis-ci.org/).

## Contributing workflow
If you want to contribute, you can look at the [open issues](https://github.com/rubymonsters/diversity_ticketing/issues). We are happy to answer your questions if you consider to help.

If you have other ideas to enhance the site, or if you've found a bug, feel free to open an [issue](https://github.com/rubymonsters/diversity_ticketing/issues)!

Here’s how we suggest you go about proposing a change to this project:

1. [Fork this project][fork] to your account.
2. [Create a branch][branch] for the change you intend to make.
3. Make your changes to your fork.
4. Test your changes. To run the tests `bundle exec rake`
5. [Send a pull request][pr] from your fork’s branch to our `master` (or `staging`) branch.
  (We created a `staging` branch that contains latest updates in order to keep the `master` branch clean and up to date with production. The `staging` branch can then be merged to `master` for deployment. Therefore, ideally your pull request merges to staging first.)
    - For bonus points, include screenshots in the description.

Using the web-based interface to make changes is fine too, and will help you
by automatically forking the project and prompting to send a pull request.

[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository
[pr]: https://help.github.com/articles/using-pull-requests/

## Build setup
This following text describes how to set up your workstation to develop for [diversity tickets](https://diversitytickets.org).

1. Check that you have the correct ruby version:
  1. open a new Terminal window
  1. `ruby --version  # --> ruby 2.4.3`
1. Install bundler by running `gem install bundler`
1. Run `bundle install` to install the dependencies specified in your Gemfile
1. Postgresql setup
  1. for OS X:
    1. in your terminal, run:
      1. `createuser -s pguser`
      1. `psql postgres`
      1. postgresql console is now opened.
        1. Enter `\password pguser`
        1. Enter the password `pguser_password` (twice)
    1. when done, quit the postgresql console with `\q`
  1. for Ubuntu:
    1. in your terminal, run:
      1. `sudo -u postgres createuser -s pguser`
      1. `sudo -u postgres psql`
      1. postgresql console is now opened.
        1. Enter `\password pguser`
        1. Enter the password `pguser_password` (twice)
    1. when done, quit the postgresql console with `\q`
1. Update the config/database.yml
  1. add this to the default group: <br>
        host: localhost <br>
        username: pguser <br>
        password: pguser_password <br>
  1. Change the names of the databases to: <br>
        diversity_ticketing_development <br>
        diversity_ticketing_test <br>
        diversity_ticketing_production <br>
1. Run `rake db:create` to create the database.

## Translate the app
If you want to contribute to Diversity Tickets by translating the app into your language, [here are some indications on how to proceed](https://github.com/rubymonsters/diversity_ticketing/wiki/Do-you-want-to-translate-Diversity-Tickets-to-your-own-language%3F-Here-are-some-indications:)

## License
[MIT](https://github.com/rubymonsters/diversity_ticketing/blob/master/LICENSE.md).
