# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::PullRequest do
  let(:pull_request) do
    described_class.new('user_name', 'user_email', options)
  end

  let(:options) do
    {
      labels: labels,
      dry_run: dry_run,
      project_column_name: project_column_name,
      project_id: project_id
    }
  end
  let(:labels) { ['label-1', 'label-2'] }
  let(:dry_run) { false }
  let(:project_column_name) { 'Column 1' }
  let(:project_id) { 123_456_789 }
  let(:pr_comet) { instance_double(PrComet, commit: nil, create!: nil) }

  before do
    allow(PrComet).to receive(:new).and_return(pr_comet)
    allow(pull_request).to receive(:timestamp).and_return('20181112212509')
  end

  describe '#commit!' do
    subject(:commit!) { pull_request.commit!('description') }

    it do
      commit!
      expect(pr_comet).to have_received(:commit).with('description')
    end
  end

  describe '#create_rubocop_challenge_pr!' do
    subject(:create_pull_request!) do
      pull_request.create_rubocop_challenge_pr!(rule, 'template_file_path')
    end

    let(:rule) do
      instance_double(RubocopChallenger::Rubocop::Rule, title: 'title')
    end
    let(:pr_template) do
      instance_double(RubocopChallenger::Github::PrTemplate, generate: 'body')
    end

    before do
      allow(RubocopChallenger::Github::PrTemplate)
        .to receive(:new).and_return(pr_template)
    end

    context 'when dry_run is true' do
      let(:dry_run) { true }

      it do
        create_pull_request!
        expect(RubocopChallenger::Github::PrTemplate)
          .to have_received(:new).with(rule, 'template_file_path')
      end

      it do
        create_pull_request!
        expect(pr_comet).not_to have_received(:create!)
      end
    end

    context 'when dry_run is false' do
      let(:expected_options) do
        {
          title: 'title-20181112212509',
          body: 'body',
          labels: labels,
          project_column_name: project_column_name,
          project_id: project_id
        }
      end

      it do
        create_pull_request!
        expect(RubocopChallenger::Github::PrTemplate)
          .to have_received(:new).with(rule, 'template_file_path')
      end

      it do
        create_pull_request!
        expect(pr_comet).to have_received(:create!).with(expected_options)
      end
    end
  end

  describe '#create_regenerate_todo_pr!' do
    subject(:create_pull_request!) do
      pull_request.create_regenerate_todo_pr!('0.64.0', '0.65.0')
    end

    context 'when dry_run is true' do
      let(:dry_run) { true }

      it do
        create_pull_request!
        expect(pr_comet).not_to have_received(:create!)
      end
    end

    context 'when dry_run is false' do
      let(:expected_options) do
        {
          title: 'Re-generate .rubocop_todo.yml with RuboCop v0.65.0',
          body: expected_pr_body,
          labels: labels,
          project_column_name: project_column_name,
          project_id: project_id
        }
      end

      let(:expected_pr_body) { <<~MARKDOWN }
        Re-generated the .rubocop_todo.yml because it was generated by old version RuboCop.

        * Using RuboCop version: [`0.64.0...0.65.0`](https://github.com/rubocop-hq/rubocop/compare/v0.64.0...v0.65.0)
        * [Release Note](https://github.com/rubocop-hq/rubocop/releases/tag/v0.65.0)

        Auto generated by [rubocop_challenger](https://github.com/ryz310/rubocop_challenger)
      MARKDOWN

      it do
        create_pull_request!
        expect(pr_comet).to have_received(:create!).with(expected_options)
      end
    end
  end
end
