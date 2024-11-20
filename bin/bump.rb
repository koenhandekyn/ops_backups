#!/usr/bin/env ruby

# Script to bump the version in lib/ops_backups/version.rb

require 'bundler'

def version_file
  @version_file ||= begin
    gemspec = Bundler.load_gemspec(Dir.glob('*.gemspec').first)
    version_file = gemspec.files.find { |file| file =~ /version\.rb$/ }
    version_file
  end
end

def read_version
  File.foreach(version_file) do |line|
    if line =~ /VERSION\s*=\s*"(\d+)\.(\d+)\.(\d+)"/
      return [$1.to_i, $2.to_i, $3.to_i]
    end
  end
  nil
end

# Write the new version back to the file
def write_version(new_version)
  content = File.read(version_file)
  updated_content = content.gsub(/VERSION\s*=\s*"\d+\.\d+\.\d+"/, "VERSION = \"#{new_version}\"")
  File.open(version_file, 'w') { |file| file.puts updated_content }
end

# Bump the patch version
def bump_version(inc = 1)
  puts "Using version file: #{version_file}"
  version = read_version
  if version.nil?
    puts "Version not found in file."
    return
  end

  major, minor, patch = version
  puts "Current version is #{major}.#{minor}.#{patch}"
  new_patch = patch + inc
  new_version = [major, minor, new_patch].join('.')
  write_version(new_version)
  puts "Version bumped to: \n#{new_version}"
end

$new_version = bump_version(ARGV[0] ? ARGV[0].to_i : 1)
`git add #{version_file}`
# commit just the version file
# `git commit -m "Bump version to #{read_version.join('.')}"`
