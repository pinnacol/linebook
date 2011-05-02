files = ARGV

if files.empty?
  files = Dir.glob File.expand_path('../*.txt', __FILE__)
end

sets  = files.collect {|file| File.read(file).split("\n").delete_if {|line| line[0] == '#' } }
counts = Hash.new(0)

sets.flatten.each do |str|
  counts[str.strip] += 1
end

counts.each_pair do |key, value|
  puts key if value > 1
end

# = Ruby - Posix
# break *
# case *
# do *
# else *
# eval
# exec
# exit
# for *
# if *
# in *
# return *
# then *
# trap
# until *
# while *

# = Ruby - Unix
# FALSE *
# TRUE *
# alias *
# break *
# eval
# exec
# exit
# printf
# return *
# sleep
# test
# trap

# = Ruby - Linux
# (none)
