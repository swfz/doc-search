#!/usr/bin/env ruby

require 'active_record'
require 'front_matter_parser'

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  charset: 'utf8mb4',
  encoding: 'utf8mb4',
  collation: 'utf8mb4_bin',
  host: '127.0.0.1',
  username: 'root',
  password: '',
  database: 'doc-search'
)

class Doc < ActiveRecord::Base
  self.table_name = 'docs'
end

# p Doc.all

def seed
  # Doc.create(
  #   url: 'sample.md',
  #   title: 'hoge',
  #   media: 'local',
  #   content: 'どんぶらこほげfuga'
  # )
  # insert_memo
  # insert_til
end

# til
def insert_til
  yaml_loader = FrontMatterParser::Loader::Yaml.new(whitelist_classes: [Time, Date])

  files = Dir.glob('/home/vagrant/til/content/blog/entries/**/*.md')
  files.each do |filename|
    article = FrontMatterParser::Parser.parse_file(filename, loader: yaml_loader)

    url = filename.gsub('/home/vagrant/til/content/blog', 'https://til.swfz.io').gsub('/index.md','').gsub('.md', '')
    p url
    if Doc.find_by(url: article['url']).nil?
      p '---------- ---------- ----------'
      p url
      p article.content
      Doc.create(url: url, title: article.front_matter['title'], media: 'til', content: article.content)
    end
  end
end

## memo
def insert_memo
  json = JSON.parse(File.read('/home/vagrant/memo/custom/data.json'))
  released = json.reject { |row| row['updated'].blank? || row['platform'] != 'blog' }

  released.each do |article|
    filename = "/home/vagrant/memo/docs/#{article['path']}.md"
    text = File.read filename
    title = article['title']
    if Doc.find_by(url: article['url']).nil?
      p '---------- ---------- ----------'
      p article['url']
      p text
      Doc.create(url: article['url'], title: article['title'], media: 'hatenablog', content: text)
    end
  end
end

def main
  seed
end

main
