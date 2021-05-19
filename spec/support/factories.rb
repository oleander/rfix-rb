FactoryBot.define do
  skip_create
  initialize_with { new(**attributes) }

  factory :repository, class: Rfix::Repository do
    repository { Rugged::Repository.new(repo_path) }
    reference { Rfix::Branch::Reference.new(name: "master") }
    transient do
      repo_path { raise "Repository path not defined" }
    end
  end
end
