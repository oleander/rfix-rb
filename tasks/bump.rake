# frozen_string_literal: true

namespace :gem do
  task :inc do
    sh "gem", "bump", "-c", "-m", "'Bump version to %{version}'"
  end

  task :amend do
    sh "git commit --amend --no-edit"
  end

  task bump: [:inc, Bundle::INSTALL, Bundle::ADD, :amend]
end
