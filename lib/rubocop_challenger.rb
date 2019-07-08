# frozen_string_literal: true

require 'erb'
require 'yard'
require 'rainbow'
require 'pr_comet'
require 'rubocop'
require 'rubocop_challenger/errors'
require 'rubocop_challenger/version'
require 'rubocop_challenger/rubocop/rule'
require 'rubocop_challenger/rubocop/config_editor'
require 'rubocop_challenger/rubocop/todo_reader'
require 'rubocop_challenger/rubocop/todo_writer'
require 'rubocop_challenger/rubocop/command'
require 'rubocop_challenger/rubocop/challenge'
require 'rubocop_challenger/rubocop/yardoc'
require 'rubocop_challenger/pull_request'
require 'rubocop_challenger/go'
require 'rubocop_challenger/cli'
require 'rubocop_challenger/bundler/command'
require 'rubocop_challenger/github/pr_template'

# Loads gems for feature of integrations
%w[rubocop-performance rubocop-rails rubocop-rspec].each do |dependency|
  begin
    require dependency
  rescue LoadError
    nil
  end
end
