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

force       = ENV['FORCE'] == 'true'
lib_dir     = File.expand_path("../lib", __FILE__)
helpers_dir = File.expand_path("../helpers", __FILE__)

sources = {}
helpers = []

Dir.glob("#{helpers_dir}/*/**/*").each do |source|
  next if File.directory?(source)
  (sources[File.dirname(source)] ||= []) << source
end

sources.each_pair do |dir, sources|
  name = dir[(helpers_dir.length + 1)..-1]
  target = File.join(lib_dir, "#{name}.rb")
  
  if force && File.exists?(target)
    FileUtils.rm(target)
  end
  
  file target => sources + [dir] do
    sh "bundle exec linecook helper '#{name}' --force"
  end
  
  helpers << target
end

desc "generate helpers"
task :helpers => [:bundle] + helpers

#
# Linecook Packages
#

packages_dir = File.expand_path("../packages", __FILE__)
packages     = Dir.glob("#{packages_dir}/*.yml")
dependencies = Dir.glob('{attributes,files,recipes,templates}/**/*')

packages.each do |source|
  target = source.chomp('.yml')
  name   = File.basename(target)
  
  namespace :packages do
    file target => dependencies + [source] + helpers do
      sh "bundle exec linecook package '#{source}' '#{target}' --force"
    end
    
    desc "generate the package: #{name}"
    task name => [:bundle, target]
  end
  
  task :packages => "packages:#{name}"
end

desc "generate packages"
task :packages

#
# VM Tasks
#

namespace :vm do
  task :setup => :bundle do
    sh 'bundle exec linecook reset'
    sh 'bundle exec linecook share vbox'
  end
  
  task :teardown => :bundle do
    sh 'bundle exec linecook stop'
  end
end

#
# Test tasks
#

desc 'Default: Run tests.'
task :default => :test

desc 'Run the tests assuming the vm is running'
task :quicktest => [:helpers] do
  tests = Dir.glob('test/**/*_test.rb')
  
  if ENV['RCOV'] == 'true'
    FileUtils.rm_rf File.expand_path('../coverage', __FILE__)
    sh('rcov', '-w', '--text-report', '--exclude', '^/', *tests)
  else
    sh('ruby', '-w', '-e', 'ARGV.dup.each {|test| load test}', *tests)
  end
end

desc 'Run the tests'
task :test do
  begin
    Rake::Task["vm:setup"].invoke
    Rake::Task["quicktest"].invoke
  ensure
    Rake::Task["vm:teardown"].execute(nil)
  end
end

desc 'Run rcov'
task :rcov do
  ENV['RCOV'] = 'true'
  Rake::Task["test"].invoke
end
