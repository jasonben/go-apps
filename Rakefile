# Rakefile
require_relative 'build.rb'

task :build_ide_image do
  Docker::Build.new
end

task default: :build_ide_image
