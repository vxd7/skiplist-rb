# frozen_string_literal: true

require_relative 'lib/skiplist/version'

Gem::Specification.new do |spec|
  spec.name = 'skiplist'
  spec.version = Skiplist::VERSION
  spec.authors = ['vxd7']
  spec.email = ['vxd732@protonmail.com']

  spec.summary = 'Skiplist data structure in pure Ruby'
  spec.homepage = 'https://github.com/vxd7/skiplist-rb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/vxd7/skiplist-rb'
  # spec.metadata['changelog_uri'] = ''

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .github Gemfile])
    end
  end
  spec.require_paths = ['lib']
end
