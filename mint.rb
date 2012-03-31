require 'rubygems'
require 'rest-client'
require 'json'
# require 'active_support/all'

module Mint

  class Base
    
    @@username = nil
    @@password = nil
    @@cookies = nil

    def self.username; @@username; end
    def self.password; @@password; end
    
    def self.username=(u)
      @@username = u
    end

    def self.password=(p)
      @@password = p
    end

    protected

      def self.cookies; @@cookies; end

      def self.cookies=(c)
        @@cookies = c
      end
  end

  class API

    def self.get(path,options)
      url = "https://wwws.mint.com/#{path}?#{options.to_query.gsub('%2F','/')}"
      response = Mint::Request.execute :method => :get,
        :url      => url,
        :headers  => { :cookies => Mint::Base.send(:cookies) }
      JSON.parse(response)
    end

    def self.budgets(start_date,end_date)
      @budgets ||= get 'getBudget.xevent', { :'startDate' => start_date, :'endDate' => end_date }
    end

    def self.categories
      @categories ||= get( 'app/getJsonData.xevent', { :task => 'categories' } )['set'].first['data']
    end

    def self.category_name(category_id)
      categories.each do |c|
        return c['value'] if c['id'] == category_id
        c['children'].each do |s|
          return "#{c['value']} / #{s['value']}" if s['id'] == category_id
        end
      end
      raise "Unable to find category with id: #{category_id}"
    end

    def self.connect!
      raise 'Username or password not specified' unless Mint::Base.username && Mint::Base.password
      begin
        Mint::Request.execute :method => :post, 
          :url      => 'https://wwws.mint.com/loginUserSubmit.xevent?task=L', 
          :payload  => { :username => Mint::Base.username, :password => Mint::Base.password },
          :headers  => { 'User-Agent' => 'Mozilla/5.0' }
        raise 'Unexpected 200 OK response received; expecting 302 Found'
      rescue RestClient::Found => e
        Mint::Base.send :cookies=, e.response.cookies
        return true
      end
    end

    protected

      # def self.start_of_month
      #   Date.civil(Date.today.year, Date.today.month, 1)
      # end

      # def self.end_of_month
      #   Date.civil(Date.today.year, Date.today.month, -1)
      # end

  end

  class Request < RestClient::Request
  end

end