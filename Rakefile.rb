require "rubygems"
require "bundler/setup"
require "stringex"

## -- Config -- ##

public_dir = "public"    # compiled site directory
posts_dir = "_posts"    # directory for blog files
drafts_dir = "_drafts"
new_post_ext = "md"  # default new post file extension when using the new_post task
new_page_ext = "md"  # default new page file extension when using the new_page task

#############################
# Create a new Post or Page #
#############################

# usage rake new_post
desc "Create a new post in #{posts_dir}"
task :new_post, :title do |t, args|
  title = args.title || ""
  link = "/#{Time.now.strftime("%Y-%m-%d")}-#{title.to_url}"
  filename = "#{drafts_dir}/#{Time.now.strftime("%Y-%m-%d")}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("#{filename} already exists.")
  end
  open(filename, "w") do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/, "&amp;")}\""
    post.puts "modified: #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}"
    post.puts "tags: []"
    post.puts "url:  #{link}"
    post.puts "image: #feature? thumbnail?"
    post.puts "  credit: Charles Hoffman"
    post.puts "  creditlink: "
    post.puts "comments: true"
    post.puts "share: true"
    post.puts "---"
  end
  puts filename
end

# usage rake new_page
desc "Create a new page"
task :new_page, :title do |t, args|
  title = args.title || ""
  filename = "#{title.to_url}.#{new_page_ext}"
  if File.exist?(filename)
    abort("#{filename} already exists.")
  end
  open(filename, "w") do |page|
    page.puts "---"
    page.puts "layout: page"
    page.puts "title: \"#{title}\""
    page.puts "modified: #{Time.now.strftime("%Y-%m-%d %H:%M")}"
    page.puts "tags: []"
    page.puts "image:"
    page.puts "  credit: Charles Hoffman"
    page.puts "  creditlink: "
    page.puts "share: true"
    page.puts "---"
  end
  puts filename
end
