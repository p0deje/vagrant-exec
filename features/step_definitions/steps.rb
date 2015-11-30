Then(/^SHH subprocess should execute command "(.+)"$/) do |command|
  subprocess_line = all_output.split("\n").reverse.find do |l|
    l.start_with?(' INFO ssh: Executing SSH in subprocess:')
  end
  if ENV['VAGRANT_EXEC_GUEST'] == 'posix'
    assert_matching_output("bash -l -c '#{command.delete("''")}'", subprocess_line)
  else
    assert_matching_output("cmd /c '#{command.delete("''")}'", subprocess_line)
  end
end

Then(/^the file "(.+)" should contain result of vagrant ssh-config$/) do |file|
  # since "bundle exec" adds some output, we actually
  # assert that file contents are included in stdout
  step 'I run `bundle exec vagrant ssh-config`'
  with_file_content(file) { |content| expect(all_stdout).to include(content) }
end
