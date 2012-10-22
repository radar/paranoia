require 'test/unit'
require 'active_record'
require File.expand_path(File.dirname(__FILE__) + "/../lib/paranoia")

DB_FILE = 'tmp/test_db'

FileUtils.mkdir_p File.dirname(DB_FILE)
FileUtils.rm_f DB_FILE

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => DB_FILE
ActiveRecord::Base.connection.execute 'CREATE TABLE parent_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)'
ActiveRecord::Base.connection.execute 'CREATE TABLE paranoid_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER, deleted_at DATETIME)'
ActiveRecord::Base.connection.execute 'CREATE TABLE featureful_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME, name VARCHAR(32))'
ActiveRecord::Base.connection.execute 'CREATE TABLE plain_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)'
ActiveRecord::Base.connection.execute 'CREATE TABLE callback_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)'

class ParanoiaTest < Test::Unit::TestCase
  def test_plain_model_class_is_not_paranoid
    assert_equal false, PlainModel.paranoid?
  end

  def test_paranoid_model_class_is_paranoid
    assert_equal true, ParanoidModel.paranoid?
  end

  def test_plain_models_are_not_paranoid
    assert_equal false, PlainModel.new.paranoid?
  end

  def test_paranoid_models_are_paranoid
    assert_equal true, ParanoidModel.new.paranoid?
  end

  def test_paranoid_models_to_param
    model = ParanoidModel.new
    model.save
    to_param = model.to_param

    model.destroy

    assert_not_equal nil, model.to_param
    assert_equal to_param, model.to_param
  end

  def test_destroy_behavior_for_plain_models
    model = PlainModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy

    assert_equal true, model.deleted_at.nil?
    assert model.frozen?

    assert_equal 0, model.class.count
    assert_equal 0, model.class.unscoped.count
  end

  def test_destroy_behavior_for_paranoid_models
    model = ParanoidModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy

    assert_equal false, model.deleted_at.nil?
    assert model.frozen?

    assert_equal 0, model.class.count
    assert_equal 1, model.class.unscoped.count

  end
  
  def test_scoping_behavior_for_paranoid_models
    ParanoidModel.unscoped.delete_all
    parent1 = ParentModel.create
    parent2 = ParentModel.create
    p1 = ParanoidModel.create(:parent_model => parent1)
    p2 = ParanoidModel.create(:parent_model => parent2)
    p1.destroy
    p2.destroy
    assert_equal 0, parent1.paranoid_models.count
    assert_equal 1, parent1.paranoid_models.only_deleted.count
    p3 = ParanoidModel.create(:parent_model => parent1)
    assert_equal 2, parent1.paranoid_models.with_deleted.count
    assert_equal [p1,p3], parent1.paranoid_models.with_deleted
  end

  def test_destroy_behavior_for_featureful_paranoid_models
    model = get_featureful_model
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy

    assert_equal false, model.deleted_at.nil?

    assert_equal 0, model.class.count
    assert_equal 1, model.class.unscoped.count
  end

  def test_only_destroyed_scope_for_paranoid_models
    model = ParanoidModel.new
    model.save
    model.destroy
    model2 = ParanoidModel.new
    model2.save

    assert_equal model, ParanoidModel.only_deleted.last
    assert_equal false, ParanoidModel.only_deleted.include?(model2)
  end
  
  def test_delete_behavior_for_callbacks
    model = CallbackModel.new
    model.save
    model.delete
    assert_equal nil, model.instance_variable_get(:@callback_called)
  end
  
  def test_destroy_behavior_for_callbacks
    model = CallbackModel.new
    model.save
    model.destroy
    assert model.instance_variable_get(:@callback_called)
  end
  
  def test_restore
    model = ParanoidModel.new
    model.save
    id = model.id
    model.destroy
    
    assert model.destroyed?
    
    model = ParanoidModel.only_deleted.find(id)
    model.restore!
    
    assert_equal false, model.destroyed?
  end
  
  def test_real_destroy
    model = ParanoidModel.new
    model.save
    model.destroy!
    
    assert_equal false, ParanoidModel.unscoped.exists?(model.id)
  end
  
  def test_real_delete
    model = ParanoidModel.new
    model.save
    model.delete!
    
    assert_equal false, ParanoidModel.unscoped.exists?(model.id)
  end

  private
  def get_featureful_model
    FeaturefulModel.new(:name => "not empty")
  end
end

# Helper classes

class ParentModel < ActiveRecord::Base
  has_many :paranoid_models
end

class ParanoidModel < ActiveRecord::Base
  belongs_to :parent_model
  acts_as_paranoid
end

class FeaturefulModel < ActiveRecord::Base
  acts_as_paranoid
  validates :name, :presence => true, :uniqueness => true
end

class PlainModel < ActiveRecord::Base
end

class CallbackModel < ActiveRecord::Base
  acts_as_paranoid
  before_destroy {|model| model.instance_variable_set :@callback_called, true }
end
