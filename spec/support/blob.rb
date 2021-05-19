# frozen_string_literal: true

require "rfix/types"
require "dry/struct"

class Blob < Dry::Struct
  attribute :path, Rfix::Types::Path::Absolute
  attribute :name, Rfix::Types::Path::Relative

  delegate :to_s, to: :name
  alias inspect to_s

  def self.new(*)
    super.setup
  end

  def absolute_path
    path.join(name)
  end

  def setup
    tap { init; touch }
  end

  def add(file)
    new(name: file).setup
  end

  def delete
    tap { file_path.delete }
  end

  def stage
    write.tap { git.add(name) }
  end

  def status
    tap { puts git.status.pretty }
  end

  def commit
    stage.tap do
      git.commit("commit #{name}")
    end
  end
  alias track commit

  def ignore
    tap { path.join(".gitignore").write(name, mode: "a") }
  end

  def repo
    @repo ||= Rugged::Repository.new(path)
  end

  def write(to: -1)
    lines = file_path.read.lines
    line = to

    lines.fill(lines.count...line) do |index|
      lines[index] ||= "\n"
    end.then do |result|
      result.insert(line, "# comment")
    end.then do |lines|
      tap { file_path.write(lines.join, mode: "a") }
    end
  end

  def file_path
    path.join(name)
  end

  def touch
    tap { file_path.write(EMPTY_STRING) }
  end

  def git
    @git ||= Git.init(path.to_s).tap do |git|
      git.chdir do
        system "git", "config", "user.name", "Linus Oleander"
        system "git", "config", "user.email", "linus@oleander.nu"
      end
    end
  end
  alias init git
end
