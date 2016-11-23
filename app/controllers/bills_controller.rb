class BillsController < ApplicationController
  respond_to :json

  require 'nokogiri'
  require 'open-uri'
  require 'date'

  LEGISCAN_API_KEY = Pusher.key

  def search
  end 

  def results
    @response = HTTParty.get('https://api.legiscan.com/?key=' + LEGISCAN_API_KEY + '&op=getMasterList&state=' + params[:state])
    @results = JSON.parse(@response.body)["masterlist"]
    @bills = @results.reject! {|k,v| k["session"]}

    @hash = {}
    @bills.values.each do |bill|
      # Create new hash that uses bill's status's as keys
      @hash[bill["status"]] =  bill["status"]

      # Compare hash keys and create an array in @hash
      if @hash[bill["status"]] == bill["status"]
        @hash[bill["status"]] = []
      end 
    end

    # Compare hash keys
    @hash.each do |k, v|    
      # Compare bills values
      @bills.values.each do |bill|
        # Check and see if the hash's key is the same as the value of the bill status
        if k == bill["status"]
          @hash[k].push bill["last_action"]
        end 
      end
    end

    @hash.each do |k,v|
      @hash[k]
      freq = @hash[k].inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    end
  end 


  def show
    @bill_api = JSON.parse(HTTParty.get('https://api.legiscan.com/?key=' + LEGISCAN_API_KEY + '&op=getBill&id=' + params[:id]).body)

    @bill_api.each do |bill_info| 
      next if bill_info[1]["bill_id"].blank? 
      if bill_info[1]["votes"].length > 0
        bill_info[1]["votes"].each do |rc|
        @roll_call_id = rc["roll_call_id"].to_s
        end 
      end 
    end

    if @roll_call_id != nil
      @roll_call = JSON.parse(HTTParty.get('https://api.legiscan.com/?key=' + LEGISCAN_API_KEY + '&op=getRollCall&id=' + @roll_call_id).body)
    end 

    @yea = []
    @nay = []
  end 
end
