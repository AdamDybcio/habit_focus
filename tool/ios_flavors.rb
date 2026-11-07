#!/usr/bin/env ruby
# frozen_string_literal: true

# Adds the dev, staging and prod flavors to the iOS project.
#
# For every flavor it creates the build configurations Debug-<flavor>,
# Release-<flavor> and Profile-<flavor> (copies of Debug, Release and Profile),
# a shared scheme named like the flavor, a bundle ID with the flavor suffix and
# a display name. It also maps the new configurations in ios/Podfile.
#
# Safe to run again: whatever exists already is left alone.
#
# Usage, from the repository root:
#   fvm flutter build ios --config-only --no-codesign   # creates ios/Podfile
#   ruby tool/ios_flavors.rb
#   cd ios && pod install
#
# Needs the `xcodeproj` gem, which comes with CocoaPods. See docs/flavors.md.

require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT, 'ios', 'Runner.xcodeproj')
SCHEMES_DIR = File.join(PROJECT_PATH, 'xcshareddata', 'xcschemes')
PODFILE_PATH = File.join(ROOT, 'ios', 'Podfile')

# Build configuration prefix => type of settings it starts from.
MODES = { 'Debug' => :debug, 'Release' => :release, 'Profile' => :release }.freeze

# Suffix is appended to the bundle ID of the prod app.
FLAVORS = {
  'dev' => { suffix: '.dev', name: 'Habit Focus DEV' },
  'staging' => { suffix: '.staging', name: 'Habit Focus STG' },
  'prod' => { suffix: '', name: 'Habit Focus' }
}.freeze

DEFAULT_NAME = 'Habit Focus'

def configuration(list, name)
  list.build_configurations.find { |config| config.name == name }
end

def add_configurations(project)
  lists = [project.build_configuration_list] + project.targets.map(&:build_configuration_list)

  FLAVORS.each_key do |flavor|
    MODES.each do |mode, type|
      name = "#{mode}-#{flavor}"
      next if configuration(project.build_configuration_list, name)

      project.add_build_configuration(name, type)
      project.targets.each { |target| target.add_build_configuration(name, type) }

      lists.each do |list|
        base = configuration(list, mode)
        copy = configuration(list, name)
        copy.build_settings = Marshal.load(Marshal.dump(base.build_settings))
        copy.base_configuration_reference = base.base_configuration_reference
      end
      puts "  + configuration #{name}"
    end
  end
end

def apply_flavor_settings(runner)
  base_id = configuration(runner.build_configuration_list, 'Release').build_settings['PRODUCT_BUNDLE_IDENTIFIER']
  abort 'Release configuration has no PRODUCT_BUNDLE_IDENTIFIER' if base_id.nil? || base_id.empty?

  runner.build_configurations.each do |config|
    flavor = FLAVORS.keys.find { |key| config.name.end_with?("-#{key}") }
    settings = flavor ? FLAVORS[flavor] : { suffix: '', name: DEFAULT_NAME }
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{base_id}#{settings[:suffix]}"
    config.build_settings['APP_DISPLAY_NAME'] = settings[:name]
  end
end

def write_schemes
  template_path = File.join(SCHEMES_DIR, 'Runner.xcscheme')
  abort "Missing #{template_path}" unless File.exist?(template_path)
  template = File.read(template_path)

  FLAVORS.each_key do |flavor|
    path = File.join(SCHEMES_DIR, "#{flavor}.xcscheme")
    next if File.exist?(path)

    scheme = template.gsub(/buildConfiguration = "(Debug|Release|Profile)"/) do
      "buildConfiguration = \"#{Regexp.last_match(1)}-#{flavor}\""
    end
    File.write(path, scheme)
    puts "  + scheme #{flavor}"
  end
end

def patch_podfile
  unless File.exist?(PODFILE_PATH)
    puts '  ! ios/Podfile not found. Run `fvm flutter build ios --config-only --no-codesign`'
    puts '    and this script again, otherwise pods cannot map the new configurations.'
    return
  end

  content = File.read(PODFILE_PATH)
  return if content.include?("'Debug-dev'")

  entries = ['Debug', 'Profile', 'Release'].flat_map do |mode|
    ([nil] + FLAVORS.keys).map do |flavor|
      name = flavor ? "#{mode}-#{flavor}" : mode
      "  '#{name}' => :#{mode == 'Debug' ? 'debug' : 'release'}"
    end
  end
  mapping = "project 'Runner', {\n#{entries.join(",\n")},\n}\n\n"

  anchor = /^def flutter_root/
  abort 'ios/Podfile has no `def flutter_root`, add the mapping by hand (docs/flavors.md).' unless content.match?(anchor)

  File.write(PODFILE_PATH, content.sub(anchor) { "#{mapping}def flutter_root" })
  puts '  + configuration mapping in ios/Podfile'
end

abort "Missing #{PROJECT_PATH}" unless File.directory?(PROJECT_PATH)

project = Xcodeproj::Project.open(PROJECT_PATH)
runner = project.targets.find { |target| target.name == 'Runner' }
abort 'Target Runner not found' if runner.nil?

puts 'iOS flavors:'
add_configurations(project)
apply_flavor_settings(runner)
project.save
write_schemes
patch_podfile
puts 'Done. Next: cd ios && pod install, then flutter run --flavor dev ...'
