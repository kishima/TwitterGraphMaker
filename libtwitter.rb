# -*- coding: utf-8 -*-
#twitter制御を行う
require "rubygems"
require 'json'
require 'uri'
require "rubytter"
require 'parsedate'

class Conversation
	def initialize(path)
		@path = path
		loadVar
	end
	
	def find(from,to)
		@data["users"].each{|c|
			if c["from"]==from && c["to"]==to
				return c
			end
		}
		return nil
	end

	def add(from,to)
		c=find(from,to)
		if c != nil
			#puts"add count"
			c["count"] += 1
		else
			#puts"add new"
			c={}
			c["from"]=from
			c["to"]=to
			c["count"]=0
			@data["users"].push(c)
		end
	end

	def loadVar
		begin
			d=""
			File.open(@path+"conversation.dat", "r"){|file|
				d = file.read
			}
			@data = JSON.parse(d)
		rescue
			@data={"users"=>[]}
		end
	end
		
	def saveVar
		puts "save Data"
		File.open(@path+"conversation.dat", "w"){|file|
			file.write(JSON.generate(@data))
		}
	end
	
	def getData
		return @data["users"]
	end	
	
end


class MyTwitter
	
	def initialize(path)
		@path = path
		
		mCONSUMER_KEY = "hoge"
		mCONSUMER_SECRET = "hoge"

		if(mCONSUMER_KEY == "hoge")
			abort "You have to set OAuth Keys!"
		end

		consumer = OAuth::Consumer.new(
			mCONSUMER_KEY,
  		mCONSUMER_SECRET,
  		:site => 'http://api.twitter.com'
  	)

		mACCESS_TOKEN = "hoge"
		mACCESS_SECRET = "hoge"
		token = OAuth::AccessToken.new(
  		consumer,
  		mACCESS_TOKEN,
  		mACCESS_SECRET
  	)
		@rubytter = OAuthRubytter.new(token)
	end

private
	def replace_uri(s)
		str = s.dup
		URI.extract(s, %w[http https ftp]) do |uri|
			str.gsub!(uri, %Q{<a href="#{uri}">#{uri}</a>}) #"
		end
		str.gsub!(/@([a-zA-Z_0-9]+)/,"@<a href=\"./#{MyURL}?act=v_ft&name="+'\1'+"\">"+'\1'+"</a>")
		str
	end

	def getPrevLoadId
		id = "0"
		begin
		File.open(@path+"lastid.dat", "r"){|file|
			id = file.gets
			id.chomp!
		}
		rescue
			puts "No Last ID File"
		end
		puts "last id="+id.to_s
		return id
	end

	def savePrevLoadId(id)
		puts "save id="+id.to_s
		File.open(@path+"lastid.dat", "w"){|file|
			file.puts id
		}
	end
	
	def loadMemberList
		json=""
		File.open(@path+"listusers.dat", "r"){|file|
			json=file.read
		}
		@memberlist = JSON.parse(json)['users']
#		p @memberlist
	end
	
	
public

	def setListName(user,name)
		@listeditor = user
		@listname = name
		loadMemberList
	end
	
	def findName(name)
		@memberlist.each{|user|
			if user['screen_name']==name
				return true
			end
		}
		return false
	end

	def getList
		puts @listeditor + " / "+@listname
		prev_num = getPrevLoadId
		if prev_num == "0"
			list = @rubytter.list_statuses(@listeditor,@listname,:per_page=>200)
		else
			list = @rubytter.list_statuses(@listeditor,@listname,:since_id=>prev_num,:per_page=>200)
		end
		if(list != []) #更新アリ
			savePrevLoadId(list[0].id)
		end
		return list
	end

  #リストに含まれるユーザ情報をキャッシュする
	def getListMember(user,name)
		@listeditor = user
		@listname = name
		next_coursor = "-1"
		json={}
		json['users']=[]
		while next_coursor != "0"
			printf "-"
			list = @rubytter.list_members(@listeditor,@listname,:cursor=>next_coursor)
			next_coursor = list.next_cursor_str
			list.users.each{|user|
				u={}
				u["id"]=user.id
				u["screen_name"]=user.screen_name
				u["name"]=user.name
				u["icon"]=user.profile_image_url
				json['users'].push(u) 
			}
		end

		File.open(@path+"listusers.dat", "w"){|file|
			file.write(JSON.generate(json))
		}
		#p JSON.generate(json)
		puts "\nchecking list users done"
	end

	def getScreen2Name(name)
		@memberlist.each{|user|
			if user['screen_name']==name
				return user['name']
			end
		}
		return nil
	end

end

