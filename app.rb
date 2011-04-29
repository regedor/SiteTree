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
    @json_nodes   = generate_json_nodes page
  end
  erb :"layout.html"
end

private

  def node_id(node)
    return "body---" if node.name == "body"
    id  = node_id(node.parent) + "=>" + node.name
    id += "#" + node[:id] if node[:id] 
    id += "." + node[:class] if node[:class] 
    id + "---"
  end
  
  def generate_json_node(parent_node)
    js = '{id:\"' + ($json_node_id+=1).to_s + '\", name:\"' + node_id(parent_node).split('---').last[2..-1]  + '\", data:{}, children:['
    parent_node.children.each do |child_node|
      next unless !$json_node_ids.member?(node_id(child_node)) && (child_node[:id] or child_node[:class])
      $json_node_ids << node_id(child_node)
      js += generate_json_node(child_node) + ","
    end
    js + "]}"
  end

  def generate_json_nodes(page) 
    $json_node_id  = 0
    $json_node_ids = []
    generate_json_node page.xpath('//body').first
  end
