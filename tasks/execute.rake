# frozen_string_literal: true

require "rake/clean"
require "tmpdir"
require "pathname"

repo_path = Pathname.new(Dir.mktmpdir)

CLEAN.include(repo_path)

namespace :execute do
  task local: [repo_path, :install] do
    chdir(repo_path) do
      sh "rfix local --main-branch master"
    end
  end

  task branch: [repo_path, :install] do
    chdir(repo_path) do
      sh "rfix branch master"
    end
  end

  task origin: [repo_path, :install] do
    chdir(repo_path) do
      sh "rfix origin --main-branch master"
    end
  end

  task lint: [repo_path, :install] do
    chdir(repo_path) do
      sh "rfix lint --main-branch master"
    end
  end

  file repo_path => :rebuild do
    sh "git clone spec/fixtures/complex.bundle #{repo_path} --branch master"
    sh "git  --work-tree=#{repo_path} branch --set-upstream-to origin/master"
  end
end
