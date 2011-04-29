require 'rubygems'
require 'sinatra'
require 'haml'
require 'open-uri'
require 'nokogiri'
 

def node_id(node)
  return "body---" if node.name == "body"
  id  = node_id(node.parent) + "=>" + node.name
  id += "#" + node[:id] if node[:id] 
  id += "#" + node[:class] if node[:class] 
  id + "---"
end

def generate2(parent_node, level=0)
  h = {}
  h[node_id(parent_node)] = []
  return h unless parent_node[:id] or parent_node[:class]
  parent_node.children.each do |child_node|
    next unless child_node[:id] or child_node[:class]
    h[node_id(parent_node)] << node_id(child_node)
    h.merge! generate(child_node)
  end
  h
end

def generate(parent_node)
  js = '{id:\"' + node_id(parent_node) + '\", name:\"' + node_id(parent_node).split('---').last  + '\", data:{}, children:['
  parent_node.children.each do |child_node|
    next unless child_node[:id] or child_node[:class]
    js += generate(child_node) + ","
  end
  js + "]}"
end

get '/' do
  erb :about 
end

post '/' do
  url = "http://www.nemum.com/" or params[:link]
  page = Nokogiri::HTML(open(url))
  if page
    @ids   = {}
    @nodes = generate page.xpath('//body').first
    #@nodes.keys.each_with_index { | node_key, i | @ids[node_key] = i }
  end
  erb :graph
end

__END__

@@ layout
<html lang='en' xml:lang='en' xmlns='http://www.w3.org/1999/xhtml'>
  <head>
    <title>HTML to Tree Graph</title>
    <meta content='text/html; charset=utf-8' http-equiv='Content-Type' />
    <style type='text/css'>
      body { background-color: #679; color: #222; text-align: left; font-family: arial, sans-serif; font-size: 62.5%; }
      body > p {  text-align:center; }
      h1 { color: #f00; margin-bottom: 1em; font-size: 1.5em; }
      <!-- #wrapper { width: 400px; margin: 50px auto 25px auto; background-color: #fff; border: 1px solid #666; } -->
      <!-- #wrapper { padding: 0 1em; font-size: 1.2em; } -->
    </style>
    <link type="text/css" href="/css/base.css" rel="stylesheet" />
    <link type="text/css" href="/css/Spacetree.css" rel="stylesheet" />
    <script language="javascript" type="text/javascript" src="/js/jit.js"></script>
    <script language="javascript" type="text/javascript" src="/js/example2.js"></script>

  </head>
  <body>
    <div id='wrapper'>
      <h1>HTML to Tree Graph</h1>
      <form action='/' method='POST'>
        <p>
          <input name='link' />
          <input class='submit' type='submit' value='Do the Magic' />
        </p>
      </form>
    </div>
    <div id='content'>
      <%= yield %>
    </div>
    <p>
      <span xmlns:dc="http://purl.org/dc/elements/1.1/" href="http://purl.org/dc/dcmitype/InteractiveResource" property="dc:title" rel="dc:type">Calculadora</span> 
      by <a xmlns:cc="http://creativecommons.org/ns#" href="http://regedor.com/" property="cc:attributionName" rel="cc:attributionURL">Miguel Regedor</a>
      is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.5/pt/">Creative Commons Attribution-Share Alike 2.5 Portugal License</a>.
      <br />Based on a work at <a xmlns:dc="http://purl.org/dc/elements/1.1/" href="http://github.com/regedor/Sinatra--Calculadora" rel="dc:source">github.com</a>.
    </p>
  </body>
</html>

@@ about
Coisas

@@ graph
<div id="center-container">
    <div id="infovis"></div>    
</div>

<div id="right-container">

<h4>Change Tree Orientation</h4>
<table>
    <tr>
        <td>
            <label for="r-left">left </label>
        </td>
        <td>
            <input type="radio" id="r-left" name="orientation" checked="checked" value="left" />
        </td>
    </tr>
    <tr>
         <td>
            <label for="r-top">top </label>
         </td>
         <td>
            <input type="radio" id="r-top" name="orientation" value="top" />
         </td>
    <tr>
         <td>
            <label for="r-bottom">bottom </label>
          </td>
          <td>
            <input type="radio" id="r-bottom" name="orientation" value="bottom" />
          </td>
    </tr>
    <tr>
          <td>
            <label for="r-right">right </label>
          </td> 
          <td> 
           <input type="radio" id="r-right" name="orientation" value="right" />
          </td>
    </tr>
</table>
</div>
<div id="log"></div>
<script>
  window.onload = function() {
 
  var json = "<%= @nodes %>";
  //var json = "{id:\"node02\", name:\"0asdf\", data:{}, children: []}";

    init(json);	  
//
//    <%# @nodes.each do | node_key, children | %>
//      g.addNode("<%# @ids[node_key] %>", { 
//        label : "<%# node_key.split(" | ").last %>",
//      });
//    <%# end %>
//
//
//    <%# @nodes.each do | node_key, children | %>
//      <%# children.each do | child | %>
//        g.addEdge("<%# @ids[node_key] %>", "<%# @ids[child] %>", { directed : true } );
//      <%# end %>
//    <%# end %>
  
  };
</script>
