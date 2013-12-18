vagrant-exec [![Gem Version](https://badge.fury.io/rb/vagrant-exec.png)](http://badge.fury.io/rb/vagrant-exec)
===============

Vagrant plugin to execute commands within the context of VM synced directory.

Description
-----------

You will probably use the plugin if you don't want to SSH into the box to execute commands simply because your machine environment is already configured (e.g. I use ZSH and TextMate bundles to run specs/features).

Example
-------

```bash
➜ vagrant exec pwd
/vagrant
```

Installation
------------

```bash
➜ vagrant plugin install vagrant-exec
```

Configuration
-------------

### Custom root

The root directory can be configured using Vagrantfile.

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'
  config.exec.root = '/custom'
end
```

```bash
➜ vagrant exec pwd
# is the same as
➜ vagrant ssh -c "cd /custom && bundle exec pwd"
```

### Prepend with

You can tell `vagrant-exec` to prepend all the commands with custom string.

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'
  config.exec.prepend_with 'bundle exec'
end
```

```bash
➜ vagrant exec pwd
# is the same as
➜ vagrant ssh -c "cd /vagrant && bundle exec pwd"
```

You can also limit prepend to specific commands and combine them.

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'
  config.exec.prepend_with 'bundle exec', :only => %w(rails rspec cucumber)
  config.exec.prepend_with 'rvmsudo', :only => %w(gem)
end
```

```bash
➜ vagrant exec rails c
# is the same as
➜ vagrant ssh -c "cd /vagrant && bundle exec rails c"
```

```bash
➜ vagrant exec gem install bundler
# is the same as
➜ vagrant ssh -c "cd /vagrant && rvmsudo gem install bundler"
```

### Environment variables

You can add environment variables to be exported before.

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'
  config.exec.env['RAILS_ENV'] = 'test'
  config.exec.env['RAILS_ROOT'] = '/vagrant'
end
```

```bash
➜ vagrant exec pwd
# is the same as
➜ vagrant ssh -c "cd /vagrant && export RAILS_ENV=test && export RAILS_ROOT=/vagrant && pwd"
```

Acceptance tests
----------------

Before running features, you'll need to bootstrap box.

```bash
➜ bundle exec rake features:bootstrap
```

To run features, execute the following rake task.

```bash
➜ bundle exec rake features:run
```

After you're done, remove Vagrant box.

```bash
➜ bundle exec rake features:cleanup
```

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2013-2013 Alex Rodionov. See LICENSE.md for details.
