require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'

#
# Gem tasks
#

def gemspec
  @gemspec ||= begin
    gemspec_path = File.expand_path('../linebook.gemspec', __FILE__)
    eval(File.read(gemspec_path), TOPLEVEL_BINDING)
  end
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end

desc 'Prints the gemspec manifest.'
task :print_manifest do
  files = gemspec.files.inject({}) do |files, file|
    files[File.expand_path(file)] = [File.exists?(file), file]
    files
  end
  
  cookbook_files = Dir.glob('{attributes,files,lib,recipes,templates}/**/*')
  cookbook_file  = Dir.glob('*')
  
  (cookbook_files + cookbook_file).each do |file|
    next unless File.file?(file)
    path = File.expand_path(file)
    files[path] = ['', file] unless files.has_key?(path)
  end
  
  # sort and output the results
  files.values.sort_by {|exists, file| file }.each do |entry| 
    puts '%-5s %s' % entry
  end
end

#
# Documentation tasks
#

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  spec = gemspec
  
  rdoc.rdoc_dir = 'rdoc'
  rdoc.options.concat(spec.rdoc_options)
  rdoc.rdoc_files.include(spec.extra_rdoc_files)
  
  files = spec.files.select {|file| file =~ /^lib.*\.rb$/}
  rdoc.rdoc_files.include( files )
end

#
# Dependency tasks
#

desc 'Bundle dependencies'
task :bundle do
  output = `bundle check 2>&1`
  
  unless $?.to_i == 0
    puts output
    sh "bundle install 2>&1"
    puts
  end
end

#
# Linecook Helpers
#

package = ENV['package']
force = (ENV['FORCE'] == 'true')

desc "build helpers and packages"
task :build => :bundle do
  sh "bundle exec linecook build #{force ? '--force ' : nil}#{package}"
end

desc "run packages"
task :run => :build do
  sh "bundle exec linecook run #{package}"
end

desc "start each vm at CURRENT"
task :start => :bundle do
  sh 'bundle exec linecook start --socket --snapshot CURRENT'
end

desc "snapshot each vm to a new CURRENT"
task :snapshot => :bundle do
  sh 'bundle exec linecook snapshot CURRENT'
end

desc "reset each vm to BASE"
task :reset => :bundle do
  sh 'bundle exec linecook snapshot --reset BASE'
  sh 'bundle exec linecook snapshot CURRENT'
  sh 'bundle exec linecook start --socket --snapshot CURRENT'
end

desc "stop each vm"
task :stop => :bundle do
  sh 'bundle exec linecook stop'
end

#
# Test tasks
#

desc 'Default: Run tests.'
task :default => :test

desc 'Run the tests assuming each vm is setup'
task :quicktest => :build do
  tests = Dir.glob('test/**/*_test.rb')
  tests.delete_if {|test| test =~ /_test\/test_/ }
  
  if ENV['RCOV'] == 'true'
    FileUtils.rm_rf File.expand_path('../coverage', __FILE__)
    sh('rcov', '-w', '--text-report', '--exclude', '^/', *tests)
  else
    sh('ruby', '-w', '-e', 'ARGV.dup.each {|test| load test}', *tests)
  end
end

desc 'Run the tests vs each vm in config/ssh'
task :multitest do
  require 'thread'
  
  hosts = `bundle exec linecook state --hosts`.split("\n")
  hosts.collect! {|line| line.split(':').at(0) }
  
  log_dir = File.expand_path('../log', __FILE__)
  unless File.exists?(log_dir)
    FileUtils.mkdir_p(log_dir)
  end
  
  threads = hosts.collect do |host|
    Thread.new do
      logfile = File.join(log_dir, host)
      Thread.current["host"] = host
      Thread.current["logfile"] = logfile
      
      cmd = "LINECOOK_TEST_HOST=#{host} rake quicktest > '#{logfile}' 2>&1"
      puts  "Multitest Host: #{host}"
      system(cmd)
      
      stdout  = File.read(logfile).split("\n")
      time    = stdout.grep(/^Finished in/)
      results = stdout.grep(/^\d+ tests/)
      puts "Using Host: #{host}\n  #{time}\n  #{results}"
    end
  end
  
  threads.each do |thread|
    thread.join
  end
end

desc 'Run the tests'
task :test do
  begin
    Rake::Task["start"].invoke
    Rake::Task["multitest"].invoke
  ensure
    Rake::Task["stop"].execute(nil)
  end
end

desc 'Run rcov'
task :rcov do
  ENV['RCOV'] = 'true'
  Rake::Task["test"].invoke
end
