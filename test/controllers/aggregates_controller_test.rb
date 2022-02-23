require 'test_helper'

class AggregatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get aggregates_index_url
    assert_response :success
  end

  test "should get create" do
    get aggregates_create_url
    assert_response :success
  end

  test "should get update" do
    get aggregates_update_url
    assert_response :success
  end

end
