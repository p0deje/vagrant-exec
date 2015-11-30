require 'bundler'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

namespace :features do
  Cucumber::Rake::Task.new(:posix) do |t|
    ENV['VAGRANT_EXEC_GUEST'] = 'posix'
    t.cucumber_opts = %w[--format pretty --tags ~@windows]
  end

  Cucumber::Rake::Task.new(:windows) do |t|
    ENV['VAGRANT_EXEC_GUEST'] = 'windows'
    t.cucumber_opts = %w[--format pretty --tags ~@posix]
  end

  desc 'Removes testing vagrant boxes.'
  task :cleanup do
    system('cd tmp/aruba && bundle exec vagrant destroy --force')
    system('bundle exec vagrant box remove --force hashicorp/precise64')
    system('bundle exec vagrant box remove --force ferventcoder/win7pro-x64-nocm-lite')
    system('bundle exec vagrant global-status --prune')
  end
end
