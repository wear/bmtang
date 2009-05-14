require File.dirname(__FILE__) + '/../test_helper'

class ConfigTest < Test::Unit::TestCase
  def setup
  end
  
  def test_config
    assert_equal 'title test', OpenSocialGadget::Config.prefs['title']
    assert_equal 'description test', OpenSocialGadget::Config.prefs['description']
    assert_equal 'Arai, Motoki', OpenSocialGadget::Config.prefs['author']
    assert_equal 'araimotoki+test@gmail.com', OpenSocialGadget::Config.prefs['author_email']
    assert_equal 'Japan', OpenSocialGadget::Config.prefs['author_location']
    
    assert_equal 'ORKUT', OpenSocialGadget::Config.keys[consumer_key]['container']
    assert_equal 'xxxxxxxxxxxxxxxxxxxxxxxx', OpenSocialGadget::Config.keys[consumer_key]['secret']
    assert_equal 'orkut.com:999999999999', OpenSocialGadget::Config.keys[consumer_key]['outgoing_key']

    assert_equal 'http://your.domain.com/test/home', OpenSocialGadget::Config.views['home']['url']
    assert_equal '10px', OpenSocialGadget::Config.views['home']['width']
    assert_equal '11px', OpenSocialGadget::Config.views['home']['height']

    assert_equal 'http://your.domain.com/test/canvas', OpenSocialGadget::Config.views['canvas']['url']
    assert_equal '20px', OpenSocialGadget::Config.views['canvas']['width']
    assert_equal '21px', OpenSocialGadget::Config.views['canvas']['height']

    assert_equal 'http://your.domain.com/test/profile', OpenSocialGadget::Config.views['profile']['url']
    assert_equal '30px', OpenSocialGadget::Config.views['profile']['width']
    assert_equal '31px', OpenSocialGadget::Config.views['profile']['height']

    assert_equal 'http://your.domain.com/test/preview', OpenSocialGadget::Config.views['preview']['url']
    assert_equal '40px', OpenSocialGadget::Config.views['preview']['width']
    assert_equal '41px', OpenSocialGadget::Config.views['preview']['height']
  end
end
