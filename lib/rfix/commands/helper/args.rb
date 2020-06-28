option :r, :root, "{{*}} Project root path", default: Dir.pwd, argument: :required
option :b, :"main-branch", "{{*}} Branch to use", default: "master", argument: :required
option :l, :limit, "{{*}} Limit number of files", argument: :optional, transform: method(:Integer)

flag nil, :dry, "{{*}} Run in dry mode"
flag nil, :untracked, "{{*}} Load untracked files"
flag nil, :"clear-cache", "{{*}} Clear Rubocop`s cache"
flag nil, :test, "{{*}} Used in tests" do
  Rfix.test = true
end

def validate!(files:)
  files = files.each.to_a

  files.each do |file|
    unless File.exists?(file)
      say_abort "Passed file {{italic:#{file}}} does not exist"
    end
  end

  files
end

def setup(r_args = [], opts, args, reference:)
  # files    = validate!(files: args)
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

  Rfix.repo = repo = Rfix::Repository.new(
    root_path: opts[:root],
    load_untracked: opts[:untracked],
    load_tracked_since: reference
  )

  if opts[:"clear-cache"]
    RuboCop::ResultCache.cleanup(store, true)
    params[:cache] = "false"
    say "Cleared Rubocop`s cache"
  end

  if block_given?
    yield(repo, [])
  end

  params2, paths = options.parse(r_args)

  params2.merge!(params)

  if config = opts[:config]
    store.options_config = config
  elsif root_path = opts[:root]
    store.for(root_path)
  end

  if paths.empty? && repo.paths.empty?
    say_exit "Everything looks good, nothing to lint"
  elsif paths.empty?
    paths = repo.paths
  end

  if limit = opts[:limit]
    paths = paths.take(limit)
  end

  env = RuboCop::CLI::Environment.new(params2, store, paths)
  exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
end
