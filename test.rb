require "date"
require "fileutils"
require "find"

class Post
  attr_reader :date, :title, :content
  
  def initialize(date, title, content)
    @date = Date.parse(date)
    @title = title || date
    @content = content
  end

  def write_to_dir(dir)
    File.write(
      File.join(dir, "#{date}-day.md"),
      <<-EOS
---
layout: post
title: #{title}
permalink: "#{date.strftime('%Y%m%d')}"
---
#{content.chomp}
      EOS
    )
  end
end

def main
  FileUtils.mkdir_p("_posts")

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
    post.write_to_dir("_posts")
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
