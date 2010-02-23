# Some default enhancements/settings for IRB, based on
# http://wiki.rubygarden.org/Ruby/page/show/Irb/TipsAndTricks

# V 0.2

# Require RubyGems by default.
require 'rubygems'

begin
#  require "map_by_method"
#  require "what_methods"
#  require "utility_belt"
rescue => e
  puts "install gem #{e}"
end

# Activate auto-completion.
require 'irb/completion'

# Use the simple prompt if possible.
IRB.conf[:PROMPT_MODE] = :SIMPLE if IRB.conf[:PROMPT_MODE] == :DEFAULT

# Setup permanent history.
HISTFILE = "~/.irb_history"
MAXHISTSIZE = 100
begin
  histfile = File::expand_path(HISTFILE)
  if File::exists?(histfile)
    lines = IO::readlines(histfile).collect { |line| line.chomp }
    puts "Read #{lines.nitems} saved history commands from '#{histfile}'." if $VERBOSE
    Readline::HISTORY.push(*lines)
  else
    puts "History file '#{histfile}' was empty or non-existant." if $VERBOSE
  end
  Kernel::at_exit do
    lines = Readline::HISTORY.to_a.reverse.uniq.reverse
    lines = lines[-MAXHISTSIZE, MAXHISTSIZE] if lines.nitems > MAXHISTSIZE
    puts "Saving #{lines.length} history lines to '#{histfile}'." if $VERBOSE
    File::open(histfile, File::WRONLY|File::CREAT|File::TRUNC) { |io| io.puts lines.join("\n") }
  end
end

