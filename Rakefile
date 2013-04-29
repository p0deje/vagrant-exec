require 'bundler'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

namespace :features do
  desc 'Adds vagrant box for testing.'
  task(:bootstrap) do
    # download and add box for acceptance tests
    system("bundle exec vagrant box add precise32 http://files.vagrantup.com/precise32.box")
  end

  Cucumber::Rake::Task.new(:run) do |t|
    t.cucumber_opts = %w(--format pretty)
  end
end
