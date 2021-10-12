require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "        "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "        "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.name = "a" * 256
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org

                          first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "Addres #{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addressess" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                            foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
    duplicate_user = @user.dup 
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with a nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    annie  = users(:annie)
    archer = users(:archer)
    assert_not annie.following?(archer)
    annie.follow(archer)
    assert annie.following?(archer)
    assert archer.followers.include?(annie)
    annie.unfollow(archer)
    assert_not annie.following?(archer)

    # users can't follow themselves
    annie.follow(annie)
    assert_not annie.following?(annie)
  end

  test "feed should have the right posts" do
    annie  = users(:annie)
    archer = users(:archer)
    lana   = users(:lana)

    # Posts from followed user
    lana.microposts.each do |post_following|
      assert annie.feed.include?(post_following)
    end
    # Self-posts for user with followers
    annie.microposts.each do |post_self|
      assert annie.feed.include?(post_self)
    end
    # Self-posts for user with no followers
    archer.microposts.each do |post_self|
      assert archer.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not annie.feed.include?(post_unfollowed)
    end
  end

end
