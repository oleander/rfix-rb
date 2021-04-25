# frozen_string_literal: true

require "rake/clean"
require "tmpdir"
require "pathname"

root_path = Pathname.new(Dir.mktmpdir)
libgit2_gz_path = root_path.join("v1.0.1.tar.gz")
libgit2_path = root_path.join("libgit2-1.0.1")

CLEAN.include(root_path)

namespace :libgit2 do
  task build: libgit2_path do
    chdir(libgit2_path) do
      sh "cmake ."
      sh "make"
    end
  end

  task install: :build do
    chdir(libgit2_path) do
      sh "make install"
    end
  end

  file libgit2_gz_path do
    sh "wget -O #{libgit2_gz_path} https://github.com/libgit2/libgit2/archive/v1.0.1.tar.gz"
  end

  file libgit2_path => libgit2_gz_path do
    sh "tar xzf #{libgit2_gz_path} -C #{root_path}"
  end
end
