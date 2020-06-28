option :r, :root, "{{*}} Project root path", default: Dir.pwd, argument: :required
option :b, :"main-branch", "{{*}} Branch to use", default: "master", argument: :required
option :l, :limit, "{{*}} Limit number of files", argument: :required, transform: method(:Integer)

flag nil, :dry, "{{*}} Run in dry mode"
flag nil, :untracked, "{{*}} Load untracked files"
flag nil, :"clear-cache", "{{*}} Clear Rubocop`s cache"
flag nil, :test, "{{*}} Used in tests" do
  Rfix.test = true
end

def validate!(files:)
  return [] unless files.is_a?(Array)

  files.each do |file|
    unless File.exist?(file)
      say_abort "Passed file {{error:#{file}}} does not exist"
    end
  end

  files
end

def setup(r_args = [], opts, _args, files: [], reference:)
  files    = validate!(files: files)
  options  = RuboCop::Options.new
  store    = RuboCop::ConfigStore.new

  params = {
    force_exclusion: true,
    formatters: ["Rfix::Formatter"],
    auto_correct: !opts[:dry]
  }

  if opts[:cache] == "false"
    params[:cache] = "false"
  end

  begin
    Rfix.repo = repo = Rfix::Repository.new(
      root_path: opts[:root],
      load_untracked: opts[:untracked],
      load_tracked_since: reference,
      paths: files
    )
  rescue Rugged::RepositoryError => e
    say_abort e.to_s
  rescue Rfix::Error => e
    say_abort e.to_s
  end

  if opts[:"clear-cache"]
    RuboCop::ResultCache.cleanup(store, true)
    params[:cache] = "false"
    say "Cleared Rubocop`s cache"
  end

  if block_given?
    yield(repo, [])
  end

  begin
    params2, paths = options.parse(r_args)
  rescue OptionParser::MissingArgument => e
    say_abort e.to_s
  end

  params2.merge!(params)

  begin
    if config = opts[:config]
      store.options_config = config
    elsif root_path = opts[:root]
      store.for(root_path)
    end
  rescue RuboCop::Error => e
    say_abort e.to_s
  rescue TypeError => e
    say_abort e.to_s
  rescue Psych::SyntaxError => e
    say_abort e.to_s
  end

  unless files.empty?
    say "Loading files from {{italic:#{files.join(', ')}}}"
  end

  if !files.empty?
    paths = files
  elsif paths.empty? && repo.paths.empty?
    say_exit "Everything looks good, nothing to lint"
  elsif paths.empty?
    paths = repo.paths
  end

  if limit = opts[:limit]
    paths = paths.take(limit)
  end

  env = RuboCop::CLI::Environment.new(params2, store, paths)

  begin
    exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
  rescue RuboCop::Error => e
    say_abort e.to_s
  end
end
