require "test_helper"

class FollowingTest < ActionDispatch::IntegrationTest
  attr_reader :user, :other

  def setup
    @user = users :michael
    @other = users :archer
    log_in_as user

    Settings.reload_from_files(
      Rails.root.join("config", "settings.yml").to_s
    )
  end

  test "following page" do
    get relationships_path user_id: user.id, is_following: true
    assert_not user.following.empty?
    assert_match user.following.count.to_s, response.body
    user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get relationships_path user_id: user.id
    assert_not user.followers.empty?
    assert_match user.followers.count.to_s, response.body
    user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow a user the standard way" do
    assert_difference "user.following.count", 1 do
      post relationships_path, params: {followed_id: other.id}
    end
  end

  test "should follow a user with Ajax" do
    assert_difference "user.following.count", 1 do
      post relationships_path, xhr: true, params: {followed_id: other.id}
    end
  end

  test "should unfollow a user the standard way" do
    user.follow other
    relationship = user.active_relationships.find_by followed_id: other.id
    assert_difference "user.following.count", -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    user.follow other
    relationship = user.active_relationships.find_by followed_id: other.id
    assert_difference "user.following.count", -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  test "feed on Home page" do
    get root_path
    Micropost.feeds(user.id).order_desc.paginate(page: 1).each do |micropost|
      assert_match CGI.escapeHTML(micropost.content), response.body
    end
  end
end
