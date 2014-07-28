require 'test_helper'

class ThreatsControllerTest < ActionController::TestCase
  setup do
    @threat = threats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:threats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create threat" do
    assert_difference('Threat.count') do
      post :create, threat: { description: @threat.description, image_url: @threat.image_url, name: @threat.name }
    end

    assert_redirected_to threat_path(assigns(:threat))
  end

  test "should show threat" do
    get :show, id: @threat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @threat
    assert_response :success
  end

  test "should update threat" do
    put :update, id: @threat, threat: { description: @threat.description, image_url: @threat.image_url, name: @threat.name }
    assert_redirected_to threat_path(assigns(:threat))
  end

  test "should destroy threat" do
    assert_difference('Threat.count', -1) do
      delete :destroy, id: @threat
    end

    assert_redirected_to threats_path
  end
end
