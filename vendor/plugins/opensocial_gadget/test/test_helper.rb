ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures"
def create_fixtures(*table_names)
  Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures", table_names)
end

OpenSocialGadget::Config.load File.join(File.dirname(__FILE__), 'gadget.yml')

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def consumer_key
    '999999999999'
  end
  def requestor_id
    '00000000000000000000'
  end
  def view_type
    'home'
  end
  def get_person
    OpenSocial::Person.new({
      "id" => "example.org:34KJDCSKJN2HHF0DW20394",
      "displayName" => "Janey",
      "name" => {"unstructured" => "Jane Doe"},
      "gender" => "female"
    })
  end
  def get_people
    person = get_person
    {person.id => person}
  end
  
  def get_group
    OpenSocial::Group.new({
      "id" => "example.org:34KJDCSKJN2HHF0DW20394/friends",
      "title" => "Peeps"
    })
  end
  def get_groups
    group = get_group
    {group.id => group}
  end

  def get_activity
    OpenSocial::Activity.new({
      "id" => "http://example.org/activities/example.org:87ead8dead6beef/self/af3778",
      "title" => "<a href=\"foo\">some activity</a>",
      "updated" => Time.now,
      "body" => "Some details for some activity",
      "bodyId" => "383777272",
      "url" => "http://api.example.org/activity/feeds/.../af3778",
      "userId" => "example.org:34KJDCSKJN2HHF0DW20394"
    })
  end
  def get_activities
    activity = get_activity
    {activity.id => activity}
  end
  
  def get_appdata
    OpenSocial::AppData.new("example.org:34KJDCSKJN2HHF0DW20394", {
      "id" => "example.org:34KJDCSKJN2HHF0DW20394",
      "pokes" => 3,
      "last_poke" => Time.now
    })
  end
  def get_appdata_list
    appdata = get_appdata
    {appdata.id => appdata}
  end

end
