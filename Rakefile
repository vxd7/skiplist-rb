# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/test_*.rb']
end

Rake::TestTask.new(:bench) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/benchmark_*.rb']
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test rubocop]
