require 'agent_orange/platform'
require 'agent_orange/operating_system'
require 'agent_orange/engine'
require 'agent_orange/version'

module AgentOrange
  class Device < Base
    attr_accessor :type, :name, :version
    attr_accessor :platform
    attr_accessor :operating_system
    attr_accessor :engine
    
    DEVICES = {
      :computer => 'windows|macintosh|x11|linux',
      :mobile => 'ipod|ipad|iphone|palm|android|opera mini|hiptop|windows ce|smartphone|mobile|treo|psp',
      :bot => 'bot'
    }
    
    def parse(user_agent)
      AgentOrange.debug "DEVICE PARSING", 2
      
      groups = parse_user_agent_string_into_groups(user_agent)
      groups.each_with_index do |content,i|
        if content[:name] =~ /(#{DEVICES.collect{|cat,regex| regex}.join(')|(')})/i
          # Matched group against name
          self.populate(content)
        elsif content[:comment] =~ /(#{DEVICES.collect{|cat,regex| regex}.join(')|(')})/i
          # Matched group against comment
          chosen_content = { :name => nil, :version => nil }
          additional_groups = parse_comment(content[:comment])
          additional_groups.each do |additional_content|
            if additional_content[:name] =~ /(#{DEVICES.collect{|cat,regex| regex}.join(')|(')})/i
              chosen_content = additional_content
            end
          end
            
          self.populate(chosen_content)
        end
      end
      
      self.analysis
      
      self.platform = AgentOrange::Platform.new(user_agent)
      self.operating_system = AgentOrange::OperatingSystem.new(user_agent)
      self.engine = AgentOrange::Engine.new(user_agent)
    end
    
    def populate(content={})
      self.debug_raw_content(content)
      AgentOrange.debug "", 2
      
      self.type = self.determine_type(DEVICES, content[:name])
      self.name = self.type.to_s.capitalize
      self.version = nil
      self
    end
    
    def analysis
      AgentOrange.debug "DEVICE ANALYSIS", 2
      self.debug_content(:type => self.type, :name => self.name, :version => self.version)
      AgentOrange.debug "", 2
    end
    
    def is_computer?(name=nil)
      if name
        case name
        when String
          return self.platform.name.downcase.include?(name.downcase)
        when Symbol
          return self.platform.name.downcase.include?(name.to_s.downcase)
        end
      else
        (self.type == "computer")
      end
    end
    
    def is_mobile?(name=nil)
      if name
        case name
        when String
          return self.platform.name.downcase.include?(name.downcase)
        when Symbol
          return self.platform.name.downcase.include?(name.to_s.downcase)
        end
      else
        self.type == "mobile"
      end
    end
    
    def is_bot?(name=nil)
      if name
        case name
        when String
          return self.name.downcase.include?(name.downcase)
        when Symbol
          return self.name.downcase.include?(name.to_s.downcase)
        end
      else
        self.type == "bot"
      end
    end
    
    def to_s
      [self.name, self.version].compact.join(' ')
    end
  end
end