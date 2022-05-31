# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To execute rubocop gem command (Mainly for mock when testing)
    class Command
      include PrComet::CommandLine

      # Executes auto correction
      def autocorrect(only_safe_autocorrect:)
        if only_safe_autocorrect
          run('--autocorrect')
        else
          run('--autocorrect-all')
        end
      end

      # Generates `.rubocop_todo.yml`
      #
      # @param exclude_limit [Integer] default: nil
      # @param auto_gen_timestamp [Boolean] default: true
      # @param offense_counts [Boolean] default: true
      def auto_gen_config(exclude_limit: nil, auto_gen_timestamp: true, offense_counts: true)
        commands = ['--auto-gen-config']
        commands << "--exclude-limit #{exclude_limit}" if exclude_limit
        commands << '--no-auto-gen-timestamp' unless auto_gen_timestamp
        commands << '--no-offense-counts' unless offense_counts
        run(*commands)
      end

      private

      def run(*subcommands)
        command = "bundle exec rubocop #{subcommands.join(' ')} || true"
        execute(command)
      end
    end
  end
end
