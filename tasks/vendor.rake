namespace :vendor do
  namespace :shopify do
    directory Vendor::DIR

    desc "Downloads shopify repository"
    task build: [Vendor::REPO, Vendor::TEST]

    desc "Re-download shopify repository"
    task rebuild: [:flush, Vendor::BUILD]

    desc "Remove shopify repository"
    task :flush do
      rm_rf Vendor::REPO
    end

    desc "Test validity of repo"
    task test: Vendor::REPO do
      cd Vendor::REPO do
        sh "git rev-list --count HEAD"
        sh "git status"
      end

      say "Finished testing vendor"
    end

    file Vendor::REPO => Vendor::DIR do
      sh "git clone", Vendor::GITHUB, Vendor::REPO

      cd Vendor::REPO do
        sh "git reset --hard", Vendor::START
      end
    end
  end
end
