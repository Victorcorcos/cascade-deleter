require 'hierarchy_tree'
require 'deactivator'

# Cascade delete items and all of their children items
# ⚠ Be aware, this lib executes HARD deletions, so
# 1. The items will be completely removed from the database
# 2. No validations or callbacks will be triggered
# Usage 1: CascadeDeleter.new(Project.unscoped.where(active: false)).delete_all
# Usage 2: CascadeDeleter.new(Project.unscoped.where(active: false)).delete_all(
#            custom_joins: { 'Attachment' => {:subproject=>:project} }
#          )
# Usage 3: CascadeDeleter.new(Discipline.where_like(description: '[TO BE DELETED]')).delete_all(
#            method: :soft
#          )

################ Debug ################
# gem cleanup cascade-deleter
# rm cascade-deleter-0.1.0.gem
# gem build hierarchy_tree
# gem install cascade-deleter-0.1.0.gem
# ruby -Itest test/test_cascade_deleter.rb
class CascadeDeleter
  def initialize(items)
    @items = items
    @class = @items.klass
    @classes = classes
  end

  def delete_all(custom_joins: {}, method: :hard)
    Deactivator.new(@classes).without_default_scopes do
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS = 0;')

      ActiveRecord::Base.transaction do
        @classes.map(&:constantize).each do |klass|
          delete(klass, build_join(klass, custom_joins), method)
        end
      end
    ensure
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS = 1;')
    end
  end

  private

  def classes
    Hierarchy.bottom_up_classes(@class).without('Audited::Audit')
  end

  def delete(klass, join, method)
    puts "#{method.to_s.titleize} Deleting #{klass.name.pluralize.titleize}".green
    count = apply_delete(build_query(klass, join), method)
    puts "#{count} #{klass.name.pluralize.titleize} are #{method} deleted".yellow
  end

  def apply_delete(items, method)
    case method
    when :hard
      items.delete_all
    when :soft
      items.update_all(active: false, updated_at: Time.now)
    else
      puts 'Unregistered Delete Method. Possible methods → :hard or :soft'.red
      0
    end
  end

  def build_query(klass, join)
    return @items if @class.to_s == klass.to_s

    klass.joins(join).where(@class.table_name => { id: @items.select(:id) })
  end

  def build_join(model, custom_joins = {})
    custom_joins[model.to_s] || Hierarchy.ancestors_bfs(from: model, to: @class)
    # You can use `Hierarchy.ancestors(from: model, to: @class)` to choose one custom_join
  end
end
