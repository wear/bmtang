require File.dirname(__FILE__) + '/../test_helper'

class ControllerExtensionsTest < Test::Unit::TestCase
  def setup
    @controller = DummyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:opensocial_params] = {
      :owner_id => consumer_key,
      :viewer_id => consumer_key,
      :consumer_key => consumer_key,
      :view_type => view_type
    }
  end

  def test_index
    OpenSocial::FetchPersonRequest.any_instance.expects(:send).returns(get_person)
    
    get :index
    assert_equal OpenSocialGadget::Config.prefs, @controller.opensocial_prefs
    assert_equal @request.session[:opensocial_params], @controller.opensocial_params
    assert_equal OpenSocialGadget::Config.views[@request.session[:opensocial_params][:view_type]], @controller.opensocial_view
    assert_response :success
  end
end

class DummyController < ActionController::Base
  include OpenSocialGadget::ControllerExtensions
  def index
    me = opensocial_connection.get_person
    render :text => "viewing index"
  end
  def rescue_action(e)
    raise e
  end
end

