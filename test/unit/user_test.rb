require 'test/test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  require "digest/sha1"

  def setup
    @admin_user = users(:admin_user)
    @powerful_user = users(:powerful_user)
  end
  
  def teardown
    @admin_user = @powerful_user = nil
  end
  
  def encrypt(string)
    Digest::SHA1.hexdigest(string)
  end

  def test_create
    assert_difference 'User.count', +1, "A user should be created" do
      user = User.create(:username => 'test_user',
                         :password => 'password')
    end
  end

  def test_read
    assert_nothing_raised "A user should be read" do
      User.find_by_username(@admin_user.username)
    end
  end

  def test_update
    assert @admin_user.update_attributes(:username => 'new_username'), "A User should be updated"
  end

  def test_delete
    assert_difference 'User.count', -1, "A user should be destroyed" do
      @admin_user.destroy
    end
  end

  def test_presence_of_username
    user = User.new
    user.valid?
    assert user.errors.invalid?(:username), "Username should NOT be valid because it's nil"
    
    user.username = ''
    user.valid?
    assert user.errors.invalid?(:username), "Username should NOT be valid because it's empty"
    
    user.username = 'username'
    user.valid?
    assert !user.errors.invalid?(:username), "Username should be valid"
  end

  def test_presence_of_password
    user = User.new
    user.valid?
    assert user.errors.invalid?(:password), "Password should NOT be valid because it's nil"
    
    user.password = ''
    user.valid?
    assert user.errors.invalid?(:password), "Password should NOT be valid because it's empty"
    
    user.password = 'password'
    user.valid?
    assert !user.errors.invalid?(:password), "Password should be valid"
  end

  def test_confirmation_of_password
    user = User.new(:username => 'new_user',
                    :password => 'password',
                    :password_confirmation => 'different_password')
    user.valid?
    assert user.errors.invalid?(:password), "Password should NOT be valid because it's not similar to the password confirmation"
    
    user.password_confirmation = 'password'
    user.valid?
    assert !user.errors.invalid?(:password), "Password should be valid because it's similar to the password confirmation"
  end

  def test_format_of_password
    # TODO
  end
  
  def test_encryption_of_password_for_new_record
    user = User.new(:username => 'username', :password => 'password')
    
    assert_equal user.password, 'password', "Password should NOT be encrypted before save"
    
    user.save!
    assert_equal user.password, encrypt('password'), "Password should be encrypted after save"
  end

  def test_encryption_of_password_for_existing_record
    @admin_user.password = 'new_password'
    assert_equal @admin_user.password, 'new_password', "Password should NOT be encrypted before save"
    
    @admin_user.save!
    assert_equal @admin_user.password, encrypt('new_password'), "Password should be encrypted after save"
  end
  
  def test_unability_to_give_same_password_after_expiration
    @admin_user.password = 'password'
    @admin_user.valid?
    
    assert @admin_user.errors.invalid?(:password), "Password should be invalid because it's similar to previous password"
  end
  
  def test_password_updated_at
    ConfigurationManager.admin_password_validity = 30 # assuming password expire 30 days after updating password
    
    @admin_user.password = "new_password"
    
    assert @admin_user.save!, "The password should be updated without validation error"
    assert_equal encrypt('new_password'), @admin_user.password,
      "The password should be encrypted after the password updating"
    
    assert_not_nil @admin_user.password_updated_at, "password_updated_at should NOT be nil after updating password"
  end
  
  def test_force_password_expiration
    @admin_user.force_password_expiration = "1"
    @admin_user.save
    
    assert_nil @admin_user.password_updated_at, "password_updated_at should be nil"
    assert @admin_user.expired?, "Password should be expired"
  end
  
  def test_expiration_of_password_when_configuration_setting_up_a_delay
    ConfigurationManager.admin_password_validity = 30 # assuming password expire 30 days after updating password
    
    @admin_user.update_attribute(:password_updated_at, Date.today - 1.day)
    assert !@admin_user.expired?, "Password should NOT be expired if password_updated_at < ConfigurationManager.admin_password_validity"
    
    @admin_user.update_attribute(:password_updated_at, Date.today - 60.days)
    assert @admin_user.expired?, "Password should be expired if password_updated_at > ConfigurationManager.admin_password_validity"
    
    @admin_user.update_attribute(:password_updated_at, nil)
    assert @admin_user.expired?, "Password should be expired if password_updated_at is nil"
  end
  
  def test_expiration_of_password_when_configuration_setting_up_no_expiration
    ConfigurationManager.admin_password_validity = 0 # assuming password never expire
    @admin_user.update_attribute(:password_updated_at, Date.today - 1.day)
    assert !@admin_user.expired?, "Password should NOT be expired if ConfigurationManager.admin_password_validity = 0"
    
    @admin_user.update_attribute(:password_updated_at, Date.today - 60.days)
    assert !@admin_user.expired?, "Password should NOT be expired if ConfigurationManager.admin_password_validity = 0, event if password_updated_at > ConfigurationManager.admin_password_validity"
  end
end
