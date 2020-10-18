# require "pry"
class Env
  KEY = "__RFIX_LOOP".freeze

  def self.spec
    Gem.loaded_specs.fetch("rfix")
  end

  def self.requirement
    spec.dependencies.select do |gem|
      gem.name == "rubocop"
    end.first&.requirement || Env.log!("RuboCop requirement not found")
  end

  def self.pretty_req
    requirement.as_list.join(" to ")
  end

  def self.bundle_path
    Gem.bin_path("bundler", "bundle")
  end

  def self.first_loop?
    !ENV.key?(Env::KEY)
  end

  def self.first_loop!
    ENV[Env::KEY] ||= path_to
  end

  def self.log(msg)
    # return unless ARGV.include?("--debug")

    $stderr.puts ["==>", msg].join(" ")
  end

  def self.log!(msg)
    $stderr.puts ["==>", msg].join(" ")
    exit(1)
  end
end
