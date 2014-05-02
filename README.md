vagrant-exec [![Gem Version](https://badge.fury.io/rb/vagrant-exec.png)](http://badge.fury.io/rb/vagrant-exec)
===============

Vagrant plugin to execute commands within the context of VM synced directory.

Description
-----------

You will probably use the plugin if you don't want to SSH into the box to execute commands simply because your machine environment is already configured (e.g. I use ZSH and TextMate bundles to run specs/features).

Installation
------------

```bash
➜ vagrant plugin install vagrant-exec
```

Example
-------

```bash
➜ vagrant exec pwd
/vagrant
```

Configuration
-------------

vagrant-exec has only one configuration option for Vagrantfile, which allows you to alter the behavior of all or specific commands.

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'
  config.exec.commands '*', directory: '/tmp'
end
```

Commands can either be:

  * `"*"` (wildcard) - apply options to all the commands
  * `"command"` (string) - apply options for specific commands
  * `%w(command1 command2)` (array) - apply options to all commands in array

Configuration options are merged, so if you specify single command in several places, all the option will be applied. The only exception is `:directory`, which is applied only once and in reverse order (i.e. the last set is used).

### Directory

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'

  # Make /tmp working directory for all the commands:
  #   ➜ vagrant exec pwd
  #   # is the same as
  #   ➜ vagrant ssh -c "cd /tmp && pwd"
  config.exec.commands '*', directory: '/tmp'

  # Make /etc working directory for env command:
  #   ➜ vagrant exec env
  #   # is the same as
  #   ➜ vagrant ssh -c "cd /etc && env"
  config.exec.commands 'env', directory: '/etc'
end
```

### Prepend

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'

  # Automatically prepend apt-get command with sudo:
  #   ➜ vagrant exec apt-get install htop
  #   # is the same as
  #   ➜ vagrant ssh -c "cd /vagrant && sudo apt-get install htop"
  config.exec.commands 'apt-get', prepend: 'sudo'

  # Automatically prepend rails and rspec commands with bundle exec:
  #   ➜ vagrant exec rails c
  #   # is the same as
  #   ➜ vagrant ssh -c "cd /vagrant && bundle exec rails c"
  #
  #   ➜ vagrant exec rspec spec/
  #   # is the same as
  #   ➜ vagrant ssh -c "cd /vagrant && bundle exec rspec spec/"
  config.exec.commands %w(rails rspec), prepend: 'bundle exec'
end
```

### Environment variables

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise32'

  # Automatically export environment variables for ruby command:
  #   ➜ vagrant exec ruby -e 'puts 1'
  #   # is the same as
  #   ➜ vagrant ssh -c "cd /vagrant && export RUBY_GC_MALLOC_LIMIT=100000000 && ruby -e 'puts 1'"
  config.exec.commands 'ruby', env: { 'RUBY_GC_MALLOC_LIMIT' => 100000000 }
end
```

Testing
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

Known issues
-----------------------------

`vagrant-exec` cannot properly handle `-v` in command args (it's caught somewhere before plugin), so executing `vagrant exec ruby -v` will return Vagrant version rather than Ruby. As a workaround, wrap it in quotes: `vagrant exec "ruby -v"`.

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2013-2014 Alex Rodionov. See LICENSE.md for details.
