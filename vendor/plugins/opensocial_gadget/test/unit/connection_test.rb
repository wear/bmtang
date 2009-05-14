require File.dirname(__FILE__) + '/../test_helper'

class ConnectionTest < Test::Unit::TestCase

  def setup
    @conn = OpenSocialGadget::Connection.new consumer_key, requestor_id
  end
  
  def test_connection
    assert_kind_of OpenSocial::Connection, @conn.connection
  end
  
  def test_get_appdata
    appdata = get_appdata
    OpenSocial::FetchAppDataRequest.any_instance.expects(:send).returns(appdata)
    assert_equal appdata, @conn.get_appdata
  end

  def test_get_person
    person = get_person
    OpenSocial::FetchPersonRequest.any_instance.expects(:send).returns(person)
    assert_equal person, @conn.get_person
  end

  def test_get_people
    people = get_people
    OpenSocial::FetchPeopleRequest.any_instance.expects(:send).returns(people)
    assert_equal people, @conn.get_people
  end

  def test_get_groups
    groups = get_groups
    OpenSocial::FetchGroupsRequest.any_instance.expects(:send).returns(groups)
    assert_equal groups, @conn.get_groups
  end

  def test_get_activities
    activities = get_activities
    OpenSocial::FetchActivitiesRequest.any_instance.expects(:send).returns(activities)
    assert_equal activities, @conn.get_activities
  end

end
