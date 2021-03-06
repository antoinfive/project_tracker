class Account < ActiveRecord::Base
  has_many :projects
  def self.find_or_create_from_github(auth_hash)
    self.where(auth_hash.slice("provider", "uid")).first_or_initialize.tap do |u|
      u.name = auth_hash.dig("info", "name")
      u.image = auth_hash.dig("info", "image")
      u.github_username = auth_hash.dig("extra", "raw_info", "login")
      u.token = auth_hash.dig("credentials", "token")
      u.save
    end
  end

  def find_repo(repo_name)
    client.repo(repo_name)
  rescue Octokit::NotFound
    nil
  end

  def client
    @client ||= Octokit::Client.new(:access_token => self.token)
  end
end
