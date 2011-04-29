require 'rubygems'
require 'sinatra'
require 'haml'
require 'open-uri'
require 'nokogiri'
 
get '/' do
  erb :"layout.html"
end

post '/' do
  url =  params[:link][0..6] == "http://" ? params[:link] : "http://" + params[:link] 
  if page = Nokogiri::HTML(open(url))
    @json_nodes = generate_json_nodes page.xpath('//body').first
  end
  erb :"layout.html"
end

 private

  def node_id(node)
    return "=>body---" if node.name == "body"
    id  = node_id(node.parent) + "=>" + node.name
    id += "#" + node[:id] if node[:id] 
    id += "#" + node[:class] if node[:class] 
    id + "---"
  end
  
  def generate_json_nodes(parent_node)
    js = '{id:\"' + node_id(parent_node) + '\", name:\"' + node_id(parent_node).split('---').last[2..-1]  + '\", data:{}, children:['
    parent_node.children.each do |child_node|
      next unless child_node[:id] or child_node[:class]
      js += generate_json_nodes(child_node) + ","
    end
    js + "]}"
  end
   

