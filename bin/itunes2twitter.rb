#!/usr/bin/ruby

require 'rubygems'
require 'osx/cocoa'
require 'twitter'

include OSX
OSX.require_framework 'ScriptingBridge'
STDOUT.sync = true

class ITunes2Twitter
  def initialize()
    @iTunes = OSX::SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")
    @config = ConfigStore.new("#{ENV['HOME']}/.twitter")
  end

  def main_loop()
    old_song = { :artist => "", :name => "" }
    loop do
      track = @iTunes.currentTrack()
      if ( old_song[:artist] != track.artist && old_song[:name] != track.name )
        httpauth = Twitter::HTTPAuth.new( @config['username'], @config['password'] )
        twitter = Twitter::Base.new(httpauth)
        twitter.update "Now listening to #{track.name} - #{track.artist}"
        old_song = { :artist => track.artist, :name => track.name }
      end
      sleep(60 * 20)
    end
  end
end

class ConfigStore
  attr_reader :file
  def initialize(file)
    @file = file
  end
  def load
    @config ||= YAML::load(open(file))
    self
  end
  def [](key)
    load
    @config[key]
  end
  def []=(key, value)
    @config[key] = value
  end
  def delete(*keys)
    keys.each { |key| @config.delete(key) }
    save
    self
  end
  def update(c={})
    @config.merge!(c)
    save
    self
  end
  def save
    File.open(file, 'w') { |f| f.write(YAML.dump(@config)) }
    self
  end
end

i2t = ITunes2Twitter.new()
i2t.main_loop()
