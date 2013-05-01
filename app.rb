require 'rubygems'
require 'sinatra'
require 'haml'
require 'tropo-webapi-ruby'
require 'net/http'

set :public_folder, 'public'
tropoToken = ""
#phone numbers to send messages from
fromArray = ['9999999999','9999999999', '9999999999']
fromLen = fromArray.length;

# use scss style sheet
get '/style.css' do
  scss :style
end

get '/' do
    haml :app
end

post '/vote.json' do	
	inputPhoneNumber = formatNumber(params[:inputPhoneNumber])
	inputText = params[:inputText].gsub(/\s+/, "+")
	inputLimit = params[:inputLimit].to_i

	#cycle through available phone numbers
	for j in 0...fromLen
		#make an http GET request to TROPO
		for i in 0...inputLimit
			result = sendTextMessage(fromArray[j], inputText, inputPhoneNumber, tropoToken)
			#wait between requests
			sleep(5)
		end
	end

	@inputLimit = inputLimit

	haml :vote
end

#script for tropo to run
post '/sendSMS.json' do
	v = Tropo::Generator.parse request.env["rack.input"].read
	
   	#get values from url
  	to = v[:session][:parameters][:input_phone_number]
  	msg = v[:session][:parameters][:input_text]
  	fromNum = v[:session][:parameters][:from]

	t = Tropo::Generator.new
    
	t.call(:from => fromNum, :to => to, :network => "SMS")
	t.say(:value => msg)
	 
	t.response
end

#call the tropo API to send the message
def sendTextMessage(fromNum, inputText, inputPhoneNumber, tropoToken)
	result = Net::HTTP.get(URI.parse('http://api.tropo.com/1.0/sessions?action=create&token='+tropoToken+'&inputPhoneNumber='+inputPhoneNumber+'&inputText='+inputText+'&from='+fromNum+''))
	return result
end

#format phone number from javascript response
def formatNumber(number)
	number = number.gsub("(","")
	number = number.gsub(")", "")
	number = number.gsub(/\s+/, "")
	return number
end

