#!/usr/bin/ruby
#コメントアップデート監視
#cronで定期実行することを想定
require "rubygems"
require 'json'
require 'libtwitter'
require 'kconv'
$KCODE='UTF-8'

STDOUT.sync = true

class Twitcommunity

	def initialize
		@path = "/hoge/hoge/"  #作業ディレクトリの指定
		@listuser = "katoyuu1" #チェック対象リストの管理ユーザ名
		@listname = "seiyu"    #チェック対象リスト名
		@mytwitter = MyTwitter.new(@path)
		@conversation = Conversation.new(@path)
	end

	def start
		@mytwitter.setListName(@listuser,@listname)
		list = @mytwitter.getList
		count=0
		list.each do |status|
			rep = status.text.scan(/@([0-9a-zA-Z_]{1,15})/) #@username をピックアップ
			if rep != []
				rep.each{|r|
					if(@mytwitter.findName(r.to_s)==true)
						@conversation.add(status.user.screen_name.to_s,r.to_s)
						count+=1
					else
					end
				}
				
			end
		end
		puts "add "+count.to_s+" data"
		@conversation.saveVar
		
	end
	
	def checkmembers
		@mytwitter.getListMember(@listuser,@listname)
	end
	
end

t = Twitcommunity.new
if(ARGV[0]=="checkmembers")
	puts "start check members"
	t.checkmembers
else
	puts "start check comment update"
	t.start
end

