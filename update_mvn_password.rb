#!/usr/bin/env ruby

require 'rubygems'
begin
  require 'commander/import'
rescue LoadError => e
  puts "Required commander gem is missing.\n\nRun\n\t[sudo] gem install commander\n\nto install the missing gem\n\n"
  exit 1
end

program :name, 'Maven password updated'
program :version, '1.0.0'
program :description, 'Simple utility to update the mvn password in settings-security and settings.xml'

def replace_token_in_file(replacement, file)
  file = File.expand_path file
  lines = IO.readlines(file)
  File.open(file, 'w') do |f|
    lines.each do |line|
      f << line.gsub(/<password>\{.+?\}<\/password>/) {|s| "<password>#{replacement}</password>" }
    end
  end
end

command :master do |c|
  c.syntax = 'master PASSWORD'
  c.description = 'Update the master password'
  c.action do |args, options|
    pw = password "Enter a new master password please:", '*'
    mvn_pw = `mvn --encrypt-master-password '#{pw}'`.strip
    replace_token_in_file mvn_pw,  "~/.m2/settings-security.xml"
  end
end


command :password do |c|
  c.syntax = 'password PASSWORD'
  c.description = 'Update the user password'
  c.option '--unsecure', 'Don\'t encrypt the password'
  c.action do |args, options|
    pw = password "Enter a new password please:", '*'
    mvn_pw = options.unsecure ? pw : `mvn --encrypt-password '#{pw}'`.strip
    puts "Using mvn password: #{mvn_pw[0..5]}"
    replace_token_in_file mvn_pw,  "~/.m2/settings.xml"
  end
end

