module Paranoia
  def self.included(klazz)
    klazz.extend Query
  end

  module Query
    def paranoid? ; true ; end

    def only_deleted
      scoped.tap { |x| x.default_scoped = false }.where("#{self.table_name}.deleted_at is not null")
    end

    def with_deleted
      scoped.tap { |x| x.default_scoped = false }
    end
  end

  def destroy
    _run_destroy_callbacks { delete }
  end

  def delete
    update_attribute_or_column(:deleted_at, Time.now) if !deleted? && persisted?
    freeze
  end

  def restore!
    update_attribute_or_column :deleted_at, nil
  end

  def destroyed?
    !self.deleted_at.nil?
  end
  alias :deleted? :destroyed?

  private

  # Rails 3.1 adds update_column. Rails > 3.2.6 deprecates update_attribute, gone in Rails 4.
  def update_attribute_or_column(*args)
    respond_to?(:update_column) ? update_column(*args) : update_attribute(*args)
  end
end

require 'paranoia/active_record'
