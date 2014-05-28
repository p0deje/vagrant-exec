Then(/^SHH subprocess should execute command "(.+)"$/) do |command|
  ssh  = %w(vagrant@127.0.0.1 -p 2200 -o Compression=yes)
  ssh += %w(-o DSAAuthentication=yes -o LogLevel=FATAL)
  ssh += %w(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)
  ssh += %W(-o IdentitiesOnly=yes -i #{Dir.home}/.vagrant.d/insecure_private_key)
  ssh += ['-q', '-t', "bash -l -c '#{command.delete("''")}'"]
  assert_partial_output("Executing SSH in subprocess: #{ssh}", all_output)
end

Then(/^the file "(.+)" should contain result of vagrant ssh-config$/) do |file|
  # since "bundle exec" adds some output, we actually
  # assert that file contents are included in stdout
  step 'I run `bundle exec vagrant ssh-config`'
  with_file_content(file) { |content| expect(all_stdout).to include(content) }
end
