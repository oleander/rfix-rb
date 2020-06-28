namespace :bundle do
  task :install do
    gemfiles.each do |gemfile|
      next if gemfile.end_with?(".lock")
      sh "bundle install", "--gemfile", gemfile
    end
  end

  namespace :git do
    task :add do
      gemfiles.each do |gemfile|
        sh "git add", gemfile
      end
    end
  end
end
