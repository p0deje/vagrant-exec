require 'bundler'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

namespace :features do
  desc 'Downloads and adds vagrant box for testing.'
  task(:bootstrap) do
    system('bundle exec vagrant box add vagrant_exec http://files.vagrantup.com/precise32.box')
  end

  Cucumber::Rake::Task.new(:run) do |t|
    t.cucumber_opts = %w(--format pretty)
  end

  desc 'Removes testing vagrant box .'
  task(:cleanup) do
    system('bundle exec vagrant destroy -f')
    system('bundle exec vagrant box remove vagrant_exec virtualbox')
  end
end
