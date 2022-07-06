
require "find"

class Post
  attr_reader :date, :title, :content
  
  def initialize(date, title, content)
    @date = date # TODO: Dateにパース
    @title = title  # TODO: nilだったらdateに変更
    @content= content
  end
end

def main
  files = search_files

  posts = []
  files.each do |path|
    posts += parse_posts(path)
  end    

  # TODO: _postsに書き込み
  # File.write(
  #   "_posts/2022-07-05-day.md",
  #   "---\nlayout: post\ntitle: 2022/07/06\npermalink: \"20220706\"\n---\ntest\n"
  #   )
  posts.each do |post|
    puts "---\n# #{post.title} #{post.date}\n#{post.content}"
  end
end

def search_files
  files = []

  Find.find('_days') do |path|
    files << path unless File.directory?(path)
  end

  files
end

def parse_posts(path)
  text = File.read(path)

  posts = []
  title = date = content = nil
  
  text.split("\n").each do |line|
    if line =~ /# ([\d\/-]+)(?: (.*))?/
      if title
        posts << Post.new(title, date, content.join("\n"))
      end
      
      title, date, content = $1, $2, []
    else
      content << line
    end
  end
  
  if title
    posts << Post.new(title, date, content.join("\n"))
  end
end

main
