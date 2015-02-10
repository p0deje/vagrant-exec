require 'bundler'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

namespace :features do
  desc 'Downloads and adds vagrant box for testing.'
  task(:bootstrap) do
    system('bundle exec vagrant box add vagrant_exec http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box')
  end

  Cucumber::Rake::Task.new(:run) do |t|
    t.cucumber_opts = %w[--format pretty]
  end

  desc 'Removes testing vagrant box.'
  task(:cleanup) do
    system('bundle exec vagrant box remove --force vagrant_exec')

    # For some reason, vagrant destroy ID fails for us
    # so let's just stick to pure VirtualBox

    `VBoxManage list vms`
      .split("\n")
      .select { |line| line =~ /aruba_(default|vagrant)/ }
      .map { |line| line.match(/\{([\w-]+)\}/)[1] }
      .each { |uuid| system("VBoxManage unregistervm #{uuid} -delete") }

    system('bundle exec vagrant global-status --prune')
  end
end
