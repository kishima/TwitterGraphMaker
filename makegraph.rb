#!/usr/bin/ruby
#cronで定期実行
require "rubygems"
require 'json'
require "graphviz"
require 'libtwitter'
require 'httpclient'

$KCODE='UTF-8'

STDOUT.sync = true

class Makegraph
	def initialize
		@path = "/hoge/hoge/" #作業ディレクトリの指定
		@listuser = "katoyuu1" #チェック対象リストの管理ユーザ名
		@listname = "seiyu"    #チェック対象リスト名
		@mytwitter = MyTwitter.new(@path)
		@conversation = Conversation.new(@path)
		@data = {}
	end

	def start
		@mytwitter.setListName(@listuser,@listname)
		@data = @conversation.getData
		drow
	end
	
	def findUser(list,name)
		list.each{|n|
			return true if(n==name)
		}
		return false
	end

	def getUsers
		list=[]
		@data.each{|c|
		  #puts c["from"] + "/" +c["to"]
			if(findUser(list,c["from"])==false)
				list.push(c["from"])
			end
			if(findUser(list,c["to"])==false)
				list.push(c["to"])
			end
		}
		return list
	end
	
	def drow
		users = getUsers
		
		# initialize
		g = GraphViz::new( "G", :label => "Seiyu Graph  (powered by http://twitter.com/katoyuu1/seiyu)  ", :output => "png" )

		# グラフ, ノード, エッジの属性の初期化
		g.node[:shape] = "ellipse"
		g.node[:color] = "black"
		g.node[:fontsize] = "16"

		g.edge[:color] = "black"
		g.edge[:weight] = "1"
		g.edge[:style] = "filled"
		g.edge[:label] = ""

		g[:size] = "70,130"

		# サブグラフを 2 つ作る
		g1 = g.add_graph( "g1" )
		
		nodes={}
		users.each{|name|
				fullname = @mytwitter.getScreen2Name(name)
				nodes[name] = g1.add_node( fullname )
		}

		@data.each{|c|
			
			if c["count"]+1 > 2 #2つ以上の会話があれば強調する
				g1.add_edge( nodes[c["from"]], nodes[c["to"]],:label =>(c["count"]+1).to_s ,:style=>"bold" , :color=>"red")
			else
				g1.add_edge( nodes[c["from"]], nodes[c["to"]],:label =>(c["count"]+1).to_s)
			end
		}

		# GraphViz::new で png を指定したので PNG で output
		g.output( )
	end
	
end

t = Makegraph.new
t.start




