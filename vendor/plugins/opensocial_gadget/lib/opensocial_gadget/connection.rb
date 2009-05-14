module OpenSocialGadget
  class Connection
    attr_accessor :connection

    def initialize(consumer_key, owner_id)
        key = Config.keys[consumer_key]
        if !key
          raise OpenSocial::AuthException.new('AuthException: unknown consumer_key=' + consumer_key)
        end

        case key['container']
        when "ORKUT"
          container = OpenSocial::Connection::ORKUT
        when "IGOOGLE"
          container = OpenSocial::Connection::IGOOGLE
        when "MYSPACE"
          container = OpenSocial::Connection::MYSPACE
        else
          raise OpenSocial::AuthException.new('AuthException: not supported container :' + key['container'])
        end

        @connection = OpenSocial::Connection.new(:container => container,
                                   :consumer_key => key['outgoing_key'],
                                   :consumer_secret => key['secret'],
                                   :xoauth_requestor_id => owner_id)
    end
    
    def get_appdata(guid = '@me', selector = '@self', aid = '@app')
      OpenSocial::FetchAppDataRequest.new(@connection, guid, selector, aid).send
    end
    
    def get_person(guid = '@me', selector = '@self')
      OpenSocial::FetchPersonRequest.new(@connection, guid, selector).send
    end
    
    def get_people(guid = '@me', selector = '@friends')
      OpenSocial::FetchPeopleRequest.new(@connection, guid, selector).send
    end
    
    def get_groups(guid = '@me')
      OpenSocial::FetchGroupsRequest.new(@connection, guid).send
    end
    
    def get_activities(guid = '@me', selector = '@self', pid = nil)
      OpenSocial::FetchActivitiesRequest.new(@connection, guid, selector, pid).send
    end
  end
end
