#!/usr/bin/env ruby

module Docker
  class Build
    def initialize
      load_env
      check_vars('IDE_GO_IMAGE')
      create_builder
      build
    end

    def load_env
      if File.exist?('.env')
        File.readlines('.env').each do |line|
          next if line.strip.empty? || line.start_with?('#')
          key, value = line.split('=', 2).map(&:strip)
          ENV[key] = value
        end
      else
        puts "Error: .env file not found."
        exit 1
      end
    end

    def check_vars(*var_names)
      var_names.each do |var_name|
        if ENV[var_name].nil? || ENV[var_name].empty?
          puts "#{var_name} is unset. Fix by copying .env.sample to .env"
          exit 1
        end
      end
    end

    def create_builder
      system('docker buildx create --name localbuilder 2>/dev/null || true')
      system('docker buildx use localbuilder')
    end

    def build
      system([
        'docker', 'buildx', 'build',
        '--load',
        "--build-arg IDE_GO_IMAGE=#{ENV['IDE_GO_IMAGE']}",
        "-t #{ENV['IDE_GO_IMAGE']}",
        '.'
      ].join(' '))
    end
  end
end

Docker::Build.new
