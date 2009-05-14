require 'test_helper'
OpenSocialGadget::Config.load File.join('<%= plugin_root %>', 'test', 'gadget.yml')

CONSUMER_KEY = '999999999999'
REQUESTOR_ID = '00000000000000000000'
VIEW_TYPE = 'home'

class <%= class_name %>ControllerTest < ActionController::TestCase
  def setup
    @controller = <%= class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_iframe
    secret = OpenSocialGadget::Config.keys[CONSUMER_KEY]['secret']
    
    width = OpenSocialGadget::Config.views[VIEW_TYPE]['width']
    height = OpenSocialGadget::Config.views[VIEW_TYPE]['height']
    
    @controller.expects(:validate).returns(true)
    
    get :iframe,
        :opensocial_owner_id => REQUESTOR_ID,
        :opensocial_viewer_id => REQUESTOR_ID,
        :oauth_consumer_key => CONSUMER_KEY,
        :id => VIEW_TYPE
    
    assert_response :success
  end

  def test_redirect
    get :redirect,
        :owner_id => REQUESTOR_ID,
        :viewer_id => REQUESTOR_ID,
        :consumer_key => CONSUMER_KEY,
        :view_type => VIEW_TYPE
    
    assert_redirected_to OpenSocialGadget::Config.views[VIEW_TYPE]['url']
  end
end
