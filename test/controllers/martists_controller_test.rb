require "test_helper"

class MartistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @martist = martists(:one)
  end

  test "should get index" do
    get martists_url, as: :json
    assert_response :success
  end

  test "should create martist" do
    assert_difference("Martist.count") do
      post martists_url, params: { martist: {  } }, as: :json
    end

    assert_response :created
  end

  test "should show martist" do
    get martist_url(@martist), as: :json
    assert_response :success
  end

  test "should update martist" do
    patch martist_url(@martist), params: { martist: {  } }, as: :json
    assert_response :success
  end

  test "should destroy martist" do
    assert_difference("Martist.count", -1) do
      delete martist_url(@martist), as: :json
    end

    assert_response :no_content
  end
end
